"""Unit tests of the masked Keccak core and of the random bit source (stage 2b). Run: python unit_mask.py
The masked core is compared with the plain core; the random bit source with a Python Keccak model."""
import os
import re
import subprocess
import sys

import simlib as S

sys.path.insert(0, os.path.join(S.IP, 'tools'))
import sha_consts as C

UNIT = S.VER + '/unit'
R = S.RTL
M64 = (1 << 64) - 1


def build_run(top, files, name):
    bd = S.WORK + '/' + name
    os.makedirs(bd, exist_ok=True)
    env = S.env_for(bd)
    cmd = [S.VBIN, '--binary', '--timing', '-O1', '-Wno-fatal', '-Wno-lint', '-Wno-style', '--top-module', top, '-Mdir', bd + '/obj', '-j', '4',
           '-CFLAGS', '-std=gnu++17', '-LDFLAGS', '-static-libstdc++ -static-libgcc', '-o', 'V'] + files
    r = subprocess.run(cmd, capture_output=True, text=True, env=env)
    exe = bd + '/obj/V.exe'
    if not os.path.exists(exe):
        print((r.stdout + r.stderr)[-2000:])
        return ''
    return subprocess.run([exe], capture_output=True, text=True, env=env).stdout


def rnd(a, rc):
    """One Keccak-f[1600] round on 25 lanes (FIPS 202 section 3.3)."""
    c = [a[x] ^ a[x + 5] ^ a[x + 10] ^ a[x + 15] ^ a[x + 20] for x in range(5)]
    d = [c[(x + 4) % 5] ^ (((c[(x + 1) % 5] << 1) | (c[(x + 1) % 5] >> 63)) & M64) for x in range(5)]
    a = [a[i] ^ d[i % 5] for i in range(25)]
    b = [0] * 25
    for x in range(5):
        for y in range(5):
            r = C.ROT[(x, y)]
            v = a[x + 5 * y]
            v = (((v << r) | (v >> (64 - r))) & M64) if r else v
            b[y + 5 * ((2 * x + 3 * y) % 5)] = v
    a = [b[x + 5 * y] ^ ((~b[((x + 1) % 5) + 5 * y]) & b[((x + 2) % 5) + 5 * y]) & M64 for y in range(5) for x in range(5)]
    a[0] ^= rc
    return a


def lanes(v):
    return [(v >> (64 * i)) & M64 for i in range(25)]


def tonum(l):
    return sum(x << (64 * i) for i, x in enumerate(l))


def seeded_state(seed):
    return lanes(seed | (1 << 256) | (1 << 1599))


def main():
    ok = True
    log = []
    out = build_run('tb_mask_unit', [UNIT + '/tb_mask_unit.sv', R + '/m_vlsit_sha_keccak_dom.sv', R + '/m_vlsit_sha_keccak.sv'], 'unit_dom')
    log.append(out)
    m = re.search(r'DOM-RESULT ok=(\d+) bad=(\d+) masked_runs=(\d+) random_shares=(\d+) parity_false_alarms=(\d+)', out)
    good = bool(m) and int(m.group(2)) == 0 and int(m.group(1)) == 60 and int(m.group(4)) == int(m.group(3)) and int(m.group(5)) == 0
    print('masked Keccak core against the plain core:', m.group(0) if m else 'NO RESULT', 'PASS' if good else 'FAIL')
    ok &= good
    out = build_run('tb_prng_unit', [UNIT + '/tb_prng_unit.sv', R + '/m_vlsit_sha_prng.sv'], 'unit_prng')
    log.append(out)
    seed = 0x0123456789abcdeffedcba98765432100f1e2d3c4b5a69788796a5b4c3d2e1f0
    a = seeded_state(seed)
    for r in range(24):
        a = rnd(a, C.RC[r])
    exp1 = tonum(a)
    for r in range(3):
        a = rnd(a, C.RC[r])
    exp4 = tonum(a)
    for tag, exp in (('PRNG-A 1', exp1), ('PRNG-A 4', exp4)):
        m = re.search(tag + r' ([0-9a-f]+)', out)
        good = bool(m) and int(m.group(1), 16) == exp
        print('random bit source, seed registers, %s matches the Python model:' % tag, 'PASS' if good else 'FAIL')
        ok &= good
    words = [int(x, 16) for x in re.findall(r'ENT \d+ ([0-9a-f]{8})', out)][:8]
    m = re.search(r'PRNG-B 1 ([0-9a-f]+)', out)
    good = False
    if m and len(words) == 8:
        a = seeded_state(sum(w << (32 * j) for j, w in enumerate(words)))
        for r in range(24):
            a = rnd(a, C.RC[r])
        good = int(m.group(1), 16) == tonum(a)
    print('random bit source, entropy port (%d words), matches the Python model:' % len(words), 'PASS' if good else 'FAIL')
    ok &= good
    m = re.search(r'PRNG-STATUS seeded_a=(\d) seeded_b=(\d) words=(\d+)', out)
    good = bool(m) and m.group(1) == '1' and m.group(2) == '1' and int(m.group(3)) == 8
    print('both sources seeded, eight entropy words taken:', 'PASS' if good else 'FAIL')
    ok &= good
    m = re.search(r'PRNG-AFTER-SRST seeded_a=(\d) seeded_b=(\d)', out)
    good = bool(m) and m.group(1) == '0' and m.group(2) == '0'
    print('soft reset clears the seeded flags:', 'PASS' if good else 'FAIL')
    ok &= good
    os.makedirs(S.VER + '/reports', exist_ok=True)
    open(S.VER + '/reports/unit_mask.log', 'w').write('\n'.join(log))
    print('UNIT RESULT:', 'PASS' if ok else 'FAIL')
    return 0 if ok else 1


if __name__ == '__main__':
    sys.exit(main())
