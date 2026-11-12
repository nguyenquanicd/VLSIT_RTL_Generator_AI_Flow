"""Vector library of the SHA2/SHA3 testbench.

Expected digests come from two sources that are independent of the RTL (R-023):
  1. the NIST CAVP byte-oriented vectors (verification/ref_nist/), parsed here;
  2. Python hashlib (OpenSSL), used for random and edge-length messages and used to cross-check
     every NIST vector that is used (a disagreement stops the generator).
The commands written here are read by tb/tb_sha_top.sv (see README.md for the command list).
"""
import hashlib
import os
import random

HERE = os.path.dirname(os.path.abspath(__file__))
VER = os.path.dirname(HERE)
NIST = os.path.join(VER, 'ref_nist')

ALGNAME = {0: 'sha224', 1: 'sha256', 2: 'sha384', 3: 'sha512', 4: 'sha512_224', 5: 'sha512_256',
           8: 'sha3_224', 9: 'sha3_256', 10: 'sha3_384', 11: 'sha3_512', 12: 'shake_128', 13: 'shake_256'}
NISTNAME = {0: 'SHA224', 1: 'SHA256', 2: 'SHA384', 3: 'SHA512', 4: 'SHA512_224', 5: 'SHA512_256',
            8: 'SHA3_224', 9: 'SHA3_256', 10: 'SHA3_384', 11: 'SHA3_512', 12: 'SHAKE128', 13: 'SHAKE256'}
DLEN = {0: 28, 1: 32, 2: 48, 3: 64, 4: 28, 5: 32, 8: 28, 9: 32, 10: 48, 11: 64}
# Block size or rate in bytes (FIPS 180-4 section 1, FIPS 202 table 3)
BLK = {0: 64, 1: 64, 2: 128, 3: 128, 4: 128, 5: 128, 8: 144, 9: 136, 10: 104, 11: 72, 12: 168, 13: 136}
ALL_ALGS = sorted(ALGNAME)


def algmask(codes):
    """ALG parameter bit of the testbench: bit c for c < 8, bit c-2 otherwise."""
    m = 0
    for c in codes:
        m |= 1 << (c if c < 8 else c - 2)
    return m


def digest(code, msg, nbytes=0):
    h = hashlib.new(ALGNAME[code], msg)
    return h.digest(nbytes) if code >= 12 else h.digest()


def parse_rsp(path):
    """Yield dictionaries of the NIST .rsp records (keys lower case)."""
    rec = {}
    for line in open(path, encoding='ascii', errors='replace'):
        line = line.strip()
        if not line or line.startswith('#') or line.startswith('['):
            if rec and not line.startswith('#') and 'msg' in rec and ('md' in rec or 'output' in rec):
                yield rec
                rec = {}
            continue
        if '=' in line:
            k, v = [x.strip() for x in line.split('=', 1)]
            k = k.lower()
            if k == 'count' and rec and 'msg' in rec:
                yield rec
                rec = {}
            if k == 'len' and rec and 'msg' in rec:
                yield rec
                rec = {}
            rec[k] = v
    if rec and 'msg' in rec:
        yield rec


