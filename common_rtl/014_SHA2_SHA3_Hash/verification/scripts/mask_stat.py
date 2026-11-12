"""Welch t-test on the Hamming weight of the two shares for every cycle of a block (REQ-SEC-003, TEST-021).
Reads the HW lines printed by the testbench command hwdump: group 0 = fixed message, group 1 = random messages.
Usage: python mask_stat.py <log> [threshold]   (threshold default 4.5, the usual TVLA limit)
Prints the maximum |t| of share 0 and share 1 over the 48 cycles and returns 0 when both are below the threshold."""
import math
import sys


def tstat(n0, s0, q0, n1, s1, q1):
    if n0 < 2 or n1 < 2:
        return 0.0
    m0, m1 = s0 / n0, s1 / n1
    v0 = max(q0 / n0 - m0 * m0, 0) * n0 / (n0 - 1)
    v1 = max(q1 / n1 - m1 * m1, 0) * n1 / (n1 - 1)
    d = math.sqrt(v0 / n0 + v1 / n1)
    return 0.0 if d == 0 else (m0 - m1) / d


def analyse(path):
    rows = {}
    for l in open(path, errors='replace'):
        t = l.split()
        if len(t) == 8 and t[0] == 'HW':
            g, k, n = int(t[1]), int(t[2]), int(t[3])
            rows[(g, k)] = (n,) + tuple(float(x) for x in t[4:8])
    res = []
    for k in range(48):
        a, b = rows.get((0, k)), rows.get((1, k))
        if not a or not b:
            continue
        res.append((k, tstat(a[0], a[1], a[2], b[0], b[1], b[2]), tstat(a[0], a[3], a[4], b[0], b[3], b[4])))
    return res


if __name__ == '__main__':
    lim = float(sys.argv[2]) if len(sys.argv) > 2 else 4.5
    r = analyse(sys.argv[1])
    if not r:
        print('no HW data')
        sys.exit(2)
    m0 = max(abs(x[1]) for x in r)
    m1 = max(abs(x[2]) for x in r)
    print('cycles %d  max|t| share0 %.2f  share1 %.2f  limit %.1f' % (len(r), m0, m1, lim))
    sys.exit(0 if (m0 < lim and m1 < lim) else 1)
