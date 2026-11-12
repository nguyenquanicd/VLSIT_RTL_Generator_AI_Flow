"""Small VCD reader: values of chosen signals at each rising edge of a clock, in a time window.
Usage: python vcd_tool.py file.vcd t0_ps t1_ps clockname sig1 sig2 ...   (signal names are dut scope names)
Also used as a library by vcd_to_wavejson.py."""
import re
import sys


def load(path, scope_filter=('dut',)):
    """Returns (ids, changes) ; ids: name -> (id, width); changes: id -> list of (time_ps, value string)."""
    ids = {}
    scope = []
    changes = {}
    t = 0
    with open(path) as f:
        in_defs = True
        for line in f:
            line = line.strip()
            if in_defs:
                if line.startswith('$scope'):
                    scope.append(line.split()[2])
                elif line.startswith('$upscope'):
                    scope.pop()
                elif line.startswith('$var'):
                    p = line.split()
                    w = int(p[2]); i = p[3]; nm = p[4]
                    full = '.'.join(scope)
                    key = nm if (scope[-1:] == ['dut'] or (len(scope) == 1 and nm == 'clk') or (nm == 'clk' and len(scope) <= 2)) else None
                    ids.setdefault('@' + full + '.' + nm, (i, w)); changes.setdefault(i, [])
                    if scope[-1:] == ['dut'] and key:
                        ids[nm] = (i, w)
                        changes.setdefault(i, [])
                    elif nm == 'clk' and 'clk' not in ids and scope[-1:] == ['tb_sha_top']:
                        ids['clk_tb'] = (i, w); changes.setdefault(i, [])
                elif line.startswith('$enddefinitions'):
                    in_defs = False
                continue
            if not line:
                continue
            if line[0] == '#':
                t = int(line[1:])
            elif line[0] in '01xzXZ' and len(line) > 1:
                i = line[1:]
                if i in changes:
                    changes[i].append((t, line[0]))
            elif line[0] == 'b':
                v, i = line[1:].split()
                if i in changes:
                    changes[i].append((t, v))
    return ids, changes


def value_at(chg, t):
    v = 'x'
    for (tt, vv) in chg:
        if tt <= t:
            v = vv
        else:
            break
    return v


def hexv(v):
    if set(v) <= set('01'):
        return '%x' % int(v, 2)
    return v


if __name__ == '__main__':
    path, t0, t1, clk = sys.argv[1], int(sys.argv[2]), int(sys.argv[3]), sys.argv[4]
    sigs = sys.argv[5:]
    ids, ch = load(path)
    ck = ids[clk][0]
    edges = [t for (t, v) in ch[ck] if v == '1' and t0 <= t <= t1]
    print('time   ' + ' '.join(sigs))
    for t in edges:
        row = []
        for s in sigs:
            row.append(hexv(value_at(ch[ids[s][0]], t - 1)))   # value just before the edge
        print('%-8d' % t + ' '.join(row))
