"""Streaming VCD reader for chosen signals (full names relative to tb_sha_top.dut or 'clk'). Prints value changes sampled at core clock edges inside a time window.
Usage: python vcd_sel.py file.vcd t0 t1 sig...   ; signal = dut-relative name, e.g. u_seq.o_ack_init or o_irq"""
import sys
path, t0, t1 = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]); want = sys.argv[4:]
scope = []; idmap = {}; clkid = None
cur = {}
rows = []
def hexv(v):
    return '%x' % int(v, 2) if set(v) <= set('01') else v
with open(path) as f:
    defs = True; t = 0; prevrow = None
    for line in f:
        line = line.strip()
        if defs:
            if line.startswith('$scope'): scope.append(line.split()[2])
            elif line.startswith('$upscope'): scope.pop()
            elif line.startswith('$var'):
                p = line.split(); i = p[3]; nm = p[4]
                full = '.'.join(scope)
                rel = full[len('tb_sha_top.dut.'):] + '.' + nm if full.startswith('tb_sha_top.dut.') else (nm if full == 'tb_sha_top.dut' else None)
                if rel is not None:
                    rel = rel.lstrip('.')
                    if rel in want: idmap.setdefault(i, []).append(rel)
                if full == 'tb_sha_top.dut' and nm == 'i_clk_core': clkid = i
            elif line.startswith('$enddefinitions'): defs = False
            continue
        if not line: continue
        if line[0] == '#':
            nt = int(line[1:])
            t = nt
            continue
        if line[0] == 'b': v, i = line[1:].split()
        elif line[0] in '01xz': v, i = line[0], line[1:]
        else: continue
        if i == clkid:
            if v == '1' and t0 <= t <= t1:
                row = tuple(hexv(cur.get(s, '?'))[:16] for s in want)
                if row != prevrow:
                    print(t, row); prevrow = row
            cur['__clk'] = v
        if i in idmap:
            for s in idmap[i]: cur[s] = v
        if t > t1: break
