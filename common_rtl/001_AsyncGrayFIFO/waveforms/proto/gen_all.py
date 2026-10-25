import sys, os, re, subprocess
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from wavelib import Vcd, render, num

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = sys.argv[1]
os.makedirs(OUT, exist_ok=True)
md = []

# =========================== FIFO write / read, from the real RTL (tb_fifo_wave.sv) ===========================
def fifo_rows(macro, rdper=14):
    rows = [
        ('WRITE DOMAIN (i_clk_wr, period 10 ns)', None, None, None),
        ('i_clk_wr', 'clk_wr', 'clk', 'w'),
        ('i_wr_en', 'i_wr_en', 'bit', 'w'),
        ('i_wr_data', 'i_wr_data', 'hex', 'w'),
        ('write accept (sampled at the edge)', 'wr_accept', 'bit', 'w'),
        ('o_full', 'o_full', 'bit', 'w'),
        ('o_full_thr', 'o_full_thr', 'bit', 'w'),
        ('o_overflow', 'o_overflow', 'bit', 'w'),
        ('write pointer (bin)', 'wbin', 'dec', 'w'),
        ('write pointer (gray)', 'wgray', 'bin', 'w'),
        ('rd gray, synchronized', 'rg_s', 'bin', 'w'),
    ]
    if macro:
        rows += [('SRAM MACRO (VLSIT_CELL_SRAM_1W1R)', None, None, None),
                 ('WEB (active low)', 'WEB', 'bit', 'm'), ('AW', 'AW', 'dec', 'm'), ('DW', 'DWb', 'hex', 'm'),
                 ('REB (tied low)', 'REB', 'bit', 'm'), ('AR (next rd pointer)', 'AR', 'dec', 'm'), ('QR', 'QR', 'hex', 'm')]
    else:
        rows += [('RTL ARRAY (m_vlsit_afifo_mem)', None, None, None),
                 ('i_wr_en (array)', 'mem_wr_en', 'bit', 'm'), ('i_wr_addr', 'mem_wr_addr', 'dec', 'm'), ('i_wr_data (array)', 'mem_wr_data', 'hex', 'm'),
                 ('i_rd_addr (next rd pointer)', 'mem_rd_addr', 'dec', 'm'), ('o_rd_data (read register)', 'rtl_q', 'hex', 'm')]
    rows += [
        ('READ DOMAIN (i_clk_rd, period %d ns)' % rdper, None, None, None),
        ('i_clk_rd', 'clk_rd', 'clk', 'r'),
        ('i_rd_en', 'i_rd_en', 'bit', 'r'),
        ('read accept (sampled at the edge)', 'rd_accept', 'bit', 'r'),
        ('o_rd_data', 'o_rd_data', 'hex', 'r'),
        ('o_empty', 'o_empty', 'bit', 'r'),
        ('o_empty_thr', 'o_empty_thr', 'bit', 'r'),
        ('o_underflow', 'o_underflow', 'bit', 'r'),
        ('read pointer (bin)', 'rbin', 'dec', 'r'),
        ('read pointer (gray)', 'rgray', 'bin', 'r'),
        ('wr gray, synchronized', 'wg_s', 'bin', 'r'),
    ]
    return rows

DESC = {
 1: 'Write of 0x11 accepted at write edge 105 (`i_wr_en` = 1 since edge 95, `o_full` = 0). The storage is written and the write Gray pointer register changes 000 -> 001 at the same edge.',
 2: '`o_rd_data` shows 0x11 (show-ahead). The storage is read in every read cycle with the address of the next read pointer (0), so it already holds the new word before the empty flag falls.',
 3: 'The write Gray pointer has crossed the 2-stage synchronizer (S = 2 read edges after the first capturing edge) and `o_empty` falls (combinational from the synchronized pointer). The data was already on `o_rd_data`.',
 4: 'The 4th word (0x44) is accepted at write edge 135 and fills the FIFO: `o_full` rises.',
 5: 'A 5th write (0x55) is sampled at write edge 145 while `o_full` = 1: it is dropped (pointer and storage unchanged) and `o_overflow` pulses for one write cycle, then `i_wr_en` falls at the same edge.',
 6: 'First read accepted at read edge 175 (`i_rd_en` = 1 since edge 161, `o_empty` = 0). `o_rd_data` moves to the next word 0x22 right after this edge, because the read module gave the address of the next read pointer.',
 7: 'The read Gray pointer has crossed to the write domain (2 write edges) and `o_full` falls.',
 8: 'The 4th read (edge 217) takes the last word: `o_empty` rises.',
 9: 'A 5th read is sampled at read edge 231 while `o_empty` = 1: the read pointer is unchanged and `o_underflow` pulses for one read cycle. `i_rd_en` falls at the same edge.',
 10: 'Write to an empty FIFO: a new word (0x66) is written to address 0 at write edge 255. The read pointer addresses the same entry and the storage is read at every read edge, but no read edge happened since the write, so `o_rd_data` still shows the old word 0x11.',
 11: 'The next read edge (259) captures the new word: `o_rd_data` = 0x66. `o_empty` is still 1.',
 12: 'The new write pointer has crossed to the read domain: `o_empty` falls.',
 13: 'The word 0x66 is read at read edge 301 and `o_empty` rises again.',
}

