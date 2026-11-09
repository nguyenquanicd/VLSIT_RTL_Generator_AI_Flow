"""Coverage summary of one or more Verilator coverage databases (coverage.dat).

Usage: python cov_report.py [--min PERCENT] [--detail] db1.dat [db2.dat ...]

The counts of the same point in several databases are added (merge of runs). A point is covered
when its count is at least 1. Points are grouped by source file and by type: line (statement),
branch (if and case arms) and toggle (every bit, rising and falling). The design set is the
modules written for this IP; generated register code, library modules and cells are listed apart.
Exit code 0 when every type of the design set reaches the minimum, 1 otherwise.
"""
import re
import sys
from collections import defaultdict

DESIGN = [
    'm_vlsit_hyperram_controller.sv',
    'm_vlsit_apb4_if.sv',
    'm_vlsit_axi4_cdc.sv',
    'm_vlsit_axi4_frontend.sv',
    'm_vlsit_hyperbus_ctrl.sv',
    'm_vlsit_hyperbus_phy.sv',
    'm_vlsit_cap_ring.sv',
    'm_vlsit_hyperram_irq.sv',
]
KEY = re.compile(r"^C '(.*)' (\d+)\s*$")


def parse(path, points):
    with open(path, encoding='latin-1') as fh:
        for ln in fh:
            m = KEY.match(ln)
            if not m:
                continue
            key, cnt = m.group(1), int(m.group(2))
            points[key] = points.get(key, 0) + cnt


def fields(key):
    d = {}
    for part in key.split('\x01'):
        if '\x02' in part:
            k, v = part.split('\x02', 1)
            d[k] = v
    return d


def main(argv):
    minimum = 50.0
    detail = False
    dbs = []
    i = 0
    while i < len(argv):
        if argv[i] == '--min':
            minimum = float(argv[i + 1])
            i += 2
        elif argv[i] == '--detail':
            detail = True
            i += 1
        else:
            dbs.append(argv[i])
            i += 1
    if not dbs:
        print(__doc__)
        return 2
    points = {}
    for db in dbs:
        parse(db, points)
    stat = defaultdict(lambda: defaultdict(lambda: [0, 0]))
    for key, cnt in points.items():
        f = fields(key)
        name = f.get('f', '?').replace('\\', '/').split('/')[-1]
        typ = f.get('t', '?')
        if typ not in ('line', 'branch', 'toggle'):
            continue
        s = stat[name][typ]
        s[1] += 1
        if cnt > 0:
            s[0] += 1
    types = ('line', 'branch', 'toggle')

    def pct(s):
        return 100.0 * s[0] / s[1] if s[1] else float('nan')

    print('%-34s %18s %18s %18s' % ('module (source file)', 'line', 'branch', 'toggle'))
    tot = {t: [0, 0] for t in types}
    for name in DESIGN:
        row = []
        for t in types:
            s = stat[name][t]
            tot[t][0] += s[0]
            tot[t][1] += s[1]
            row.append('%5d/%-5d %5.1f%%' % (s[0], s[1], pct(s)) if s[1] else '        -        ')
        print('%-34s %18s %18s %18s' % (name, row[0], row[1], row[2]))
    row = ['%5d/%-5d %5.1f%%' % (tot[t][0], tot[t][1], pct(tot[t])) for t in types]
    print('%-34s %18s %18s %18s' % ('TOTAL design set', row[0], row[1], row[2]))
    others = sorted(n for n in stat if n not in DESIGN)
    if detail:
        print()
        print('Not part of the design set (generated, library, cells, test code):')
        for name in others:
            row = []
            for t in types:
                s = stat[name][t]
                row.append('%5d/%-5d %5.1f%%' % (s[0], s[1], pct(s)) if s[1] else '        -        ')
            print('%-34s %18s %18s %18s' % (name, row[0], row[1], row[2]))
    ok = all(tot[t][1] == 0 or pct(tot[t]) >= minimum for t in types)
    print()
    print('minimum %.0f%% on every type of the design set: %s' % (minimum, 'PASS' if ok else 'FAIL'))
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
