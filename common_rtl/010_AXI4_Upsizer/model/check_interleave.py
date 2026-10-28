"""Byte-level check of the AXI3 write data interleaving (WID contexts) on the cycle model.

Run: UPS_S=32 UPS_M=128 python check_interleave.py [n_txn] [seed] [depth]   (exit code 0 when no error)
The manager interleaves the data of up to `depth` transactions with different WID values; the downstream
memory model accepts interleaved M-side data (it matches the WID of each M beat with the M AW).
"""
import os
import random
import sys

n_arg = sys.argv[1:] or ['200', '1', '2']
sys.argv = ['x', n_arg[0], n_arg[1]]
DEPTH = int(n_arg[2]) if len(n_arg) > 2 else 2
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import check_model as T  # noqa: E402
from ups_cycle_model import Upsizer, beat_addr, SB, MB  # noqa: E402
import ups_cycle_model as M  # noqa: E402

rnd = random.Random(int(n_arg[1]) + 1000)
R = MB // SB
IDS = 4


def main():
    txns = []
    for k in range(int(n_arg[0])):
        t = T.rand_txn(True)
        t['id'] = rnd.randrange(IDS)
        # one 4KB page per transaction: the order of overlapping bytes of different IDs is not defined by AXI
        t['addr'] = (k << 12) | (t['addr'] & 0xFFF)
        txns.append(t)
    # beats of every transaction
    ref = {}
    beats = []
    for t in txns:
        bl = []
        for n in range(t['length'] + 1):
            va = T.valid_addrs(t['addr'], t['size'], t['length'], t['burst'], n)
            data = [0] * SB
            strb = 0
            for a in va:
                if rnd.random() < 0.8:
                    j = a % SB
                    data[j] = rnd.randrange(256)
                    strb |= 1 << j
                    ref[a] = data[j]
            bl.append(dict(label=data, strb=strb, last=(n == t['length']), wid=t['id']))
        beats.append(bl)
    u = Upsizer(8, 4, DEPTH)
    u.zero = (None, 0)
    mem = {}
    pa = 0
    nxt_beat = [0] * len(txns)
    finished = [False] * len(txns)
    active = []         # indices of transactions whose data has started and is not complete
    offer = None        # (txn index, beat) held until accepted
    m_aw = []           # dict(t, bi, id)
    b_pending = []
    errors = []
    cyc = 0
    got_m = 0
    max_active = 0
    interleaved_beats = 0
    last_w_txn = None
    awc = 0
    aw_delay = []
    for _ in txns:
        awc += rnd.choice([0, 1, 2, 4])
        aw_delay.append(awc)
    while cyc < 400000:
        v = u.view(cyc)
        awv = pa < len(txns) and cyc >= aw_delay[pa]
        if offer is None:
            cands = []
            ids_active = {txns[i]['id'] for i in active}
            for i in range(pa):          # only transactions whose AW was issued (AW before W)
                if finished[i] or nxt_beat[i] >= len(beats[i]):
                    continue
                if i in active:
                    cands.append(i)
                elif len(active) < DEPTH and txns[i]['id'] not in ids_active and not any((not finished[j]) and txns[j]['id'] == txns[i]['id'] for j in range(i)):
                    cands.append(i)
            if cands and rnd.random() < 0.85:
                i = rnd.choice(cands)
                if i not in active:
                    active.append(i)
                offer = (i, beats[i][nxt_beat[i]])
        wv = offer is not None
        sink = dict(m_awready=rnd.random() < 0.8, m_wready=rnd.random() < 0.8, m_arready=True, s_bready=True, s_rready=True)
        mbv = bool(b_pending) and cyc >= b_pending[0]
        inp = dict(awvalid=awv, arvalid=False, wvalid=wv, m_bvalid=mbv, m_rvalid=False,
                   aw=(dict(txns[pa], id=txns[pa]['id']) if awv else None), ar=None,
                   w=offer[1] if wv else None, m_b=dict(resp=0) if mbv else None, m_r=None)
        if awv:
            inp['aw'] = {k: txns[pa][k] for k in ('addr', 'length', 'size', 'burst', 'lock', 'cache')}
            inp['aw']['id'] = txns[pa]['id']
        if u.aw_sl.v and sink['m_awready']:
            m_aw.append(dict(t=dict(u.aw_sl.d), bi=0, id=u.aw_sl.d['id']))
        if u.w_sl.v and sink['m_wready']:
            beat = u.w_sl.d
            e = None
            for x in m_aw:
                if x['id'] == beat['wid']:
                    e = x
                    break
            if e is None:
                errors.append('M W beat with WID %s has no M AW at cycle %d' % (beat['wid'], cyc))
            else:
                t = e['t']
                a = beat_addr(t['addr'], t['size'], t['len'], t['burst'], e['bi'])
                nb = 1 << t['size']
                vad = range(a, (a // nb + 1) * nb) if e['bi'] == 0 else range((a // nb) * nb, (a // nb) * nb + nb)
                base = (a // MB) * MB
                lanes = {x - base for x in vad}
                for k in range(R):
                    for j in range(SB):
                        if (beat['strb_list'][k] >> j) & 1:
                            if k * SB + j not in lanes:
                                errors.append('strobe outside the valid lanes at cycle %d' % cyc)
                            mem[base + k * SB + j] = beat['data'][k][j]
                if bool(beat['last']) != (e['bi'] == t['len']):
                    errors.append('WLAST mismatch at cycle %d' % cyc)
                got_m += 1
                if e['bi'] == t['len']:
                    m_aw.remove(e)
                    b_pending.append(cyc + 2)
                else:
                    e['bi'] += 1
        hs = u.step(v, inp, sink)
        max_active = max(max_active, len(u.ctxs))
        if hs['aw_hs']:
            pa += 1
        if hs['w_hs']:
            i, b = offer
            if last_w_txn is not None and last_w_txn != i and not finished[last_w_txn] and nxt_beat[last_w_txn] < len(beats[last_w_txn]):
                interleaved_beats += 1
            last_w_txn = i
            nxt_beat[i] += 1
            offer = None
            if nxt_beat[i] >= len(beats[i]):
                finished[i] = True
                active.remove(i)
        if hs['mb_hs']:
            b_pending.pop(0)
        cyc += 1
        if pa == len(txns) and all(finished) and not b_pending and not u.b_sl.v and not u.w_sl.v and not u.aw_sl.v and not m_aw and u.w_stage is None:
            break
    else:
        errors.append('timeout (deadlock) after %d cycles' % cyc)
    for a, vv in ref.items():
        if mem.get(a) != vv:
            errors.append('memory byte %#x differs' % a)
            break
    for a in mem:
        if a not in ref:
            errors.append('byte %#x written by the M side only' % a)
            break
    exp_m = sum(M.convert(**{k: t[k] for k in ('addr', 'length', 'size', 'burst', 'lock', 'cache')})['len'] + 1 for t in txns)
    if got_m != exp_m:
        errors.append('M beats %d expected %d' % (got_m, exp_m))
    print('AXI3 interleave depth %d ratio %d: %d txns, %d S beats, %d M beats, %d cycles, max contexts %d, beats that switched transaction while another was open %d, errors %d'
          % (DEPTH, R, len(txns), sum(len(b) for b in beats), got_m, cyc, max_active, interleaved_beats, len(errors)))
    for e in errors[:5]:
        print('   ', e)
    return len(errors)


sys.exit(1 if main() else 0)