def next_edge(v, sig, t):
    prev = None
    for a, x in v.series(sig):
        if a > t + 1e-6 and x == "1" and prev == "0": return a
        prev = x
    return None

def edges_with(v, clk, sig):
    """rising edges of clk at which sig is 1 just before the edge (the value that the design samples)"""
    out, prev = [], None
    for a, x in v.series(clk):
        if x == '1' and prev == '0' and v.at(sig, a - 0.002) == '1':
            out.append(a)
        prev = x
    return out

def fifo_events(v):
    e = {}
    e[1] = next_edge(v, 'clk_wr', v.change('wr_accept', 1, 90))
    e[2] = v.change('o_rd_data', 0x11, 100)
    e[3] = v.change('o_empty', 0, 100)
    e[4] = v.change('o_full', 1, 100)
    e[5] = v.change('o_overflow', 1, 100)
    e[6] = next_edge(v, 'clk_rd', v.change('rd_accept', 1, 150))
    e[7] = v.change('o_full', 0, e[4])
    e[8] = v.change('o_empty', 1, e[3])
    e[9] = v.change('o_underflow', 1, 200)
    e[10] = next_edge(v, 'clk_wr', v.change('wr_accept', 1, e[8]))
    e[11] = v.change('o_rd_data', 0x66, e[10])
    e[12] = v.change('o_empty', 0, e[8])
    e[13] = next_edge(v, 'clk_rd', v.change('rd_accept', 1, e[12]))
    return e

def check_sync(v, clk, sigs, label, out):
    """every change of the interface signals must happen at a rising edge of the clock"""
    edges = [a for a, x in v.series(clk) if x == '1']
    bad = []
    for sg in sigs:
        for a, x in v.series(sg):
            if a > 50 and not any(abs(a - ed) < 0.0015 for ed in edges):
                bad.append((sg, a))
    out.append(f'Check of the {label}: {len(bad)} change(s) of {", ".join(sigs)} outside a rising edge of the clock' + ('' if not bad else ': ' + str(bad[:3])))

for macro, tag, name in ((0, '0', 'rtl_array'), (1, '1', 'sram_macro')):
    v = Vcd(os.path.join(HERE, f'afifo_{tag}.vcd')); v.set_tick(0.001)
    rows = fifo_rows(macro)
    ev = fifo_events(v)
    cfg = 'SRAM macro (CFG-MACRO)' if macro else 'RTL array (CFG-BASE)'
    render(v, rows, 95, 330, 4.5, os.path.join(OUT, f'fifo_{name}_1_overview.svg'),
           f'Async Gray FIFO write and read, {cfg} - depth 4, 8-bit data, 2-stage synchronizers', ev, list(range(1, 14)))
    render(v, rows, 98, 200, 11.0, os.path.join(OUT, f'fifo_{name}_2_write_to_empty_fall.svg'),
           f'{cfg} - first write, pointer crossing and the empty flag (zoom)', ev, [1, 2, 3, 4, 5, 6])
    render(v, rows, 236, 290, 20.0, os.path.join(OUT, f'fifo_{name}_3_read_during_write.svg'),
           f'{cfg} - write to an empty FIFO whose read port reads the same entry every cycle (zoom)', ev, [10, 11, 12])
    md.append(f'FIFO_{name}')
    md.append('| No. | Time (ns) | Event |')
    md.append('|---:|---:|---|')
    for k in range(1, 14):
        t = ev[k]
        md.append(f'| {k} | {t:.1f} | {DESC[k]} |' if t is not None else f'| {k} | - | {DESC[k]} |')
    md.append('')
    chk = []
    check_sync(v, 'clk_wr', ['i_wr_en', 'i_wr_data'], 'write interface inputs', chk)
    check_sync(v, 'clk_rd', ['i_rd_en'], 'read interface inputs', chk)
    md.extend(chk)
    md.append('')

