"""Writes the hash vector files of the testbench into verification/vec/.
Run: python gen_vectors.py
Files (per AXI width DW and algorithm set):
  nist_<set>_dw<DW>.vec   NIST CAVP ShortMsg, LongMsg (subset), SHAKE VariableOut (subset)  TEST-001, TEST-006
  edge_<set>_dw<DW>.vec   lengths 0,1,rate-1,rate,rate+1,2 x rate + FIPS example messages     TEST-001, TEST-003, TEST-004
  rand_<set>_dw<DW>.vec   seeded random lengths and burst sizes                               TEST-001, TEST-003
  multi_<set>_dw<DW>.vec  interleaved contexts, random order                                   TEST-005
"""
import os
import random
import sys

import vec_lib as V

OUT = os.path.join(V.VER, 'vec')
SETS = {
    'all': V.ALL_ALGS,
    'sha2': [0, 1, 2, 3, 4, 5],
    # AXI 128-bit is legal only when every block is a multiple of 16 bytes (DEC-021): SHA-2 and SHA3-224
    'w128': [0, 1, 2, 3, 4, 5, 8],
}
# Long NIST messages are expensive: keep every STEP-th record
LONG_STEP = 6
VAR_STEP = 7


def nist_file(dw, algs, name):
    v = V.Vec(dw)
    n = 0
    for c in algs:
        for kind in ('ShortMsg', 'LongMsg', 'VariableOut'):
            lst = V.nist_vectors(c, kind)
            if kind == 'LongMsg':
                lst = lst[::LONG_STEP] + [lst[-1]] if lst else lst
            if kind == 'VariableOut':
                lst = lst[::VAR_STEP]
            for (tag, msg, exp, nout) in lst:
                v.hash(c, msg, 0, nout, tag, exp=exp)
                n += 1
    v.add('end')
    v.save(os.path.join(OUT, name))
    return n


def edge_file(dw, algs, name):
    v = V.Vec(dw)
    rng = random.Random(11)
    n = 0
    for c in algs:
        r = V.BLK[c]
        for ln in (0, 1, r - 1, r, r + 1, 2 * r):
            nout = 37 if c >= 12 else 0
            v.hash(c, V.rnd_msg(rng, ln), 0, nout)
            n += 1
        # FIPS example messages (FIPS 180-4 / NIST examples): abc and the 448-bit and 896-bit strings
        for m in (b'abc', b'abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq',
                  b'abcdefghbcdefghicdefghijdefghijkefghijklfghijklmghijklmnhijklmnoijklmnopjklmnopqklmnopqrlmnopqrsmnopqrstnopqrstu'):
            v.hash(c, m, 0, 32 if c >= 12 else 0)
            n += 1
    v.add('end')
    v.save(os.path.join(OUT, name))
    return n


def rand_file(dw, algs, name, count=6, seed=1):
    v = V.Vec(dw)
    rng = random.Random(seed)
    n = 0
    for c in algs:
        for _ in range(count):
            ln = rng.choice([rng.randrange(0, 40), rng.randrange(0, 600), rng.randrange(0, 1600)])
            nout = rng.randrange(1, 400) if c >= 12 else 0
            v.hash(c, V.rnd_msg(rng, ln), 0, nout, burst=rng.choice([1, 2, 3, 5, 16, 64, 255]))
            n += 1
    v.add('end')
    v.save(os.path.join(OUT, name))
    return n


def multi_file(dw, algs, ctxn, name, seed=5, rounds=3):
    """Messages in 2..ctxn contexts at once; words of the contexts are interleaved at random."""
    v = V.Vec(dw)
    rng = random.Random(seed)
    wb = dw // 8
    n = 0
    for _ in range(rounds):
        k = rng.randrange(2, ctxn + 1)
        jobs = []
        for ctx in range(k):
            c = rng.choice(algs)
            ln = rng.randrange(0, 700)
            msg = V.rnd_msg(rng, ln)
            nout = rng.randrange(1, 100) if c >= 12 else 0
            jobs.append([ctx, c, msg, V.words(msg, wb), 0, nout])
        for j in jobs:
            v.add('cov %d %s' % (j[1], V.lenclass(j[1], len(j[2]))))
            v.start(j[1], j[0])
        left = True
        while left:
            left = False
            for j in jobs:
                if j[4] < len(j[3]):
                    cnt = min(rng.randrange(1, 9), len(j[3]) - j[4])
                    ch = j[3][j[4]:j[4] + cnt]
                    j[4] += cnt
                    v.add('axiw %d %d %s' % (j[0], len(ch), ' '.join(v.hx(w) for w in ch)))
                    left = True
        order = jobs[:]
        rng.shuffle(order)
        for j in order:
            v.finish(j[1], j[0], len(j[2]))
        rng.shuffle(order)
        for j in order:
            v.add('apbw 008 %08x' % (1 | (j[1] << 8) | (j[0] << 16)))
            v.collect(j[1], j[0], V.digest(j[1], j[2], j[5]), 'MULTI_ctx%d_%s_len%d' % (j[0], V.ALGNAME[j[1]], len(j[2])))
            n += 1
        for j in jobs:
            v.add('apbw 008 %08x' % (1 | (j[0] << 16)))
            v.add('apbw 00c 4')
        v.add('poll 060 3 2 20000')
    v.add('end')
    v.save(os.path.join(OUT, name))
    return n


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    for dw, sets in ((64, ['all']), (32, ['all']), (128, ['w128'])):
        for s in sets:
            algs = SETS[s]
            print('dw%d %s: nist %d, edge %d, rand %d, multi %d' % (
                dw, s, nist_file(dw, algs, 'nist_%s_dw%d.vec' % (s, dw)),
                edge_file(dw, algs, 'edge_%s_dw%d.vec' % (s, dw)),
                rand_file(dw, algs, 'rand_%s_dw%d.vec' % (s, dw)),
                multi_file(dw, algs, 4, 'multi_%s_dw%d.vec' % (s, dw))))
