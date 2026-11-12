"""TEST-018: checks the PERF lines of the perf_* and boot suite logs against section 13 of the specification.
 PERF-003: cycles per block = R/UNR + 2, tolerance 2 cycles (slope between two message lengths, so the start-up cost cancels).
 PERF-001: 4 MiB of SHA-256 and SHA-384 in at most 5 ms at 500 MHz = 2,500,000 cycles.
 PERF-002: sustained throughput at least 8 Gbit/s at 500 MHz (16 bit per cycle) for one SHA-256 or SHA3-256 stream.
Writes reports/perf_report.md; exit status 1 on a failed check.
"""
import os
import re
import sys

import simlib as S
import vec_lib as V

ROUNDS = {'sha256': 64, 'sha512': 80, 'sha3_256': 24, 'sha3_512': 24}
BLK = {'sha256': 64, 'sha512': 128, 'sha3_256': 136, 'sha3_512': 72}
FMAX_HZ = 500e6


def perf_lines(path):
    out = {}
    for m in re.finditer(r'PERF (PERF_(\w+?)_(\d+)) cycles=(\d+) blocks=(\d+)', open(path).read()):
        out[(m.group(2), int(m.group(3)))] = (int(m.group(4)), int(m.group(5)))
    return out


def main():
    rows = ['# Performance results (TEST-018)', '',
            'Cycles are counted by the testbench from just before the first message word to `sha_sts.ready` (core clock). '
            'Cycles per block is the slope between a 40-block and a 120-block message (the padding block is counted).', '',
            '| Configuration | Algorithm | Unroll | Cycles per block (measured) | Formula max(R/UNR+2, words+4) | Difference | Bits per cycle | Gbit/s at 500 MHz | Result |',
            '|---|---|---|---|---|---|---|---|---|']
    bad = 0
    for u in (1, 2, 4):
        p = S.VER + '/logs/perf_u%d.log' % u
        if not os.path.exists(p):
            rows.append('| perf_u%d | not run | | | | | | | NOT-RUN |' % u)
            bad += 1
            continue
        d = perf_lines(p)
        for a in ('sha256', 'sha512', 'sha3_256', 'sha3_512'):
            if (a, 40) not in d or (a, 120) not in d:
                rows.append('| perf_u%d | %s | %d | missing | | | | | FAIL |' % (u, a, u))
                bad += 1
                continue
            (c1, b1), (c2, b2) = d[(a, 40)], d[(a, 120)]
            slope = (c2 - c1) / float(b2 - b1)
            words = BLK[a] // 8                       # words per block on the 64-bit window, one word per cycle
            exp = max(ROUNDS[a] // u + 2, words + 4)   # section 13, DEC-032
            ok = abs(slope - exp) <= 2
            bad += 0 if ok else 1
            bpc = BLK[a] * 8 / slope
            res = 'PASS' if ok else ('FAIL')
            rows.append('| perf_u%d | %s | %d | %.2f | %d | %+.2f | %.2f | %.2f | %s |' % (u, a, u, slope, exp, slope - exp, bpc, bpc * FMAX_HZ / 1e9, res))
    rows += ['', '| Check | Measured | Limit | Result |', '|---|---|---|---|']
    p = S.VER + '/logs/boot.log'
    if os.path.exists(p):
        t = open(p).read()
        for m in re.finditer(r'PERF (BOOT_(\w+?)_4MiB) cycles=(\d+) blocks=(\d+)', t):
            c = int(m.group(3))
            ok = c <= 2500000
            bad += 0 if ok else 1
            rows.append('| PERF-001 4 MiB %s, CFG-BOOT | %d cycles = %.2f ms at 500 MHz; minimum clock for 5 ms: %.0f MHz | 2,500,000 cycles (5 ms at 500 MHz) | %s |' % (
                m.group(2), c, c / FMAX_HZ * 1e3, c / 5e-3 / 1e6, 'PASS' if ok else 'FAIL'))
    else:
        rows.append('| PERF-001 | not run | | NOT-RUN |')
        bad += 1
    # CFG-STOR of the specification: SHA-256 unroll 4, Keccak unroll 2
    for a, u in (('sha256', 4), ('sha3_256', 2)):
        p = S.VER + '/logs/perf_u%d.log' % u
        if os.path.exists(p):
            d = perf_lines(p)
            if (a, 40) in d and (a, 120) in d:
                (c1, b1), (c2, b2) = d[(a, 40)], d[(a, 120)]
                slope = (c2 - c1) / float(b2 - b1)
                g = BLK[a] * 8 / slope * FMAX_HZ / 1e9
                ok = g >= 8.0
                bad += 0 if ok else 1
                rows.append('| PERF-002 %s unroll %d, one stream | %.2f Gbit/s at 500 MHz | >= 8 Gbit/s | %s |' % (a, u, g, 'PASS' if ok else 'FAIL'))
    # recompute detection: every block runs twice (section 13, DEC-035)
    p = S.VER + '/logs/perf_redo.log'
    rows += ['', '| Recompute detection (unroll 1) | Cycles per block (measured) | 2 x (R/UNR + 2) | Result |', '|---|---|---|---|']
    if os.path.exists(p):
        d = perf_lines(p)
        for a in ('sha256', 'sha512', 'sha3_256', 'sha3_512'):
            if (a, 40) in d and (a, 120) in d:
                (c1, b1), (c2, b2) = d[(a, 40)], d[(a, 120)]
                slope = (c2 - c1) / float(b2 - b1)
                exp = 2 * (ROUNDS[a] + 2)
                ok = abs(slope - exp) <= 2
                bad += 0 if ok else 1
                rows.append('| %s | %.2f | %d | %s |' % (a, slope, exp, 'PASS' if ok else 'FAIL'))
    else:
        rows.append('| not run | | | NOT-RUN |')
        bad += 1
    # masked Keccak: 24 rounds x 2 cycles + 2 (section 13, DEC-036)
    p = S.VER + '/logs/perf_mask.log'
    rows += ['', '| Masked Keccak (unroll 1, pipe 2) | Cycles per block (measured) | 2 x 24 + 2 | Bits per cycle | Gbit/s at 500 MHz | Result |', '|---|---|---|---|---|---|']
    if os.path.exists(p):
        d = perf_lines(p)
        for a in ('sha3_256', 'sha3_512'):
            if (a, 40) in d and (a, 120) in d:
                (c1, b1), (c2, b2) = d[(a, 40)], d[(a, 120)]
                slope = (c2 - c1) / float(b2 - b1)
                ok = abs(slope - 50) <= 2
                bad += 0 if ok else 1
                bpc = BLK[a] * 8 / slope
                rows.append('| %s | %.2f | 50 | %.2f | %.2f | %s |' % (a, slope, bpc, bpc * FMAX_HZ / 1e9, 'PASS' if ok else 'FAIL'))
            else:
                rows.append('| %s | missing | 50 | | | FAIL |' % a)
                bad += 1
    else:
        rows.append('| not run | | | | | NOT-RUN |')
        bad += 1
    open(S.VER + '/reports/perf_report.md', 'w').write('\n'.join(rows) + '\n')
    print('\n'.join(rows))
    return bad


if __name__ == '__main__':
    sys.exit(1 if main() else 0)