def nist_vectors(code, kind):
    """Byte-oriented NIST vectors of an algorithm. kind: ShortMsg, LongMsg, VariableOut.
    Returns a list of (name, msg bytes, expected bytes, nout)."""
    nm = NISTNAME[code]
    if code < 6:
        path = os.path.join(NIST, 'x_shabytetestvectors', 'shabytetestvectors', nm + kind + '.rsp')
    elif code < 12:
        path = os.path.join(NIST, 'x_sha-3bytetestvectors', nm + kind + '.rsp')
    else:
        path = os.path.join(NIST, 'x_shakebytetestvectors', nm + kind + '.rsp')
    if not os.path.exists(path):
        return []
    out = []
    n = 0
    for r in parse_rsp(path):
        if 'len' in r:
            ln = int(r['len'])
        else:
            ln = len(r['msg']) * 4
        if ln % 8:
            continue
        msg = bytes.fromhex(r['msg'])[:ln // 8] if ln else b''
        exp = bytes.fromhex(r.get('md', r.get('output')))
        if code >= 12:
            ol = int(r.get('outputlen', len(exp) * 8))
            if ol % 8:
                continue
            exp = exp[:ol // 8]
        nout = len(exp) if code >= 12 else 0
        # cross-check against hashlib: two independent references must agree
        ref = digest(code, msg, nout)
        if ref != exp:
            raise SystemExit('NIST and hashlib disagree: %s %s %s' % (nm, kind, ln))
        out.append(('NIST_%s_%s_len%d_%d' % (nm, kind, ln // 8, n), msg, exp, nout))
        n += 1
    return out


def words(b, wb):
    b = b + b'\0' * (-len(b) % wb)
    return [int.from_bytes(b[i:i + wb], 'little') for i in range(0, len(b), wb)]


def lenclass(code, ln):
    """Length class of the spec (TEST-001): 0, 1, rate-1, rate, rate+1, 2 x rate, other."""
    r = BLK[code]
    for name, v in (('zero', 0), ('one', 1), ('rm1', r - 1), ('r', r), ('rp1', r + 1), ('2r', 2 * r)):
        if ln == v:
            return name
    return 'other'


class Vec:
    """Builds the command list of one vector file for one AXI width."""

    def __init__(self, dw):
        self.dw = dw
        self.wb = dw // 8
        self.L = []
        self.mask = 0

    def add(self, s):
        self.L.append(s)

    def save(self, path):
        with open(path, 'w', newline='\n') as f:
            f.write('\n'.join(self.L) + '\n')

    def hx(self, w):
        return '%0*x' % (self.wb * 2, w)

    def start(self, code, ctx):
        self.add('apbw 008 %08x' % (1 | (code << 8) | (ctx << 16) | (self.mask << 24)))
        self.add('apbw 00c 1')
        self.add('poll 060 f00 100 2000')

    def feed(self, ctx, msg, burst=16, order=None):
        ws = words(msg, self.wb)
        for i in range(0, len(ws), burst):
            ch = ws[i:i + burst]
            self.add('axiw %d %d %s' % (ctx, len(ch), ' '.join(self.hx(w) for w in ch)))
        return len(msg)

    def finish(self, code, ctx, ln):
        tail = ln % self.wb
        self.add('apbw 008 %08x' % (1 | (code << 8) | (ctx << 16) | (self.mask << 24)))
        self.add('apbw 010 %x' % tail)
        self.add('apbw 00c 2')
        self.add('poll 060 4 4 200000')

    def collect(self, code, ctx, exp, tag):
        nw = (len(exp) + self.wb - 1) // self.wb
        self.add('tag %s' % tag)
        i = 0
        while i < nw:
            n = min(8, nw - i)
            self.add('waitlvl %d 400000' % n)
            self.add('axir %d %d' % (ctx, n))
            i += n
        ew = words(exp, self.wb)
        # the last word of a digest that is not a multiple of the width is compared by its valid bytes
        last = len(exp) % self.wb
        self.add('expect %d %d %s' % (len(exp), nw, ' '.join(self.hx(w) for w in ew)))

    def hash(self, code, msg, ctx=0, nout=0, tag=None, burst=16, exp=None):
        if exp is None:
            exp = digest(code, msg, nout)
        tag = tag or 'H_%s_len%d' % (ALGNAME[code], len(msg))
        self.add('cov %d %s' % (code, lenclass(code, len(msg))))
        self.start(code, ctx)
        self.feed(ctx, msg, burst)
        self.finish(code, ctx, len(msg))
        self.collect(code, ctx, exp, tag)
        self.add('apbw 008 %08x' % (1 | (ctx << 16)))
        self.add('apbw 00c 4')
        self.add('poll 060 3 2 20000')


def rnd_msg(rng, n):
    return bytes(rng.randrange(256) for _ in range(n))
