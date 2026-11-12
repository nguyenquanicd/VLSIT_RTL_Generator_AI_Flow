"""Performance vectors (TEST-018, REQ-PERF-001..003) and the long-stream digest model.
The message is the pattern of the testbench task stream: lane j of word i = i * 9E3779B1 + j * 85EBCA6B + seed (mod 2^32).
Expected digests are computed by hashlib (OpenSSL) from the same pattern.
"""
import os
import sys

import vec_lib as V

OUT = os.path.join(V.VER, 'vec')


def pattern_bytes(dw, nwords, seed):
    lanes = dw // 32
    out = bytearray()
    for i in range(nwords):
        for j in range(lanes):
            out += ((i * 0x9E3779B1 + j * 0x85EBCA6B + seed) & 0xFFFFFFFF).to_bytes(4, 'little')
    return bytes(out)


def stream_job(v, code, nblocks, seed, tag, perf=True, check_digest=True, mask=0):
    """Hash of nblocks full blocks of the pattern. Returns the number of core blocks (data blocks + padding block)."""
    wb = v.wb
    blk = V.BLK[code]
    nbytes = nblocks * blk
    assert nbytes % wb == 0
    nw = nbytes // wb
    v.add('apbw 008 %08x' % (1 | (code << 8) | (mask << 24)))
    v.add('apbw 00c 1')
    v.add('poll 060 f00 100 2000')
    if perf:
        v.add('perf0')
    v.add('stream 0 %d %d' % (nw, seed))
    v.add('apbw 010 0')
    v.add('apbw 00c 2')
    v.add('poll 060 4 4 20000000')
    if perf:
        v.add('perf1 %s %d' % (tag, nblocks + 1))
    if check_digest:
        msg = pattern_bytes(v.dw, nw, seed)
        nout = 32 if code >= 12 else 0
        v.collect(code, 0, V.digest(code, msg, nout), tag)
    v.add('apbw 008 %08x' % 1)
    v.add('apbw 00c 4')
    v.add('poll 060 3 2 200000')
    return nblocks + 1


def perf_file(dw, name, codes, sizes=(40, 120), pre=(), mask=0):
    v = V.Vec(dw)
    for l in pre:
        v.add(l)
    for c in codes:
        for k, nb in enumerate(sizes):
            stream_job(v, c, nb, 5 + k, 'PERF_%s_%d' % (V.ALGNAME[c], nb), mask=mask)
    v.add('end')
    v.save(os.path.join(OUT, name))


def boot_file(dw, name, code, mib=4):
    """4 MiB of message (REQ-PERF-001): the digest is compared with hashlib."""
    v = V.Vec(dw)
    nbytes = mib * 1024 * 1024
    blk = V.BLK[code]
    # 4 MiB is a multiple of both block sizes (64 and 128)
    nb = nbytes // blk
    stream_job(v, code, nb, 9, 'BOOT_%s_%dMiB' % (V.ALGNAME[code], mib))
    v.add('end')
    v.save(os.path.join(OUT, name))


if __name__ == '__main__':
    perf_file(64, 'perf_dw64.vec', [1, 3, 9, 11])
    # recompute detection on (sha_sec.fault = 1, fredo = 1, resp = 3): every block runs twice
    perf_file(64, 'perf_redo_dw64.vec', [1, 3, 9, 11], pre=['apbw 018 00030411'])
    # masked Keccak (DEC-036): seed registers written and loaded first
    seed = ['apbw %03x %08x' % (0x20 + 4 * i, 0x1234567 * (i + 1) & 0xFFFFFFFF) for i in range(8)] + ['apbw 00c 20', 'poll 060 20 20 2000']
    perf_file(64, 'perf_mask_dw64.vec', [9, 11], pre=seed, mask=1)
    boot_file(64, 'boot_sha256_dw64.vec', 1)
    boot_file(64, 'boot_sha384_dw64.vec', 2)
    print('perf vectors written')
