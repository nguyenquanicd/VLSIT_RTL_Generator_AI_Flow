"""Code coverage report (R-047). Reads the Verilator coverage.dat of every suite in coverage/data/, merges them (a point is
covered when any suite counted it), keeps the points of the design files of rtl/ (the generated CSR is reported separately,
library cells, the testbench and the checkers are excluded) and writes reports/coverage_report.md and coverage/uncovered_<metric>.txt.
Metrics: line (statement blocks), branch, toggle. Status words follow the guide: baseline_only / target_met / target_unmet.
Run: python cov_report.py [--target LINE=NN]
"""
import collections
import glob
import os
import re
import sys

import simlib as S

COV = S.VER + '/coverage'
REP = S.VER + '/reports'
RTL = S.RTL.replace(chr(92), '/')

POINT = re.compile(r"^C '(.*)' (\d+)\s*$")


def parse(path):
    for line in open(path, encoding='utf-8', errors='replace'):
        m = POINT.match(line)
        if not m:
            continue
        body, cnt = m.group(1), int(m.group(2))
        d = {}
        for item in body.split('\x01'):
            if '\x02' in item:
                k, v = item.split('\x02', 1)
                d[k] = v
        yield d, cnt


def main():
    merged = {}
    files = sorted(f for f in glob.glob(COV + '/data/*.dat') if not os.path.basename(f).startswith('open'))   # the open-finding suites are not part of the regression
    for p in files:
        for d, cnt in parse(p):
            f = d.get('f', '').replace(chr(92), '/')
            if not f.startswith(RTL):
                continue
            key = (f, d.get('l'), d.get('n'), d.get('t'), d.get('o'), d.get('h'))
            merged[key] = merged.get(key, 0) + cnt
    stats = collections.defaultdict(lambda: [0, 0])      # (metric, group) -> [covered, total]
    unc = collections.defaultdict(list)
    for (f, l, n, t, o, h), c in merged.items():
        grp = 'csr (generated)' if '/csr/' in f else 'design'
        base = os.path.basename(f)
        for g in (grp, base):
            stats[(t, g)][1] += 1
            if c > 0:
                stats[(t, g)][0] += 1
        if c == 0:
            unc[t].append('%s:%s col %s %s %s [%s]' % (base, l, n, t, o, h))
    metrics = ('line', 'branch', 'toggle')
    out = ['# Code coverage report', '',
           'Simulator and version: Verilator 5.053 (OSS CAD Suite) with `--coverage-line --coverage-toggle` (branch points are produced by the line option). '
           'Merged data of %d suites (%s). DUT scope: the 15 files of `rtl/` (`m_vlsit_sha_*` and the generated `csr/`); instances of the same module in '
           'different hierarchy paths count separately. Excluded: library cells and library modules, the testbench, the checkers. '
           'No exclusion file is used: unreachable and stage-2 points are counted as uncovered. Status: `baseline_only` (no target was given, R-047).' % (len(files), ', '.join(os.path.basename(x)[:-4] for x in files)), '',
           '| Scope | Line covered / total | Branch covered / total | Toggle covered / total |', '|---|---|---|---|']
    def cell(m, g):
        c, t = stats[(m, g)]
        return '%d / %d (%.1f %%)' % (c, t, 100.0 * c / t) if t else 'n/a'
    for g in ('design', 'csr (generated)'):
        out.append('| %s | %s | %s | %s |' % (g, cell('line', g), cell('branch', g), cell('toggle', g)))
    out += ['', '## Per file (design files and generated CSR files)', '', '| File | Line | Branch | Toggle |', '|---|---|---|---|']
    names = sorted({g for (m, g) in stats if g not in ('design', 'csr (generated)')})
    for g in names:
        out.append('| %s | %s | %s | %s |' % (g, cell('line', g), cell('branch', g), cell('toggle', g)))
    # functional coverage COV-006: algorithm x length class x width (context count is reported separately)
    import vec_lib as V
    CLS = ['zero', 'one', 'rm1', 'r', 'rp1', '2r', 'other']
    hits = set()
    ctxs = set()
    for lp in glob.glob(S.VER + '/logs/*.log'):
        if '/cdc/' in lp.replace(chr(92), '/'):
            continue
        for m in re.finditer(r'COV alg=(\d+) cls=(\w+) ctxn=(\d+) dw=(\d+)', open(lp, errors='replace').read()):
            hits.add((int(m.group(4)), int(m.group(1)), m.group(2)))
            ctxs.add(int(m.group(3)))
    out += ['## Functional coverage COV-006 (algorithm x length class x AXI width)', '',
            'Bins: length classes of TEST-001 (0, 1, rate-1, rate, rate+1, 2 x rate bytes, other) for every algorithm legal at the width '
            '(128-bit: SHA-2 and SHA3-224). Context counts simulated with hashing: %s (the specification cross also lists other counts; they were not simulated).' % sorted(ctxs), '',
            '| Width | Algorithms | Bins | Hit | Missing |', '|---|---|---|---|---|']
    for dw, algs in ((32, V.ALL_ALGS), (64, V.ALL_ALGS), (128, [0, 1, 2, 3, 4, 5, 8])):
        bins = [(dw, a, c) for a in algs for c in CLS]
        hit = [b for b in bins if b in hits]
        miss = ['%s/%s' % (V.ALGNAME[b[1]], b[2]) for b in bins if b not in hits]
        out.append('| %d | %d | %d | %d | %s |' % (dw, len(algs), len(bins), len(hit), ', '.join(miss) if miss else 'none'))
    os.makedirs(REP, exist_ok=True)
    for m in metrics:
        with open(COV + '/uncovered_%s.txt' % m, 'w') as f:
            f.write('\n'.join(sorted(unc[m])) + '\n')
    out += ['', 'Uncovered points are listed in `coverage/uncovered_line.txt`, `uncovered_branch.txt` and `uncovered_toggle.txt`.', '']
    open(REP + '/coverage_report.md', 'w', encoding='utf-8').write('\n'.join(out) + '\n')
    print('\n'.join(out[:20]))


if __name__ == '__main__':
    main()
