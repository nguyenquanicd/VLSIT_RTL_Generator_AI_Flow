"""Cycle model of the AXI upsizer defined by the specification (not RTL).

Used to draw the waveforms of the specification and to check the algorithm of section 10.2 at byte level.
Parameters of the drawings: S = 32 bit, M = 128 bit (ratio 4), AXI4 profile. Other widths: environment
variables UPS_S and UPS_M (bits).
"""
import math
import os

S_W = int(os.environ.get('UPS_S', 32))
M_W = int(os.environ.get('UPS_M', 128))
SB, MB = S_W // 8, M_W // 8
LS, LM = int(math.log2(SB)), int(math.log2(MB))          # log2 of SB, MB
RATIO = M_W // S_W
SLOT_N = RATIO
INCR, FIXED, WRAP = 1, 0, 2


# ---------------------------------------------------------------------------------------------------------
# attribute conversion (specification section 10.2, OP-001)
# ---------------------------------------------------------------------------------------------------------
def convert(addr, length, size, burst, lock, cache):
    """Return dict of the M-side attributes and the pack flag. length = AxLEN (beats - 1)."""
    c = (length + 1) << size                     # wrap container in bytes (burst WRAP)
    pack = False
    if (cache >> 1) & 1 and lock == 0 and size == LS and burst in (INCR, WRAP):
        if burst == INCR:
            pack = True
        else:
            pack = (c < MB) or (addr % MB == 0)
    out = dict(addr=addr, len=length, size=size, burst=burst, pack=pack)
    if not pack:
        return out
    if burst == INCR:
        e = (addr >> LS << LS) + ((length + 1) << LS)
        n_m = -(-e // MB) - (addr // MB)
        out.update(size=LM, len=n_m - 1, burst=INCR)
    else:
        if c >= MB:
            n = c // MB
            out.update(size=LM, len=n - 1, burst=WRAP if n > 1 else INCR)
        else:
            out.update(addr=(addr // c) * c, size=LM, len=0, burst=INCR)
    return out


def beat_addr(a, size, length, burst, idx):
    nb = 1 << size
    if burst == FIXED or idx == 0:
        return a
    if burst == INCR:
        return (a // nb) * nb + idx * nb
    c = nb * (length + 1)
    base = (a // c) * c
    return base + ((a - base + idx * nb) % c)


def word_last(txn, idx):
    if not txn['pack']:
        return True
    o = txn['orig']
    if idx == o['length']:
        return True
    cur = beat_addr(o['addr'], o['size'], o['length'], o['burst'], idx)
    nxt = beat_addr(o['addr'], o['size'], o['length'], o['burst'], idx + 1)
    return cur // MB != nxt // MB


# ---------------------------------------------------------------------------------------------------------
# optimized forms of the same functions (specification section 10.2, "implementation form"): only shifts, masks,
# small adders and compares on the low address bits; no division, modulo or multiplication
# ---------------------------------------------------------------------------------------------------------
LR = LM - LS                       # log2 of the ratio
LA = max(LM, LS + 4)               # number of low address bits that the logic needs (LPARA_ADDR_LOW_W)


def convert_fast(addr, length, size, burst, lock, cache):
    r = RATIO
    bl = length + 1
    s0 = (addr >> LS) & (r - 1)                       # first slot
    small = bl < r                                    # container below M (used for WRAP only)
    pack = bool((cache >> 1) & 1) and lock == 0 and size == LS and (
        burst == INCR or (burst == WRAP and (small or (addr & (MB - 1)) == 0)))
    out = dict(addr=addr, len=length, size=size, burst=burst, pack=pack)
    if not pack:
        return out
    if burst == INCR:
        nm = (s0 + bl + r - 1) >> LR                  # number of M beats
        out.update(size=LM, len=nm - 1, burst=INCR)
    elif small:
        mask = (bl << LS) - 1                         # container bytes - 1 (bl is a power of 2)
        out.update(addr=addr & ~mask, size=LM, len=0, burst=INCR)
    else:
        n = bl >> LR
        out.update(size=LM, len=n - 1, burst=WRAP if n > 1 else INCR)
    return out


def slot_fast(addr, length, burst, idx):
    """slot of beat idx of a packable burst: counter and a wrap mask"""
    r = RATIO
    bl = length + 1
    s0 = (addr >> LS) & (r - 1)
    wm = (bl - 1) if (burst == WRAP and bl < r) else (r - 1)
    return (s0 & ~wm & (r - 1)) | ((s0 + idx) & wm)


def word_last_fast(addr, length, burst, idx):
    r = RATIO
    bl = length + 1
    whole = not (burst == WRAP and bl < r)
    return idx == length or (whole and slot_fast(addr, length, burst, idx) == r - 1)


def next_low_fast(cur, size, length, burst):
    """next beat address, low LA bits only, for a beat that is not packed (incremental)"""
    nb = 1 << size
    if burst == FIXED:
        return cur
    nxt = (cur & ~(nb - 1)) + nb
    if burst == WRAP:
        mask = ((length + 1) << size) - 1
        nxt = (cur & ~mask) | (nxt & mask)
    return nxt & ((1 << LA) - 1)


# ---------------------------------------------------------------------------------------------------------
class Slice:
    """Register slice with a registered ready (output register plus skid register), full throughput."""
    def __init__(self):
        self.v = False
        self.d = None
        self.sv = False
        self.sd = None
        self.rdy = False       # registered ready, 0 in reset, 1 from the second cycle after the release

    def reset(self):
        self.__init__()

    def ready_in(self):
        return self.rdy

    def step(self, iv, idata, out_ready):
        consumed = self.v and out_ready
        accept = iv and self.rdy
        v, d, sv, sd = self.v, self.d, self.sv, self.sd
        if sv:
            if consumed:
                v, d, sv, sd = True, sd, False, None
        else:
            if accept:
                if (not v) or consumed:
                    v, d = True, idata
                else:
                    sv, sd = True, idata
            elif consumed:
                v, d = False, None
        self.v, self.d, self.sv, self.sd = v, d, sv, sd
        self.rdy = not sv
        return accept, consumed


class Upsizer:
    """il = 0: AXI4 write path (in-order W). il >= 1: AXI3 write path with WID contexts, depth il."""

    def __init__(self, depth_w=4, depth_r=4, il=0):
        self.depth_w, self.depth_r, self.il = depth_w, depth_r, il
        self.zero = ('--', '0')
        self.reset()

    def reset(self):
        self.wq, self.rq = [], []
        self.w_idx = 0
        self.acc = {}          # slot -> (label, strobe)
        self.r_idx = 0
        self.word = None       # dict(slots=[labels], resp)
        self.w_stage = None    # AXI3 only: one S beat held between the S side and the contexts
        self.ctxs = []         # AXI3 only: active write contexts (one per interleaved WID)
        self.aw_sl, self.w_sl, self.b_sl = Slice(), Slice(), Slice()
        self.ar_sl, self.r_sl = Slice(), Slice()

    # combinational view of the current cycle --------------------------------------------------------
    def view(self, i):
        v = {}
        if self.il:
            outstanding = len(self.wq) + len(self.ctxs)
            v['awready'] = (outstanding < self.depth_w) and self.aw_sl.ready_in()
        else:
            v['awready'] = (len(self.wq) < self.depth_w) and self.aw_sl.ready_in()
        v['arready'] = (len(self.rq) < self.depth_r) and self.ar_sl.ready_in()
        head = self.wq[0] if self.wq else None
        v['w_head'] = head
        if self.il:
            can, ctx, bind = False, None, None
            st = self.w_stage
            if st:
                for c in self.ctxs:
                    if c['id'] == st['wid']:
                        ctx = c
                        break
                if ctx is None and len(self.ctxs) < self.il:
                    for e in self.wq:
                        if e['orig']['id'] == st['wid']:
                            bind = e
                            break
                txn = ctx['t'] if ctx else bind
                if txn is not None:
                    idx = ctx['idx'] if ctx else 0
                    can = (not word_last(txn, idx)) or self.w_sl.ready_in()
            v['w_can'], v['w_ctx'], v['w_bind'] = can, ctx, bind
            v['w_last_word'] = False
            v['wready'] = (self.w_stage is None or can) and (len(self.wq) > 0 or len(self.ctxs) > 0)
        elif head:
            v['w_last_word'] = word_last(head, self.w_idx)
            v['wready'] = (not v['w_last_word']) or self.w_sl.ready_in()
        else:
            v['w_last_word'] = False
            v['wready'] = False
        v['bready_m'] = self.b_sl.ready_in()
        rh = self.rq[0] if self.rq else None
        v['r_head'] = rh
        sx = False
        last_word = False
        txn_last = False
        if self.word is not None and rh:
            last_word = word_last(rh, self.r_idx)
            txn_last = (self.r_idx == rh['orig']['length'])
            sx = self.r_sl.ready_in()
        v['r_s_xfer'], v['r_last_word'], v['r_txn_last'] = sx, last_word, txn_last
        if self.word is None:
            ok = len(self.rq) >= 1
        else:
            if sx and last_word:
                ok = len(self.rq) >= (2 if txn_last else 1)
            else:
                ok = False
        v['rready_m'] = ok
        return v

    # clocked behavior -------------------------------------------------------------------------------
    def _slot_pay(self, acc, last, wid=None):
        zero = self.zero
        return dict(data=[acc.get(k, zero)[0] for k in range(SLOT_N)],
                    strb=(''.join(acc.get(k, zero)[1] for k in reversed(range(SLOT_N))) if isinstance(zero[1], str) else None),
                    strb_list=[acc.get(k, zero)[1] for k in range(SLOT_N)], last=last, wid=wid)

    def step(self, v, inp, sink):
        """inp: dict of S-side valid/payload and M-side responses; sink: ready of the outside neighbours."""
        aw_hs = inp['awvalid'] and v['awready']
        ar_hs = inp['arvalid'] and v['arready']
        w_hs = inp['wvalid'] and v['wready']
        mb_hs = inp['m_bvalid'] and v['bready_m']
        mr_hs = inp['m_rvalid'] and v['rready_m']
        # --- AW
        aw_m = None
        if aw_hs:
            a = dict(inp['aw'])
            aid = a.pop('id', 0)
            t = convert(**a)
            t['orig'] = dict(a, id=aid)
            t['id'] = aid
            self.wq.append(t)
            aw_m = dict(t)
        self.aw_sl.step(aw_hs, aw_m, sink['m_awready'])
        # --- W
        push, wpay = False, None
        if self.il:
            if self.w_stage and v['w_can']:
                st = self.w_stage
                if v['w_ctx'] is not None:
                    c = v['w_ctx']
                else:
                    e = v['w_bind']
                    self.wq.remove(e)
                    c = dict(id=st['wid'], t=e, idx=0, acc={})
                    self.ctxs.append(c)
                o = c['t']['orig']
                addr = beat_addr(o['addr'], o['size'], o['length'], o['burst'], c['idx'])
                c['acc'][(addr % MB) // SB] = (st['label'], st['strb'])
                if word_last(c['t'], c['idx']):
                    push = True
                    wpay = self._slot_pay(c['acc'], c['idx'] == o['length'], c['id'])
                    c['acc'] = {}
                if c['idx'] == o['length']:
                    self.ctxs.remove(c)
                else:
                    c['idx'] += 1
                self.w_stage = None
            if w_hs:
                self.w_stage = dict(inp['w'])
        else:
            head = v['w_head']
            if w_hs:
                o = head['orig']
                addr = beat_addr(o['addr'], o['size'], o['length'], o['burst'], self.w_idx)
                self.acc[(addr % MB) // SB] = (inp['w']['label'], inp['w']['strb'])
                if v['w_last_word']:
                    push = True
                    wpay = self._slot_pay(self.acc, self.w_idx == o['length'])
                    self.acc = {}
                if self.w_idx == o['length']:
                    self.wq.pop(0)
                    self.w_idx = 0
                else:
                    self.w_idx += 1
        self.w_sl.step(push, wpay, sink['m_wready'])
        # --- B
        self.b_sl.step(inp['m_bvalid'], inp['m_b'], sink['s_bready'])
        # --- AR
        ar_m = None
        if ar_hs:
            a = dict(inp['ar'])
            a.pop('id', None)
            t = convert(**a)
            t['orig'] = dict(a)
            self.rq.append(t)
            ar_m = dict(t)
        self.ar_sl.step(ar_hs, ar_m, sink['m_arready'])
        # --- R
        spush, spay = False, None
        rh = v['r_head']
        if v['r_s_xfer']:
            o = rh['orig']
            addr = beat_addr(o['addr'], o['size'], o['length'], o['burst'], self.r_idx)
            slot = (addr % MB) // SB
            spush = True
            spay = dict(data=self.word['slots'][slot], resp=self.word['resp'], last=v['r_txn_last'])
            if v['r_last_word']:
                self.word = None
            if v['r_txn_last']:
                self.rq.pop(0)
                self.r_idx = 0
            else:
                self.r_idx += 1
        self.r_sl.step(spush, spay, sink['s_rready'])
        if mr_hs:
            self.word = dict(slots=list(inp['m_r']['slots']), resp=inp['m_r']['resp'])
        return dict(aw_hs=aw_hs, ar_hs=ar_hs, w_hs=w_hs, mb_hs=mb_hs, mr_hs=mr_hs)
