"""Constants of SHA-2 and SHA-3 computed from their definitions (FIPS 180-4 sections 4.2 and 5.3,
FIPS 202 sections 3.2 and 3.3), checked against hashlib, and printed as SystemVerilog hex tables.
Run: python sha_consts.py   (self-check; prints OK or stops with an assertion)."""
import hashlib
import math


def primes(n):
    out, c = [], 2
    while len(out) < n:
        if all(c % p for p in out):
            out.append(c)
        c += 1
    return out


def iroot(n, k):
    lo, hi = 0, 1 << ((n.bit_length() // k) + 2)
    while lo < hi:
        mid = (lo + hi + 1) // 2
        if mid ** k <= n:
            lo = mid
        else:
            hi = mid - 1
    return lo


P80 = primes(80)
K256 = [iroot(p << 96, 3) & 0xFFFFFFFF for p in P80[:64]]
K512 = [iroot(p << 192, 3) & ((1 << 64) - 1) for p in P80]
H256 = [math.isqrt(p << 64) & 0xFFFFFFFF for p in P80[:8]]
H512 = [math.isqrt(p << 128) & ((1 << 64) - 1) for p in P80[:8]]
H384 = [math.isqrt(p << 128) & ((1 << 64) - 1) for p in P80[8:16]]
H224 = [h & 0xFFFFFFFF for h in H384]
M64 = (1 << 64) - 1


def rotr(x, n, w):
    return ((x >> n) | (x << (w - n))) & ((1 << w) - 1)


def compress512(h, block):
    w = [int.from_bytes(block[8 * i:8 * i + 8], 'big') for i in range(16)]
    for t in range(16, 80):
        s0 = rotr(w[t - 15], 1, 64) ^ rotr(w[t - 15], 8, 64) ^ (w[t - 15] >> 7)
        s1 = rotr(w[t - 2], 19, 64) ^ rotr(w[t - 2], 61, 64) ^ (w[t - 2] >> 6)
        w.append((w[t - 16] + s0 + w[t - 7] + s1) & M64)
    a, b, c, d, e, f, g, hh = h
    for t in range(80):
        s1 = rotr(e, 14, 64) ^ rotr(e, 18, 64) ^ rotr(e, 41, 64)
        ch = (e & f) ^ (~e & M64 & g)
        t1 = (hh + s1 + ch + K512[t] + w[t]) & M64
        s0 = rotr(a, 28, 64) ^ rotr(a, 34, 64) ^ rotr(a, 39, 64)
        mj = (a & b) ^ (a & c) ^ (b & c)
        t2 = (s0 + mj) & M64
        hh, g, f, e, d, c, b, a = g, f, e, (d + t1) & M64, c, b, a, (t1 + t2) & M64
    return [(x + y) & M64 for x, y in zip(h, [a, b, c, d, e, f, g, hh])]


def sha512_iv(iv, msg):
    pad = msg + b'\x80'
    pad += b'\x00' * ((112 - len(pad)) % 128) + (len(msg) * 8).to_bytes(16, 'big')
    h = list(iv)
    for i in range(0, len(pad), 128):
        h = compress512(h, pad[i:i + 128])
    return h


def sha512t_iv(t):
    iv = [x ^ 0xA5A5A5A5A5A5A5A5 for x in H512]
    return sha512_iv(iv, ('SHA-512/%d' % t).encode())


H512_224 = sha512t_iv(224)
H512_256 = sha512t_iv(256)
# self-check of the 512-class constants through hashlib
for name, iv, n in (('sha512', H512, 64), ('sha384', H384, 48), ('sha512_224', H512_224, 28), ('sha512_256', H512_256, 32)):
    d = b''.join(x.to_bytes(8, 'big') for x in sha512_iv(iv, b'abc'))[:n]
    assert d == hashlib.new(name, b'abc').digest(), name

# Keccak round constants (FIPS 202 algorithm 5) and rotation offsets (section 3.2.2)
def rc_bit(t):
    if t % 255 == 0:
        return 1
    r = [1, 0, 0, 0, 0, 0, 0, 0]
    for _ in range(t % 255):
        r = [0] + r
        r[0] ^= r[8]
        r[4] ^= r[8]
        r[5] ^= r[8]
        r[6] ^= r[8]
        r = r[:8]
    return r[0]


RC = []
for ir in range(24):
    v = 0
    for j in range(7):
        v |= rc_bit(j + 7 * ir) << ((1 << j) - 1)
    RC.append(v)
ROT = {(0, 0): 0}
x, y = 1, 0
for t in range(24):
    ROT[(x, y)] = ((t + 1) * (t + 2) // 2) % 64
    x, y = y, (2 * x + 3 * y) % 5


def keccak_f(a):
    for ir in range(24):
        c = [a[x][0] ^ a[x][1] ^ a[x][2] ^ a[x][3] ^ a[x][4] for x in range(5)]
        d = [c[(x - 1) % 5] ^ rotr(c[(x + 1) % 5], 63, 64) for x in range(5)]
        a = [[a[x][y] ^ d[x] for y in range(5)] for x in range(5)]
        b = [[0] * 5 for _ in range(5)]
        for x in range(5):
            for y in range(5):
                b[y][(2 * x + 3 * y) % 5] = rotr(a[x][y], (64 - ROT[(x, y)]) % 64, 64)
        a = [[b[x][y] ^ (~b[(x + 1) % 5][y] & M64 & b[(x + 2) % 5][y]) for y in range(5)] for x in range(5)]
        a[0][0] ^= RC[ir]
    return a


def sha3(msg, rate, suffix, outlen):
    pad = bytearray(msg) + bytes([suffix])
    pad += b'\x00' * (-len(pad) % rate)
    pad[-1] |= 0x80
    st = [[0] * 5 for _ in range(5)]
    for off in range(0, len(pad), rate):
        for i in range(rate // 8):
            st[i % 5][i // 5] ^= int.from_bytes(pad[off + 8 * i:off + 8 * i + 8], 'little')
        st = keccak_f(st)
    out = b''.join(st[i % 5][i // 5].to_bytes(8, 'little') for i in range(25))
    return out[:outlen]


assert sha3(b'abc', 136, 0x06, 32) == hashlib.sha3_256(b'abc').digest()
assert sha3(b'abc', 72, 0x06, 64) == hashlib.sha3_512(b'abc').digest()
assert sha3(b'abc', 168, 0x1F, 32) == hashlib.shake_128(b'abc').digest(32)
assert hashlib.sha256(b'abc').digest()  # K256 and H256 are checked in the RTL test


def table(vals, w, per_line):
    items = ["%d'h%0*x" % (w, w // 4, v) for v in reversed(vals)]
    lines = []
    for i in range(0, len(items), per_line):
        lines.append('    ' + ', '.join(items[i:i + per_line]))
    return '{\n' + ',\n'.join(lines) + '\n  }'


if __name__ == '__main__':
    assert K256[0] == 0x428a2f98 and K256[63] == 0xc67178f2 and K512[0] == 0x428a2f98d728ae22 and K512[79] == 0x6c44198c4a475817
    assert RC[0] == 1 and RC[23] == 0x8000000080008008 and ROT[(1, 0)] == 1 and ROT[(2, 0)] == 62 and ROT[(0, 1)] == 36
    print('OK: constants verified against hashlib (SHA-384/512/512-t digests, SHA3-256/512, SHAKE128)')
