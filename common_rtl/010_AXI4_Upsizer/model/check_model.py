"""Byte-level check of the algorithm of the specification (cycle model), random AXI traffic, write phase then read phase.

Run: UPS_S=32 UPS_M=128 python check_model.py [n_txn] [seed]   (exit code 0 when no error)
"""
import os
import random
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ups_cycle_model as M  # noqa: E402
from ups_cycle_model import Upsizer, beat_addr, INCR, FIXED, WRAP, SB, MB, LS, LM  # noqa: E402

N = int(sys.argv[1]) if len(sys.argv) > 1 else 300
SEED = int(sys.argv[2]) if len(sys.argv) > 2 else 1
rnd = random.Random(SEED)
R = MB // SB


def valid_addrs(addr, size, length, burst, idx):
    """byte addresses of the valid lanes of beat idx"""
    nb = 1 << size
    a = beat_addr(addr, size, length, burst, idx)
    if idx == 0:
        end = (a // nb + 1) * nb
        return list(range(a, end))
    return list(range((a // nb) * nb, (a // nb) * nb + nb))


def rand_txn(is_wr):
    while True:
        burst = rnd.choice([INCR, INCR, INCR, WRAP, FIXED])
        size = rnd.choice([LS, LS, LS, rnd.randint(0, LS)])
        nb = 1 << size
        if burst == WRAP:
            length = rnd.choice([1, 3, 7, 15])
            addr = rnd.randrange(0, 0x1000 // nb) * nb
        elif burst == FIXED:
            length = rnd.randint(0, 15)
            addr = rnd.randrange(0, 0x1000)
        else:
            length = rnd.randint(0, 40)
            addr = rnd.randrange(0, 0x1000)
        base = rnd.choice([0x0, 0x1000, 0x20000])
        # no 4KB crossing
        last = beat_addr(addr, size, length, burst, length) if burst != INCR else (addr // nb) * nb + length * nb
        if burst == INCR and (addr // 4096) != ((last + nb - 1) // 4096):
            continue
        cache = rnd.choice([0, 2, 2, 2, 3, 0xB])
        lock = rnd.choice([0, 0, 0, 0, 1])
        return dict(addr=base + addr, length=length, size=size, burst=burst, lock=lock, cache=cache)


def mem_byte(mem, a):
    return mem.get(a, (a * 7 + 3) & 255)


def run_phase(txns, is_wr, delays):
    u = Upsizer(4, 4)
    u.zero = (None, 0)
    mem = {}
    ref = {}
    # S-side manager
    pa = 0
    wbeats = []     # list of dict(label=list of SB bytes, strb=int, last=bool) in AW order
    expected_writes = []
    for t in txns:
        for n in range(t['length'] + 1):
            va = valid_addrs(t['addr'], t['size'], t['length'], t['burst'], n)
            data = [0] * SB
            strb = 0
            for a in va:
                if rnd.random() < 0.8:
                    j = a % SB
                    data[j] = rnd.randrange(256)
                    strb |= 1 << j
                    ref[a] = data[j]
            wbeats.append(dict(label=data, strb=strb, last=(n == t['length'])))
    pw = 0
    # M-side subordinate state
    m_aw_q = []        # converted attributes with remaining beat index
    m_w_idx = 0
    b_pending = []
    m_ar_q = []
    m_r_beats = []     # beats to present: dict(cycle, slots, resp, last)
    m_r_ptr = 0
    s_r_got = []       # S-side R beats received
    pr = 0
    cyc = 0
    errors = []
    s_beats_expected = []
    if not is_wr:
        for t in txns:
            for n in range(t['length'] + 1):
                s_beats_expected.append((t, n))
    done = False
    maxc = 200000
    exp_m_beats = 0
    got_m_beats = 0
    while not done and cyc < maxc:
        v = u.view(cyc)
        awv = is_wr and pa < len(txns) and cyc >= delays['aw'][pa]
        wv = is_wr and pw < len(wbeats) and cyc >= delays['w'][pw]
        arv = (not is_wr) and pr < len(txns) and cyc >= delays['aw'][pr]
        mrv = m_r_ptr < len(m_r_beats) and cyc >= m_r_beats[m_r_ptr]['cycle']
        mbv = bool(b_pending) and cyc >= b_pending[0]
        sink = dict(m_awready=rnd.random() < 0.8, m_wready=rnd.random() < 0.8, m_arready=rnd.random() < 0.8,
                    s_bready=rnd.random() < 0.8, s_rready=rnd.random() < 0.8)
        inp = dict(awvalid=awv, arvalid=arv, wvalid=wv, m_bvalid=mbv, m_rvalid=mrv,
                   aw=(dict(txns[pa]) if awv else None), ar=(dict(txns[pr]) if arv else None),
                   w=wbeats[pw] if wv else None, m_b=dict(resp=0) if mbv else None,
                   m_r=m_r_beats[m_r_ptr] if mrv else None)
        # observe the M side before the edge
        if u.aw_sl.v and sink['m_awready']:
            m_aw_q.append(dict(u.aw_sl.d))
        if u.ar_sl.v and sink['m_arready']:
            t = dict(u.ar_sl.d)
            m_ar_q.append(t)
            # downstream builds its R beats
            c0 = cyc + rnd.randint(2, 6)
            for n in range(t['len'] + 1):
                a = beat_addr(t['addr'], t['size'], t['len'], t['burst'], n)
                base = (a // MB) * MB
                slots = []
                for k in range(R):
                    slots.append([mem_byte(mem, base + k * SB + j) for j in range(SB)])
                c0 += rnd.choice([0, 0, 1])
                m_r_beats.append(dict(cycle=c0, slots=slots, resp=0, last=(n == t['len'])))
                c0 += 0
        if u.w_sl.v and sink['m_wready']:
            beat = u.w_sl.d
            t = m_aw_q[0] if m_aw_q else None
            if t is None:
                errors.append('M W beat before the M AW at cycle %d' % cyc)
            else:
                a = beat_addr(t['addr'], t['size'], t['len'], t['burst'], m_w_idx)
                nb = 1 << t['size']
                if m_w_idx == 0:
                    vaddrs = range(a, (a // nb + 1) * nb)
                else:
                    vaddrs = range((a // nb) * nb, (a // nb) * nb + nb)
                base = (a // MB) * MB
                valid_lanes = {x - base for x in vaddrs}
                for k in range(R):
                    sl = beat['data'][k]
                    st = beat['strb_list'][k]
                    for j in range(SB):
                        lane = k * SB + j
                        if (st >> j) & 1:
                            if lane not in valid_lanes:
                                errors.append('strobe outside the valid lanes at cycle %d lane %d' % (cyc, lane))
                            mem[base + lane] = sl[j]
                last_exp = (m_w_idx == t['len'])
                if bool(beat['last']) != last_exp:
                    errors.append('WLAST mismatch at cycle %d' % cyc)
                got_m_beats += 1
                if last_exp:
                    m_aw_q.pop(0)
                    m_w_idx = 0
                    b_pending.append(cyc + 2)
                else:
                    m_w_idx += 1
        hs = u.step(v, inp, sink)
        if hs['aw_hs']:
            pa += 1
        if hs['ar_hs']:
            pr += 1
        if hs['w_hs']:
            pw += 1
        if hs['mr_hs']:
            m_r_ptr += 1
        if hs['mb_hs']:
            b_pending.pop(0)
        # S-side R beats received this cycle (before the edge the slice output was visible)
        if not is_wr and u.r_sl.v is not None:
            pass
        cyc += 1
        if is_wr:
            done = pa == len(txns) and pw == len(wbeats) and not b_pending and not u.b_sl.v and not u.w_sl.v and not u.aw_sl.v and not m_aw_q
        else:
            done = pr == len(txns) and not u.r_sl.v and m_r_ptr == len(m_r_beats) and u.word is None and not u.rq and not u.ar_sl.v
        # collect S R beat handshakes: the slice output consumed this cycle
        if not is_wr and getattr(u, '_last_r', None) is not None:
            pass
    return u, mem, ref, errors, cyc, got_m_beats, s_r_got


# ---- the S-side R beat collector needs the slice output at each cycle: wrap Upsizer.step -------------------
_orig_step = Upsizer.step


def step_hook(self, v, inp, sink):
    if self.r_sl.v and sink['s_rready']:
        self.s_r_log = getattr(self, 's_r_log', [])
        self.s_r_log.append(self.r_sl.d)
    return _orig_step(self, v, inp, sink)


Upsizer.step = step_hook


def main():
    fails = 0
    classes = {}
    # ---- write phase
    txns = [rand_txn(True) for _ in range(N)]
    delays = dict(aw=[0] * len(txns), w=[0] * sum(t['length'] + 1 for t in txns))
    c = 0
    for k in range(len(delays['aw'])):
        c += rnd.choice([0, 1, 2, 5])
        delays['aw'][k] = c
    c = 0
    for k in range(len(delays['w'])):
        c += rnd.choice([0, 0, 0, 1, 3])
        delays['w'][k] = c
    u, mem, ref, errors, cyc, nm, _ = run_phase(txns, True, delays)
    for a, vv in ref.items():
        if mem.get(a) != vv:
            errors.append('memory byte %#x differs: M side %s expected %s' % (a, mem.get(a), vv))
            break
    for a in mem:
        if a not in ref:
            errors.append('M side wrote byte %#x that the S side did not write' % a)
            break
    exp_m = 0
    for t in txns:
        from ups_cycle_model import convert
        exp_m += convert(**t)['len'] + 1
    if nm != exp_m:
        errors.append('M W beats %d expected %d' % (nm, exp_m))
    packed = sum(1 for t in txns if M.convert(**t)['pack'])
    print('WRITE ratio %d: %d txns (%d packed), %d S beats, %d M beats, %d cycles, errors %d' % (R, len(txns), packed, sum(t['length'] + 1 for t in txns), nm, cyc, len(errors)))
    for e in errors[:5]:
        print('   ', e)
    fails += len(errors)
    # ---- read phase: memory contents are the default pattern
    txns = [rand_txn(False) for _ in range(N)]
    delays = dict(aw=[0] * len(txns), w=[])
    c = 0
    for k in range(len(txns)):
        c += rnd.choice([0, 1, 2, 5])
        delays['aw'][k] = c
    u, mem, ref, errors, cyc, nm, _ = run_phase(txns, False, delays)
    got = getattr(u, 's_r_log', [])
    exp = []
    for t in txns:
        for n in range(t['length'] + 1):
            exp.append((t, n))
    if len(got) != len(exp):
        errors.append('S R beats %d expected %d' % (len(got), len(exp)))
    else:
        for (t, n), g in zip(exp, got):
            va = valid_addrs(t['addr'], t['size'], t['length'], t['burst'], n)
            for a in va:
                if g['data'][a % SB] != mem_byte({}, a):
                    errors.append('read byte %#x wrong in txn %s beat %d' % (a, t, n))
                    break
            if g['last'] != (n == t['length']):
                errors.append('RLAST wrong in txn %s beat %d' % (t, n))
            if g['resp'] != 0:
                errors.append('RRESP wrong')
    packed = sum(1 for t in txns if M.convert(**t)['pack'])
    print('READ  ratio %d: %d txns (%d packed), %d S beats, %d cycles, errors %d' % (R, len(txns), packed, len(exp), cyc, len(errors)))
    for e in errors[:5]:
        print('   ', e)
    fails += len(errors)
    return fails


if __name__ == '__main__':
    sys.exit(1 if main() else 0)
