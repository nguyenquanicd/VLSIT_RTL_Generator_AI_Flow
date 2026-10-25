"""Draw the software reset waveforms and event tables from srst_<n>.vcd.

Usage: python gen_srst.py <dir_with_vcd> <out_dir>
Writes srst_*.svg and srst_tables.md into out_dir.
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from wavelib import Vcd, render

SRC, OUT = sys.argv[1], sys.argv[2]
os.makedirs(OUT, exist_ok=True)
WST = {0: 'RUN', 1: 'REQ', 2: 'PTR', 3: 'HOLD', 4: 'REL'}
RST = {0: 'RUN', 1: 'RST', 2: 'ACK'}

def rows(hw_resets=False):
    r = [('WRITE DOMAIN (i_clk_wr, period 10 ns)', None, None, None),
         ('i_clk_wr', 'clk_wr', 'clk', 'w')]
    if hw_resets:
        r.append(('i_rst_n_wr (hardware)', 'rst_n_wr', 'bit', 'w'))
    r += [('i_rst_n_sw (active-low)', 'i_rst_n_sw', 'bit', 'w'),
          ('o_sw_rst_busy', 'o_sw_rst_busy', 'bit', 'w'),
          ('write reset FSM', 'wst', 'enum', 'w', WST),
          ('write blocked (wr_blk)', 'wr_blk', 'bit', 'w'),
          ('i_wr_en', 'i_wr_en', 'bit', 'w'),
          ('write accepted', 'wr_accept', 'bit', 'w'),
          ('o_full', 'o_full', 'bit', 'w'),
          ('o_full_thr (thr = 3)', 'o_full_thr', 'bit', 'w'),
          ('o_overflow', 'o_overflow', 'bit', 'w'),
          ('write pointer', 'wbin', 'dec', 'w'),
          ('req_wr (to read domain)', 'req_wr', 'bit', 'w'),
          ('ack (synchronized in wr)', 'ack_s', 'bit', 'w'),
          ('rd gray (synchronized in wr)', 'rgray_s', 'bin', 'w'),
          ('READ DOMAIN (i_clk_rd, period 14 ns)', None, None, None),
          ('i_clk_rd', 'clk_rd', 'clk', 'r')]
    if hw_resets:
        r.append(('i_rst_n_rd (hardware)', 'rst_n_rd', 'bit', 'r'))
    r += [('req (synchronized in rd)', 'req_s', 'bit', 'r'),
          ('read reset FSM', 'rst_st', 'enum', 'r', RST),
          ('read blocked (rd_blk)', 'rd_blk', 'bit', 'r'),
          ('i_rd_en', 'i_rd_en', 'bit', 'r'),
          ('read accepted', 'rd_accept', 'bit', 'r'),
          ('o_empty', 'o_empty', 'bit', 'r'),
          ('o_empty_thr (thr = 1)', 'o_empty_thr', 'bit', 'r'),
          ('o_underflow', 'o_underflow', 'bit', 'r'),
          ('read pointer', 'rbin', 'dec', 'r'),
          ('ack_rd (to write domain)', 'ack_rd', 'bit', 'r'),
          ('wr gray (synchronized in rd)', 'wgray_s', 'bin', 'r')]
    return r

def load(n):
    v = Vcd(os.path.join(SRC, f'srst_{n}.vcd')); v.set_tick(0.1); return v

def fig(v, ev, t0, t1, name, title, hw=False, marks=None):
    scale = (1300 - 168 - 20) / (t1 - t0)
    render(v, rows(hw), t0, t1, scale, os.path.join(OUT, name), title, {k: x[0] for k, x in ev.items()}, marks or list(ev),
           note='numbers = events of the table next to the figure; blue = write clock domain, orange = read clock domain')

md = []
def table(tag, ev):
    md.append(tag)
    md.append('| No. | Time (ns) | Event |')
    md.append('|---:|---:|---|')
    for k in sorted(ev):
        md.append(f'| {k} | {ev[k][0]:.1f} | {ev[k][1]} |')
    md.append('')

# ------------------------------------------------------------------------- scenario 1: main
v = load(1)
t1 = v.change('i_rst_n_sw', 0, 100)
e = {}
e[1] = v.change('i_rst_n_sw', 0, 100)
e[2] = v.change('req_wr', 1, e[1] - 1)
e[3] = v.change('req_s', 1, e[1])
e[4] = v.change('rst_st', 1, e[1])
e[5] = v.change('ack_rd', 1, e[1])
e[6] = v.change('ack_s', 1, e[1])
e[7] = v.change('wst', 2, e[1])
e[8] = v.change('i_rst_n_sw', 1, e[1])
e[9] = v.change('req_wr', 0, e[1])
e[10] = v.change('req_s', 0, e[3])
e[11] = v.change('rst_st', 0, e[4])
e[12] = v.change('ack_s', 0, e[6])
e[13] = v.change('wst', 0, e[7])
e[14] = v.change('wr_accept', 1, e[13])
e[15] = v.change('o_empty', 0, e[13])
D1 = {
 1: 'Software asserts `i_rst_n_sw` = 0 (active-low request). In the same cycle (zero latency) writes are blocked: `i_wr_en` = 1 is not accepted, `o_full` = 1, and `o_full_thr` takes the value of an empty FIFO (0).',
 2: 'Write FSM leaves RUN: `req_wr` = 1 and `o_sw_rst_busy` = 1. Writes stay blocked.',
 3: 'The request is visible in the read domain (after the synchronizer): reads are blocked, `o_empty` = 1 and `o_empty_thr` = 1 in the same cycle. Reads accepted before this event were normal reads of pre-reset words.',
 4: 'Read FSM in RST: the read pointer is reset to 0.',
 5: '`ack_rd` = 1: the read side is reset and acknowledges.',
 6: 'The acknowledge is visible in the write domain.',
 7: 'Write FSM in PTR: the write pointer is reset to 0. The FSM then waits in HOLD for `i_rst_n_sw` = 1.',
 8: 'Software releases `i_rst_n_sw` (back to 1). Writes stay blocked (FSM in HOLD, then REL).',
 9: 'Write FSM: `req_wr` = 0 (release request).',
 10: 'The request = 0 is visible in the read domain.',
 11: 'Read FSM returns to RUN: **read released first**. `ack_rd` = 0, flags live (`o_empty` = 1 because both pointers are 0).',
 12: 'The acknowledge = 0 is visible in the write domain.',
 13: 'Write FSM returns to RUN: **write released last**. Writes unblocked, `o_full` = 0, `o_full_thr` normal, `o_sw_rst_busy` = 0.',
 14: 'The first write after the reset is accepted (0xA5).',
 15: 'The new write pointer has crossed to the read domain: `o_empty` falls.',
}
ev1 = {k: (e[k], D1[k]) for k in e}
tend = v.tmax()
fig(v, ev1, e[1] - 60, tend + 5, 'srst_1_overview.svg', 'Software reset 1 - overview: three words in the FIFO, producer and consumer keep requesting')
fig(v, ev1, e[1] - 25, e[7] + 25, 'srst_1a_request_and_read_reset.svg', 'Software reset 1a - request, read-side reset, acknowledge, write-side reset', marks=[1, 2, 3, 4, 5, 6, 7])
fig(v, ev1, e[8] - 25, e[13] + 30, 'srst_1b_release_order.svg', 'Software reset 1b - release order: read side first, write side last', marks=[8, 9, 10, 11, 12, 13])
fig(v, ev1, e[13] - 40, e[15] + 45, 'srst_1c_flag_recovery.svg', 'Software reset 1c - flags return to the FIFO logic after the release', marks=[13, 14, 15])
table('SRST_1', ev1)

# ------------------------------------------------------------------------- scenario 2: full FIFO, one-cycle pulse
v = load(2)
e = {}
e[1] = v.change('o_overflow', 1, 100)
e[2] = v.change('i_rst_n_sw', 0, 100)
e[3] = v.change('req_wr', 1, e[2] - 1)
e[4] = v.change('i_rst_n_sw', 1, e[2])
e[5] = v.change('req_s', 1, e[2])
e[6] = v.change('ack_rd', 1, e[2])
e[7] = v.change('wst', 2, e[2])
e[8] = v.change('req_wr', 0, e[4])
e[9] = v.change('rst_st', 0, v.change('rst_st', 1, e[2]))
e[10] = v.change('wst', 0, e[7])
e[11] = v.change('wr_accept', 1, e[10])
D2 = {
 1: 'The FIFO is full and the producer keeps writing: `o_overflow` pulses (normal overflow, registered one cycle after the rejected request).',
 2: '`i_rst_n_sw` = 0 for **one write-clock cycle** only. Writes are blocked at once, `o_full` stays 1, and no overflow pulse follows although `i_wr_en` = 1 (the blocked access is not an error).',
 3: 'Write FSM takes the request at the first write edge: `req_wr` = 1, `o_sw_rst_busy` = 1.',
 4: '`i_rst_n_sw` is back to 1 after one cycle. The request is already latched, so the sequence continues.',
 5: 'The request is visible in the read domain: reads blocked, `o_empty` = 1.',
 6: 'Read pointer reset, `ack_rd` = 1.',
 7: 'Write pointer reset (PTR). The input is already 1, so the FSM does not wait in HOLD.',
 8: 'Write FSM: `req_wr` = 0.',
 9: 'Read side released first.',
 10: 'Write side released last: `o_full` falls, writes unblocked.',
 11: 'The first write after the reset is accepted.',
}
ev2 = {k: (e[k], D2[k]) for k in e}
fig(v, ev2, e[1] - 25, v.tmax() + 5, 'srst_2_short_pulse_full_fifo.svg', 'Software reset 2 - one-cycle pulse on a full FIFO (the sequence completes)')
table('SRST_2', ev2)

# ------------------------------------------------------------------------- scenario 3: re-assertion in REL
v = load(3)
e = {}
e[1] = v.change('i_rst_n_sw', 0, 100)
e[2] = v.change('i_rst_n_sw', 1, e[1])
e[3] = v.change('wst', 4, e[1])
e[4] = v.change('i_rst_n_sw', 0, e[2])
e[5] = v.change('rst_st', 0, v.change('rst_st', 1, e[1]))
e[6] = v.change('wst', 0, e[3])
e[7] = v.change('req_wr', 1, e[3])
e[8] = v.change('i_rst_n_sw', 1, e[4])
e[9] = v.change('rst_st', 0, v.change('rst_st', 1, e[5]))
e[10] = v.change('wst', 0, v.change('wst', 2, e[7]))
D3 = {
 1: 'First software reset: `i_rst_n_sw` = 0, writes blocked, handshake starts.',
 2: '`i_rst_n_sw` back to 1 (after HOLD): the write FSM goes to REL and drops the request.',
 3: 'Write FSM in REL, waiting for the acknowledge to fall.',
 4: '`i_rst_n_sw` = 0 **again while the write FSM is in REL**. Writes stay blocked (the block includes the input); `i_wr_en` = 1 is not accepted.',
 5: 'First sequence: the read side is released.',
 6: 'First sequence: the write FSM reaches RUN. The input is still 0, so no write is accepted in this cycle either (`wr_blk` includes the input).',
 7: 'Second sequence starts at once: `req_wr` = 1.',
 8: '`i_rst_n_sw` back to 1 (in HOLD of the second sequence).',
 9: 'Second sequence: the read side is released again after its own reset.',
 10: 'Second sequence: the write side is released last. Writes are unblocked.',
}
ev3 = {k: (e[k], D3[k]) for k in e}
fig(v, ev3, e[1] - 25, e[10] + 40, 'srst_3_reassert_in_rel.svg', 'Software reset 3 - i_rst_n_sw asserted again while the write FSM is in REL (a new sequence follows)')
table('SRST_3', ev3)

# ------------------------------------------------------------------------- scenario 4: hardware reset in the sequence
v = load(4)
e = {}
e[1] = v.change('i_rst_n_sw', 0, 100)
e[2] = v.change('req_wr', 1, e[1] - 1)
e[3] = v.change('ack_rd', 1, e[1])
e[4] = v.change('wst', 3, e[1])
e[5] = v.change('rst_n_wr', 0, e[1])
e[6] = v.change('rst_n_wr', 1, e[5])
e[7] = v.change('rst_n_rd', 1, e[5])
e[8] = v.change('wr_accept', 1, e[7])
e[9] = v.change('o_empty', 0, e[7])
D4 = {
 1: 'Software reset starts: `i_rst_n_sw` = 0.',
 2: '`req_wr` = 1.',
 3: 'The read side is reset and `ack_rd` = 1.',
 4: 'The write pointer is reset; the write FSM waits in HOLD.',
 5: 'Hardware reset of both domains asserted (`i_rst_n_wr` = 0, `i_rst_n_rd` = 0) in the middle of the sequence; the testbench also releases `i_rst_n_sw`. Both FSMs, both pointers and both synchronizers go to their reset values at once (hardware reset priority).',
 6: '`i_rst_n_wr` released. The write FSM is in RUN and the FIFO is empty.',
 7: '`i_rst_n_rd` released (later than the write side). The read FSM is in RUN and `o_empty` = 1.',
 8: 'The first write after the reset is accepted (0xA5) once both domains are out of reset (ASM-005).',
 9: '`o_empty` falls after the write pointer has crossed to the read domain.',
}
ev4 = {k: (e[k], D4[k]) for k in e}
fig(v, ev4, e[1] - 25, v.tmax() + 5, 'srst_4_hardware_reset_during_sequence.svg', 'Software reset 4 - hardware reset of both domains during the sequence (clean restart)', hw=True)
table('SRST_4', ev4)

# ------------------------------------------------------------------------- o_sw_rst_busy in detail
def rows_busy(read_side=True):
    r = [('WRITE DOMAIN (i_clk_wr, period 10 ns)', None, None, None),
         ('i_clk_wr', 'clk_wr', 'clk', 'w'),
         ('i_rst_n_sw (active-low)', 'i_rst_n_sw', 'bit', 'w'),
         ('write reset FSM', 'wst', 'enum', 'w', WST),
         ('write blocked (wr_blk)', 'wr_blk', 'bit', 'w'),
         ('o_sw_rst_busy (flip-flop)', 'o_sw_rst_busy', 'bit', 's'),
         ('req_wr (to read domain)', 'req_wr', 'bit', 'w'),
         ('ack (synchronized in wr)', 'ack_s', 'bit', 'w'),
         ('i_wr_en', 'i_wr_en', 'bit', 'w'),
         ('write accepted', 'wr_accept', 'bit', 'w'),
         ('o_full', 'o_full', 'bit', 'w')]
    if read_side:
        r += [('READ DOMAIN (i_clk_rd, period 14 ns)', None, None, None),
              ('i_clk_rd', 'clk_rd', 'clk', 'r'),
              ('req (synchronized in rd)', 'req_s', 'bit', 'r'),
              ('read reset FSM', 'rst_st', 'enum', 'r', RST),
              ('ack_rd (to write domain)', 'ack_rd', 'bit', 'r')]
    return r

def fig_busy(v, evb, t0, t1, name, title, read_side=True):
    scale = (1300 - 168 - 20) / (t1 - t0)
    render(v, rows_busy(read_side), t0, t1, scale, os.path.join(OUT, name), title, {k: x[0] for k, x in evb.items()}, sorted(evb),
           note='numbers = events of the table next to the figure; violet = o_sw_rst_busy')

v1 = load(1)
b1 = {
 1: (ev1[1][0], '`i_rst_n_sw` falls. `wr_blk` = 1 and `o_full` = 1 at once (combinational). `o_sw_rst_busy` is still 0: it is a flip-flop and changes only at the next write-clock edge.'),
 2: (ev1[2][0], 'The first write-clock edge after the fall: the write FSM goes RUN to REQ, and `req_wr` and `o_sw_rst_busy` rise **at this same edge** (busy is one write-clock cycle behind the block).'),
 3: (ev1[7][0], 'The acknowledge was seen, the write FSM goes REQ to PTR and resets the write pointer. Busy stays 1 (state not RUN).'),
 4: (ev1[8][0], '`i_rst_n_sw` back to 1. The write FSM is in HOLD and goes to REL at the next edge. Busy stays 1: it follows the FSM state, not the input.'),
 5: (ev1[11][0], 'The read FSM returns to RUN (read side released). Busy stays 1: it describes the write side, which is released last.'),
 6: (ev1[13][0], 'The write FSM returns to RUN. `o_sw_rst_busy` falls at this edge, together with `wr_blk` and `o_full`: writes are possible again.'),
}
fig_busy(v1, b1, ev1[1][0] - 30, ev1[13][0] + 45, 'srst_5_busy_vs_state.svg', 'o_sw_rst_busy follows the write reset FSM (scenario 1)')
table('SRST_BUSY_1', b1)

v3 = load(3)
b3 = {
 1: (ev3[4][0], '`i_rst_n_sw` = 0 again while the write FSM is in REL (first sequence not finished). Busy is still 1.'),
 2: (ev3[6][0], 'The write FSM returns to RUN: `o_sw_rst_busy` falls. `wr_blk` stays 1 because the input is still 0.'),
 3: (ev3[7][0], 'One write-clock cycle later the FSM sees the input at 0 in RUN and goes to REQ: `o_sw_rst_busy` rises again. Writes were blocked during the whole gap.'),
}
fig_busy(v3, b3, ev3[6][0] - 70, ev3[7][0] + 70, 'srst_6_busy_between_sequences.svg', 'o_sw_rst_busy between two sequences (scenario 3, one-cycle gap)', read_side=False)
table('SRST_BUSY_3', b3)

# measured intervals of o_sw_rst_busy and of the write block, from the four simulations
def edges(v, sig):
    out, prev = [], None
    for a, x in v.series(sig):
        if prev is not None and prev != x and x in '01': out.append((a, int(x)))
        prev = x
    return out
md.append('SRST_BUSY_TABLE')
md.append('| Scenario | `i_rst_n_sw` falls (ns) | `wr_blk` rises (ns) | `o_sw_rst_busy` rises (ns) | `o_sw_rst_busy` falls (ns) | `wr_blk` falls (ns) | Busy high (write-clock cycles) |')
md.append('|---|---:|---:|---:|---:|---:|---:|')
for n in (1, 2, 3, 4):
    vv = load(n)
    f_in = [a for a, x in edges(vv, 'i_rst_n_sw') if x == 0]
    b_up = [a for a, x in edges(vv, 'o_sw_rst_busy') if x == 1]
    b_dn = [a for a, x in edges(vv, 'o_sw_rst_busy') if x == 0]
    w_up = [a for a, x in edges(vv, 'wr_blk') if x == 1]
    w_dn = [a for a, x in edges(vv, 'wr_blk') if x == 0]
    for k, bu in enumerate(b_up):
        bd = next((t for t in b_dn if t > bu), None)
        fi = max([t for t in f_in if t <= bu], default=None)
        wu = max([t for t in w_up if t <= bu], default=None)
        wd = next((t for t in w_dn if bd is not None and t >= bd), None)
        cyc = f'{(bd - bu) / 10:.0f}' if bd is not None else '-'
        md.append(f'| {n}{"" if len(b_up) == 1 else "." + str(k + 1)} | {fi:.1f} | {wu:.1f} | {bu:.1f} | {bd:.1f} | {wd:.1f} | {cyc} |')
md.append('')

# synchronism of the interface signals: every change must happen at a rising edge of its clock
md.append('SRST_SYNC')
md.append('| Scenario | Write domain signals checked (clock `i_clk_wr`) | Changes outside a rising edge | Read domain signals checked (clock `i_clk_rd`) | Changes outside a rising edge |')
md.append('|---|---|---:|---|---:|')
for n in (1, 2, 3, 4):
    vv = load(n)
    def outside(clk, sigs):
        edges = [a for a, x in vv.series(clk) if x == '1']
        return sum(1 for sg in sigs for a, x in vv.series(sg) if a > 1 and not any(abs(a - ed) < 0.15 for ed in edges))
    wsig = ['i_wr_en', 'i_wr_data', 'i_rst_n_sw', 'rst_n_wr']
    rsig = ['i_rd_en', 'rst_n_rd']
    md.append(f"| {n} | {', '.join('`%s`' % x for x in wsig)} | {outside('clk_wr', wsig)} | {', '.join('`%s`' % x for x in rsig)} | {outside('clk_rd', rsig)} |")
md.append('')

open(os.path.join(OUT, 'srst_tables.md'), 'w', encoding='utf-8').write('\n'.join(md))
print('figures and srst_tables.md written to', OUT)