# =========================== back-to-back write and read (scenario 2) ===========================
B2B_DESC = {
 1: 'First write accepted (`i_wr_en` was driven at the previous edge).',
 2: '`o_empty` falls: the first word has crossed the synchronizer (S = 2 read edges).',
 3: 'First read accepted. The consumer saw `o_empty` = 0, set `i_rd_en` = 1 at the next read edge, and keeps it: from here every read edge accepts one word.',
 4: 'Steady state, middle of the burst: one word is written and one word is read in every clock cycle, and `o_rd_data` steps through consecutive words.',
 5: 'Last write of the burst accepted (word 24). `i_wr_en` falls at this edge.',
 6: 'Last read accepted (word 24). `i_rd_en` falls at this edge.',
 7: '`o_empty` rises: the burst is fully read.',
}
for macro, tag, name in ((0, '0', 'rtl_array'), (1, '1', 'sram_macro')):
    v = Vcd(os.path.join(HERE, f'b2b_{tag}.vcd')); v.set_tick(0.001)
    wedges = edges_with(v, 'clk_wr', 'wr_accept')
    redges = edges_with(v, 'clk_rd', 'rd_accept')
    ev = {}
    ev[1] = wedges[0]
    ev[2] = v.change('o_empty', 0, ev[1])
    ev[3] = redges[0]
    ev[4] = redges[len(redges) // 2]
    ev[5] = wedges[-1]
    ev[6] = redges[-1]
    ev[7] = v.change('o_empty', 1, ev[3])
    rows = fifo_rows(macro, 10)
    rows[0] = ('WRITE DOMAIN (i_clk_wr, period 10 ns)', None, None, None)
    cfg = 'SRAM macro (CFG-MACRO)' if macro else 'RTL array (CFG-BASE)'
    render(v, rows, 35, ev[7] + 20, 3.9, os.path.join(OUT, f'fifo_{name}_4_back_to_back.svg'),
           f'Back-to-back write and read, {cfg} - depth 8, 8-bit data, one word per cycle on both sides', ev, list(range(1, 8)))
    render(v, rows, ev[4] - 45, ev[4] + 65, 11.0, os.path.join(OUT, f'fifo_{name}_5_back_to_back_zoom.svg'),
           f'{cfg} - back-to-back, steady state (zoom): a word is accepted at every write edge and every read edge', ev, [4])
    md.append(f'B2B_{name}')
    md.append('| No. | Time (ns) | Event |')
    md.append('|---:|---:|---|')
    for k in range(1, 8):
        md.append(f'| {k} | {ev[k]:.1f} | {B2B_DESC[k]} |')
    md.append('')
    nw, nr = len(wedges), len(redges)
    wgap = sum(1 for a, b in zip(wedges, wedges[1:]) if abs((b - a) - 10) > 0.01)
    rgap = sum(1 for a, b in zip(redges, redges[1:]) if abs((b - a) - 10) > 0.01)
    # o_empty low and o_full low between the first read and the last read
    t_emp = v.change('o_empty', 1, ev[3])
    empty_in_burst = 'yes' if (t_emp is not None and t_emp < ev[6] - 0.01) else 'no'
    full = [x for a, x in v.series('o_full') if a > 30]
    ovf = [x for a, x in v.series('o_overflow') if a > 30 and x == '1']
    unf = [x for a, x in v.series('o_underflow') if a > 30 and x == '1']
    md.append(f'Check of the run: {nw} write edges accepted, gaps between them: {wgap}; {nr} read edges accepted, gaps between them: {rgap}; '
              f'`o_empty` = 1 between the first and the last accepted read: {empty_in_burst}; '
              f'`o_full` = 1 at any time: {"yes" if "1" in full else "no"}; overflow pulses: {len(ovf)}; underflow pulses: {len(unf)}.')
    chk = []
    check_sync(v, 'clk_wr', ['i_wr_en', 'i_wr_data'], 'write interface inputs', chk)
    check_sync(v, 'clk_rd', ['i_rd_en'], 'read interface inputs', chk)
    md.extend(chk)
    md.append('')

# =========================== metastability model ===========================
log = open(os.path.join(HERE, 'meta_log.txt')).read().splitlines()
lat = [re.match(r'LAT S=(\d) t=([\d.]+) bit=(\d) new=(\d) extra=(\d) latency=(\d)', l) for l in log if l.startswith('LAT')]
lat = [m.groups() for m in lat if m]
repl = [re.match(r'REPL S=(\d) t=([\d.]+) bit=(\d) pending=(\d) replaced by (\d)', l).groups() for l in log if l.startswith('REPL')]
mv = Vcd(os.path.join(HERE, 'meta_seed.vcd')); mv.set_tick(0.01)
def meta_rows(S):
    nom = 'q_nom' if S == 2 else 'q_nom3'
    g_nom, t_nom = ('g_nom', 't_nom') if S == 2 else ('g_nom3', 't_nom3')
    g_m, t_m = ('g_s2', 't_s2') if S == 2 else ('g_s3', 't_s3')
    la = ('lat0', 'lat1', 'lat2', 'lat3') if S == 2 else ('l3_0', 'l3_1', 'l3_2', 'l3_3')
    return [
        ('SOURCE DOMAIN (period 10 ns)', None, None, None),
        ('clk_src', 'clk_src', 'clk', 'w'),
        ('src[2:0] Gray pointer', 'g_src', 'bin', 'w'),
        ('src[3] fast toggling bit', 't_src', 'bit', 'w'),
        (f'DESTINATION DOMAIN (period 14 ns), S = {S}', None, None, None),
        ('clk_dst', 'clk_dst', 'clk', 'r'),
        (f'plain {S}-FF chain, Gray bits', g_nom, 'bin', 'r'),
        (f'meta model, Gray bits', g_m, 'bin', 'r'),
        (f'plain {S}-FF chain, bit 3', t_nom, 'bit', 'r'),
        ('meta model, bit 3', t_m, 'bit', 'r'),
        ('MODEL INTERNALS', None, None, None),
        ('latency chosen, bit 0 (cycles)', la[0], 'dec', 's'),
        ('latency chosen, bit 1', la[1], 'dec', 's'),
        ('latency chosen, bit 2', la[2], 'dec', 's'),
        ('latency chosen, bit 3', la[3], 'dec', 's'),
    ]
for S in (2, 3):
    rows = meta_rows(S)
    sel = [x for x in lat if int(x[0]) == S]
    ev = {}
    marks = []
    # one marker per distinct extra value (first occurrence) and one for the first replacement
    seen = set()
    for g in sel:
        if g[4] not in seen and len(seen) < 3:
            seen.add(g[4]); n = len(ev) + 1; ev[n] = float(g[1]); marks.append((n, g))
    rp = [x for x in repl if int(x[0]) == S]
    if rp:
        n = len(ev) + 1; ev[n] = float(rp[0][1]); marks.append((n, ('REPL',) + rp[0]))
    render(mv, rows, 95, 640, 2.2, os.path.join(OUT, f'meta_model_S{S}.svg'),
           f'Synchronizer metastability model, S = {S}: random per-bit latency {S-1}, {S} or {S+1} cycles after the first capturing edge',
           ev, sorted(ev), note='numbers = examples listed in the table next to the figure; the model output equals the plain chain output when the extra delay is 0')
    md.append(f'META_S{S}')
    md.append('| No. | Time (ns) | What happens |')
    md.append('|---:|---:|---|')
    for n, g in marks:
        if g[0] == 'REPL':
            md.append(f'| {n} | {g[2]} | Bit {g[3]}: the pending change to {g[4]} is replaced by the new input value {g[5]}; the delay restarts. |')
        else:
            nom = float(g[1])
            md.append(f'| {n} | {nom} | Bit {g[2]} changes to {g[3]} at the last synchronizer stage. The model chose {g[4]} extra cycle(s): latency {g[5]} cycles after the first capturing edge, so the model output changes {int(g[4])*14} ns after the plain chain output. |')
    md.append('')
    md.append(f'All latency choices of the run with S = {S}: ' + '; '.join(f't={g[1]} ns bit {g[2]} extra {g[4]} (latency {g[5]})' for g in sel))
    md.append('')
open(os.path.join(OUT, 'tables.txt'), 'w', encoding='utf-8').write('\n'.join(md))
print('\n'.join(md)[:3000])
