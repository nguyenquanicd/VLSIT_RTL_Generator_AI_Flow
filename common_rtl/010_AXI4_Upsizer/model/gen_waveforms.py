"""Generate the WaveJSON files of the waveform plan of the AXI4 upsizer specification from the cycle model.

Usage: python gen_waveforms.py OUT_DIR   (then render each file with vlsit_waveform_svg.py render --cell 54)
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from ups_cycle_model import (Upsizer, INCR, FIXED, WRAP, LS, LM, MB, SB)  # noqa: E402

OUT = sys.argv[1] if len(sys.argv) > 1 else 'wf'
os.makedirs(OUT, exist_ok=True)
BURST = {0: 'FIXED', 1: 'INCR', 2: 'WRAP'}
RESP = {0: 'OKAY', 2: 'SLVERR', 3: 'DECERR'}


def aw(cycle, addr, length, size=LS, burst=INCR, cache=2, lock=0, id=0):
    return dict(cycle=cycle, addr=addr, length=length, size=size, burst=burst, lock=lock, cache=cache, id=id)


def wbeats(cycles, labels, strb='F', wid=0):
    n = len(labels)
    return [dict(cycle=c, label=l, strb=strb if isinstance(strb, str) else strb[k], last=(k == n - 1), wid=wid) for k, (c, l) in enumerate(zip(cycles, labels))]


def lo(spec):
    out = set()
    for a, b in spec:
        out.update(range(a, b + 1))
    return out


def run(ncyc, aws=(), ws=(), ars=(), mrs=(), depth=4, m_awready_low=(), m_wready_low=(), m_arready_low=(),
        s_bready_low=(), s_rready_low=(), b_delay=2, b_resps=(0,), start=0, il=0):
    u = Upsizer(depth, depth, il)
    aws, ws, ars, mrs = list(aws), list(ws), list(ars), list(mrs)
    pa = pw = pr = pm = 0
    b_pending = []
    bi = 0
    recs = []
    for i in range(ncyc):
        c = i + start
        v = u.view(i)
        awv = pa < len(aws) and c >= aws[pa]['cycle']
        wv = pw < len(ws) and c >= ws[pw]['cycle']
        arv = pr < len(ars) and c >= ars[pr]['cycle']
        mrv = pm < len(mrs) and c >= mrs[pm]['cycle']
        mbv = bool(b_pending) and c >= b_pending[0][0]
        m_b = dict(resp=b_pending[0][1]) if mbv else None
        sink = dict(m_awready=c not in m_awready_low, m_wready=c not in m_wready_low, m_arready=c not in m_arready_low,
                    s_bready=c not in s_bready_low, s_rready=c not in s_rready_low)
        rec = {}
        rec['s_awvalid'] = int(awv)
        rec['s_awready'] = int(v['awready'])
        rec['s_aw'] = aws[pa] if awv else None
        rec['m_awvalid'] = int(u.aw_sl.v)
        rec['m_awready'] = int(sink['m_awready'])
        rec['m_aw'] = u.aw_sl.d if u.aw_sl.v else None
        rec['s_wvalid'] = int(wv)
        rec['s_wready'] = int(v['wready'])
        rec['s_w'] = ws[pw] if wv else None
        rec['m_wvalid'] = int(u.w_sl.v)
        rec['m_wready'] = int(sink['m_wready'])
        rec['m_w'] = u.w_sl.d if u.w_sl.v else None
        rec['m_bvalid'] = int(mbv)
        rec['m_bready'] = int(v['bready_m'])
        rec['m_b'] = m_b
        rec['s_bvalid'] = int(u.b_sl.v)
        rec['s_bready'] = int(sink['s_bready'])
        rec['s_b'] = u.b_sl.d if u.b_sl.v else None
        rec['s_arvalid'] = int(arv)
        rec['s_arready'] = int(v['arready'])
        rec['s_ar'] = ars[pr] if arv else None
        rec['m_arvalid'] = int(u.ar_sl.v)
        rec['m_arready'] = int(sink['m_arready'])
        rec['m_ar'] = u.ar_sl.d if u.ar_sl.v else None
        rec['m_rvalid'] = int(mrv)
        rec['m_rready'] = int(v['rready_m'])
        rec['m_r'] = mrs[pm] if mrv else None
        rec['s_rvalid'] = int(u.r_sl.v)
        rec['s_rready'] = int(sink['s_rready'])
        rec['s_r'] = u.r_sl.d if u.r_sl.v else None
        rec['rst'] = 1
        rec['cycle'] = c
        # events
        wl_consumed = u.w_sl.v and sink['m_wready'] and u.w_sl.d is not None and u.w_sl.d['last']
        inp = dict(awvalid=awv, arvalid=arv, wvalid=wv, m_bvalid=mbv, m_rvalid=mrv,
                   aw=({k: aws[pa][k] for k in ('addr', 'length', 'size', 'burst', 'lock', 'cache', 'id')} if awv else None),
                   ar=({k: ars[pr][k] for k in ('addr', 'length', 'size', 'burst', 'lock', 'cache')} if arv else None),
                   w=ws[pw] if wv else None, m_b=m_b, m_r=mrs[pm] if mrv else None)
        hs = u.step(v, inp, sink)
        if hs['aw_hs']:
            pa += 1
        if hs['ar_hs']:
            pr += 1
        if hs['w_hs']:
            pw += 1
        if hs['mr_hs']:
            pm += 1
        if hs['mb_hs']:
            b_pending.pop(0)
        if wl_consumed:
            b_pending.append((c + b_delay, b_resps[min(bi, len(b_resps) - 1)]))
            bi += 1
        recs.append(rec)
    return recs


def reset_rec(c):
    rec = {k: 0 for k in ('s_awvalid', 's_awready', 'm_awvalid', 'm_awready', 's_wvalid', 's_wready', 'm_wvalid', 'm_wready',
                          'm_bvalid', 'm_bready', 's_bvalid', 's_bready', 's_arvalid', 's_arready', 'm_arvalid', 'm_arready',
                          'm_rvalid', 'm_rready', 's_rvalid', 's_rready')}
    for k in ('s_aw', 'm_aw', 's_w', 'm_w', 'm_b', 's_b', 's_ar', 'm_ar', 'm_r', 's_r'):
        rec[k] = None
    rec['rst'] = 0
    rec['cycle'] = c
    return rec


# ---------------------------------------------------------------------------------------------------------
def tok_aw(a, key):
    if a is None:
        return None
    if key == 'addr':
        return '%X' % a['addr']
    if key == 'len':
        return str(a['len'] if 'len' in a else a['length'])
    if key == 'size':
        return str(a['size'])
    if key == 'burst':
        return BURST[a['burst']]
    if key == 'cache':
        return '%X' % a['cache'] if 'cache' in a else None
    if key == 'id':
        return str(a['id']) if 'id' in a else None


def dig(vals):
    s = ''
    prev = None
    for v in vals:
        if v == prev:
            s += '.'
        else:
            s += str(v)
        prev = v
    return s


def dat(vals):
    s = ''
    data = []
    prev = object()
    for v in vals:
        if v == prev:
            s += '.'
        elif v is None:
            s += 'x'
        else:
            s += '='
            data.append(v)
        prev = v
    return s, data


def sig(name, vals, kind):
    if kind == 'bit':
        return dict(name=name, wave=dig(vals))
    w, d = dat(vals)
    o = dict(name=name, wave=w)
    if d:
        o['data'] = d
    return o


def build(recs, groups, title):
    n = len(recs)
    rows = [dict(name='i_clk_axi', wave='p' + '.' * (n - 1)), dict(name='i_rst_n_axi', wave=dig([r['rst'] for r in recs]))]
    sw = []
    for g in groups:
        items = [g[0]]
        for spec in g[1:]:
            name, key, kind = spec[0], spec[1], spec[2]
            if kind == 'bit':
                items.append(sig(name, [r[key] for r in recs], 'bit'))
            else:
                f = spec[3]
                items.append(sig(name, [f(r) for r in recs], 'data'))
        sw.append(items)
    return dict(signal=rows + sw, head=dict(text=title, tick=0), config=dict(hscale=1))


def f_aw(side, key):
    def f(r):
        a = r['s_aw'] if side == 's' else r['m_aw']
        if side == 's' and a is not None:
            a = dict(a, len=a['length'])
        return tok_aw(a, key)
    return f


def f_ar(side, key):
    def f(r):
        a = r['s_ar'] if side == 's' else r['m_ar']
        if side == 's' and a is not None:
            a = dict(a, len=a['length'])
        return tok_aw(a, key)
    return f


def f_sw(key):
    def f(r):
        w = r['s_w']
        if w is None:
            return None
        return {'data': w['label'], 'strb': w['strb'], 'last': '1' if w['last'] else '0', 'wid': str(w.get('wid', 0))}[key]
    return f


def f_mw(key):
    def f(r):
        w = r['m_w']
        if w is None:
            return None
        if key == 'data':
            return '|'.join(reversed(w['data']))
        if key == 'strb':
            return w['strb']
        if key == 'wid':
            return str(w['wid'])
        return '1' if w['last'] else '0'
    return f


def f_b(side):
    def f(r):
        b = r['m_b'] if side == 'm' else r['s_b']
        return None if b is None else RESP[b['resp']]
    return f


def f_mr(key):
    def f(r):
        m = r['m_r']
        if m is None:
            return None
        if key == 'data':
            return '|'.join(reversed(m['slots']))
        if key == 'resp':
            return RESP[m['resp']]
        return '1' if m.get('last') else '0'
    return f


def f_sr(key):
    def f(r):
        s = r['s_r']
        if s is None:
            return None
        return {'data': s['data'], 'resp': RESP[s['resp']], 'last': '1' if s['last'] else '0'}[key]
    return f


G_AW = [['AW subordinate side',
         ('i_axi_awvalid', 's_awvalid', 'bit'), ('o_axi_awready', 's_awready', 'bit'),
         ('i_axi_awaddr', None, 'd', f_aw('s', 'addr')), ('i_axi_awlen', None, 'd', f_aw('s', 'len')),
         ('i_axi_awsize', None, 'd', f_aw('s', 'size')), ('i_axi_awburst', None, 'd', f_aw('s', 'burst')),
         ('i_axi_awcache', None, 'd', f_aw('s', 'cache'))],
        ['AW manager side',
         ('o_axi_awvalid', 'm_awvalid', 'bit'), ('i_axi_awready', 'm_awready', 'bit'),
         ('o_axi_awaddr', None, 'd', f_aw('m', 'addr')), ('o_axi_awlen', None, 'd', f_aw('m', 'len')),
         ('o_axi_awsize', None, 'd', f_aw('m', 'size')), ('o_axi_awburst', None, 'd', f_aw('m', 'burst'))]]
G_W = [['W subordinate side (32 bit)',
        ('i_axi_wvalid', 's_wvalid', 'bit'), ('o_axi_wready', 's_wready', 'bit'),
        ('i_axi_wdata', None, 'd', f_sw('data')), ('i_axi_wstrb', None, 'd', f_sw('strb')), ('i_axi_wlast', None, 'd', f_sw('last'))],
       ['W manager side (128 bit)',
        ('o_axi_wvalid', 'm_wvalid', 'bit'), ('i_axi_wready', 'm_wready', 'bit'),
        ('o_axi_wdata', None, 'd', f_mw('data')), ('o_axi_wstrb', None, 'd', f_mw('strb')), ('o_axi_wlast', None, 'd', f_mw('last'))]]
G_B = [['B manager side',
        ('i_axi_bvalid', 'm_bvalid', 'bit'), ('o_axi_bready', 'm_bready', 'bit'), ('i_axi_bresp', None, 'd', f_b('m'))],
       ['B subordinate side',
        ('o_axi_bvalid', 's_bvalid', 'bit'), ('i_axi_bready', 's_bready', 'bit'), ('o_axi_bresp', None, 'd', f_b('s'))]]
G_AR = [['AR subordinate side',
         ('i_axi_arvalid', 's_arvalid', 'bit'), ('o_axi_arready', 's_arready', 'bit'),
         ('i_axi_araddr', None, 'd', f_ar('s', 'addr')), ('i_axi_arlen', None, 'd', f_ar('s', 'len')),
         ('i_axi_arsize', None, 'd', f_ar('s', 'size')), ('i_axi_arburst', None, 'd', f_ar('s', 'burst')),
         ('i_axi_arcache', None, 'd', f_ar('s', 'cache'))],
        ['AR manager side',
         ('o_axi_arvalid', 'm_arvalid', 'bit'), ('i_axi_arready', 'm_arready', 'bit'),
         ('o_axi_araddr', None, 'd', f_ar('m', 'addr')), ('o_axi_arlen', None, 'd', f_ar('m', 'len')),
         ('o_axi_arsize', None, 'd', f_ar('m', 'size')), ('o_axi_arburst', None, 'd', f_ar('m', 'burst'))]]
G_R = [['R manager side (128 bit)',
        ('i_axi_rvalid', 'm_rvalid', 'bit'), ('o_axi_rready', 'm_rready', 'bit'),
        ('i_axi_rdata', None, 'd', f_mr('data')), ('i_axi_rresp', None, 'd', f_mr('resp')), ('i_axi_rlast', None, 'd', f_mr('last'))],
       ['R subordinate side (32 bit)',
        ('o_axi_rvalid', 's_rvalid', 'bit'), ('i_axi_rready', 's_rready', 'bit'),
        ('o_axi_rdata', None, 'd', f_sr('data')), ('o_axi_rresp', None, 'd', f_sr('resp')), ('o_axi_rlast', None, 'd', f_sr('last'))]]


def fix_names(groups):
    """AR/R groups use their own names; nothing to rename, kept for clarity."""
    return groups


def mr(cycle, slots, resp=0, last=False):
    return dict(cycle=cycle, slots=slots, resp=resp, last=last)


def save(wfid, name, recs, groups, title):
    j = build(recs, groups, title)
    p = os.path.join(OUT, '%s.json' % name)
    json.dump(j, open(p, 'w'), indent=1)
    # event log for the specification text
    ev = []
    for r in recs:
        c = r['cycle']
        ev.append((c, {k: r[k] for k in ('s_awvalid', 's_awready', 'm_awvalid', 'm_awready', 's_wvalid', 's_wready', 'm_wvalid', 'm_wready',
                                       's_bvalid', 's_bready', 's_arvalid', 's_arready', 'm_rvalid', 'm_rready', 's_rvalid', 's_rready')}))
    return p, ev


def hs_log(recs):
    out = []
    for r in recs:
        c = r['cycle']
        parts = []
        for nm, v, rd in (('S-AW', 's_awvalid', 's_awready'), ('M-AW', 'm_awvalid', 'm_awready'), ('S-W', 's_wvalid', 's_wready'),
                          ('M-W', 'm_wvalid', 'm_wready'), ('M-B', 'm_bvalid', 'm_bready'), ('S-B', 's_bvalid', 's_bready'),
                          ('S-AR', 's_arvalid', 's_arready'), ('M-AR', 'm_arvalid', 'm_arready'), ('M-R', 'm_rvalid', 'm_rready'),
                          ('S-R', 's_rvalid', 's_rready')):
            if r[v] and r[rd]:
                parts.append(nm)
        if parts:
            out.append('%d: %s' % (c, ' '.join(parts)))
    return out


plan = {}


def wf(wfid, name, title, recs, groups):
    p, ev = save(wfid, name, recs, groups, title)
    plan[wfid] = (name, p)
    print('==', wfid, name, 'cycles', len(recs))
    for l in hs_log(recs):
        print('  ', l)


GW = G_AW + G_W + G_B
GR = G_AR + G_R

G_AW3 = [['AW subordinate side',
          ('i_axi_awvalid', 's_awvalid', 'bit'), ('o_axi_awready', 's_awready', 'bit'),
          ('i_axi_awid', None, 'd', f_aw('s', 'id')), ('i_axi_awaddr', None, 'd', f_aw('s', 'addr')), ('i_axi_awlen', None, 'd', f_aw('s', 'len'))],
         ['AW manager side',
          ('o_axi_awvalid', 'm_awvalid', 'bit'), ('i_axi_awready', 'm_awready', 'bit'),
          ('o_axi_awid', None, 'd', f_aw('m', 'id')), ('o_axi_awaddr', None, 'd', f_aw('m', 'addr')), ('o_axi_awlen', None, 'd', f_aw('m', 'len')),
          ('o_axi_awsize', None, 'd', f_aw('m', 'size'))]]
G_W3 = [['W subordinate side (32 bit)',
         ('i_axi_wvalid', 's_wvalid', 'bit'), ('o_axi_wready', 's_wready', 'bit'),
         ('i_axi_wid', None, 'd', f_sw('wid')), ('i_axi_wdata', None, 'd', f_sw('data')), ('i_axi_wlast', None, 'd', f_sw('last'))],
        ['W manager side (128 bit)',
         ('o_axi_wvalid', 'm_wvalid', 'bit'), ('i_axi_wready', 'm_wready', 'bit'),
         ('o_axi_wid', None, 'd', f_mw('wid')), ('o_axi_wdata', None, 'd', f_mw('data')), ('o_axi_wstrb', None, 'd', f_mw('strb')),
         ('o_axi_wlast', None, 'd', f_mw('last'))]]

# WF-001 write INCR pack, aligned
recs = run(16, aws=[aw(1, 0x1000, 7)], ws=wbeats(range(2, 10), ['a%d' % k for k in range(8)]))
wf('WF-001', 'upsizer_wf001_write_incr_pack', 'WF-001 write INCR packed, S 32 bit to M 128 bit, 8 beats, aligned start', recs, GW)

# WF-002 write INCR pack unaligned start, partial words
recs = run(14, aws=[aw(1, 0x1008, 4)], ws=wbeats(range(2, 7), ['b%d' % k for k in range(5)]))
wf('WF-002', 'upsizer_wf002_write_incr_unaligned', 'WF-002 write INCR packed, start 0x1008, partial first and last word', recs, GW)

# WF-003 write lane steering (Non-modifiable)
recs = run(12, aws=[aw(1, 0x2004, 3, cache=0)], ws=wbeats(range(2, 6), ['c%d' % k for k in range(4)]))
wf('WF-003', 'upsizer_wf003_write_lane_steering', 'WF-003 write lane steering, Non-modifiable (AWCACHE[1] = 0), one S beat per M beat', recs, GW)

# WF-004 write with backpressure
wc = [2, 3, 4, 5, 6, 7] + list(range(10, 20))
recs = run(32, aws=[aw(1, 0x1000, 15)], ws=wbeats(wc, ['p%d' % k for k in range(16)]),
           m_awready_low=lo([(1, 3)]), m_wready_low=lo([(6, 15)]))
wf('WF-004', 'upsizer_wf004_write_backpressure', 'WF-004 write with AWREADY and WREADY low on the manager side and a gap in WVALID', recs, GW)

# WF-005 W before AW
recs = run(16, aws=[aw(4, 0x1000, 3)], ws=wbeats(range(1, 5), ['d%d' % k for k in range(4)]))
wf('WF-005', 'upsizer_wf005_write_w_before_aw', 'WF-005 W data offered before the AW: WREADY stays low until the AW is accepted', recs, GW)

# WF-006 write WRAP
recs = run(26, aws=[aw(1, 0x3010, 7, burst=WRAP), aw(3, 0x3014, 1, burst=WRAP)],
           ws=wbeats(range(2, 10), ['e%d' % k for k in range(8)]) + wbeats(range(10, 12), ['f0', 'f1']))
wf('WF-006', 'upsizer_wf006_write_wrap', 'WF-006 write WRAP packed: container 32 bytes aligned to M, then container 8 bytes inside one M word', recs, GW)

# WF-007 read INCR pack
recs = run(18, ars=[aw(1, 0x1000, 7)],
           mrs=[mr(4, ['r0', 'r1', 'r2', 'r3']), mr(5, ['r4', 'r5', 'r6', 'r7'], 0, True)])
for r in recs:
    pass
wf('WF-007', 'upsizer_wf007_read_incr_pack', 'WF-007 read INCR packed: each M beat is split into 4 S beats', recs, G_AR + G_R)

# WF-008 read lane steering
recs = run(14, ars=[aw(1, 0x2004, 3, cache=0)],
           mrs=[mr(4, ['--', 'c0', '--', '--']), mr(5, ['--', '--', 'c1', '--']), mr(6, ['--', '--', '--', 'c2']), mr(7, ['c3', '--', '--', '--'], 0, True)])
wf('WF-008', 'upsizer_wf008_read_lane_steering', 'WF-008 read lane steering, Non-modifiable: one M beat gives one S beat', recs, GR)

# WF-009 read WRAP
recs = run(24, ars=[aw(1, 0x3010, 7, burst=WRAP), aw(3, 0x3014, 1, burst=WRAP)],
           mrs=[mr(4, ['g0', 'g1', 'g2', 'g3']), mr(5, ['g4', 'g5', 'g6', 'g7'], 0, True), mr(12, ['h1', 'h0', '--', '--'], 0, True)])
wf('WF-009', 'upsizer_wf009_read_wrap', 'WF-009 read WRAP packed: 32-byte container (2 M beats) then 8-byte container (1 M beat)', recs, GR)

# WF-010 error responses: write B and read R
recsw = run(22, aws=[aw(1, 0x1000, 3)], ws=wbeats(range(2, 6), ['k%d' % k for k in range(4)]), b_resps=(2,),
            ars=[aw(1, 0x1100, 7)], mrs=[mr(5, ['q0', 'q1', 'q2', 'q3']), mr(6, ['q4', 'q5', 'q6', 'q7'], 2, True)])
wf('WF-010', 'upsizer_wf010_error_response', 'WF-010 error responses: BRESP SLVERR, and RRESP SLVERR copied to the 4 S beats of one M beat', recsw, GW + GR)

# WF-011 outstanding queue full (depth 2)
recs = run(30, depth=2,
           aws=[aw(1, 0x1000, 1), aw(2, 0x1010, 1), aw(3, 0x1020, 1)],
           ws=wbeats([8, 9], ['x0', 'x1']) + wbeats([10, 11], ['y0', 'y1']) + wbeats([12, 13], ['z0', 'z1']),
           ars=[aw(1, 0x1000, 1), aw(2, 0x1010, 1), aw(3, 0x1020, 1)],
           mrs=[mr(10, ['u0', 'u1', '--', '--'], 0, True), mr(11, ['v0', 'v1', '--', '--'], 0, True), mr(12, ['w0', 'w1', '--', '--'], 0, True)])
wf('WF-011', 'upsizer_wf011_queue_full', 'WF-011 outstanding queue of depth 2 full: the third AW and the third AR wait', recs, G_AW + G_W + G_AR + G_R)

# WF-012 reset
a = run(5, aws=[aw(1, 0x1000, 7)], ws=wbeats(range(2, 10), ['m%d' % k for k in range(8)]))
b = run(16, aws=[aw(7, 0x1000, 3)], ws=wbeats(range(8, 12), ['n%d' % k for k in range(4)]), start=7)
recs = a + [reset_rec(5), reset_rec(6)] + b
wf('WF-012', 'upsizer_wf012_reset', 'WF-012 reset during a write burst, then a new burst after the release', recs, GW)

# WF-013 AXI3 write data interleave (depth 2)
order = []
for k in range(8):
    order.append(('a%d' % k, 1))
    order.append(('b%d' % k, 2))
ws = []
for k, (lab, wid) in enumerate(order):
    ws.append(dict(cycle=2 + k, label=lab, strb='F', last=(lab in ('a7', 'b7')), wid=wid))
ws += [dict(cycle=18, label='c0', strb='F', last=False, wid=3), dict(cycle=19, label='c1', strb='F', last=True, wid=3)]
recs = run(34, il=2, depth=4,
           aws=[aw(1, 0x1000, 7, id=1), aw(2, 0x1100, 7, id=2), aw(20, 0x1200, 1, id=3)], ws=ws)
wf('WF-013', 'upsizer_wf013_axi3_write_interleave', 'WF-013 AXI3 write data interleave, depth 2: WID 1 and 2 alternate beat by beat, WID 3 waits for its AW', recs, G_AW3 + G_W3 + G_B)

json.dump({k: v[0] for k, v in plan.items()}, open(os.path.join(OUT, 'plan.json'), 'w'), indent=1)
