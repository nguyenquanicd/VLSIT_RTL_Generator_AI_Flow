"""Writes the directed test scripts of the testbench into verification/vec/ (focused tests first, then
integrated flows, R-048). Every expected value comes from VLSIT_SHA2_SHA3_HASH_HDS.md (section and ID in the tag)
or from the standards, never from the RTL (R-023).
Run: python gen_directed.py
"""
import os
import random

import vec_lib as V

OUT = os.path.join(V.VER, 'vec')
ALL = V.ALL_ALGS

CTRL, CMD, LEN, DMAC, SEC = 0x008, 0x00C, 0x010, 0x014, 0x018
STS, LVL, DVLD, ERR, ERRA = 0x060, 0x064, 0x070, 0x074, 0x078
RAW, EN, INJ, ISTS = 0x0C0, 0x0C4, 0x0C8, 0x0CC
INIT, FINAL, ABORT, SRST, CLEAR = 1, 2, 4, 8, 16


def ctrl(code, ctx, dmaen=0, en=1):
    return (en & 1) | (code << 8) | (ctx << 16) | (dmaen << 25)


class T(V.Vec):
    def chk(self, a, mask, val, tag=None):
        if tag:
            self.add('tag %s' % tag)
        self.add('chka %03x %08x %08x' % (a, mask, val))

    def sel(self, code, ctx, dmaen=0):
        self.add('apbw %03x %08x' % (CTRL, ctrl(code, ctx, dmaen) | (self.mask << 24)))

    def cmd(self, c):
        self.add('apbw %03x %x' % (CMD, c))

    def clear_irq(self):
        self.add('apbw %03x ffffffff' % RAW)

    def srst(self):
        self.cmd(SRST)
        self.add('wait 30')

    def state(self, ctx, st, tag=None):
        self.sel(0, ctx)
        self.chk(STS, 0xF00, st << 8, tag)


# ---------------------------------------------------------------------------------------------
def apb_file(dw, ctxn, algs, zero=1):
    """TEST-010, REQ-IF-003, REQ-REG-001: reset values and every APB access case of section 11.4."""
    v = T(dw)
    wbit = {32: 0, 64: 1, 128: 2}[dw]
    cap0 = V.algmask(algs) | (ctxn << 16) | (wbit << 24) | (1 << 28)
    v.add('rstb 6')
    v.add('static 0 1')
    v.chk(0x000, 0xFFFFFFFF, cap0, 'APB_CAP0_reset_value_11.1')
    v.chk(CTRL, 0xFFFFFFFF, 0x00000100, 'APB_reset_ctrl')
    v.chk(LEN, 0xFFFFFFFF, 0, 'APB_reset_len')
    v.chk(DMAC, 0xFFFFFFFF, 0x00000010, 'APB_reset_dmac')
    v.chk(SEC, 0xFFFFFFFF, 0x00030001, 'APB_reset_sec')
    v.chk(STS, 0xFFF, 0x002, 'APB_reset_sts_idle')
    v.chk(LVL, 0xFFFFFFFF, 0, 'APB_reset_lvl')
    v.chk(RAW, 0xFFFFFFFF, 0, 'APB_reset_irq_raw')
    v.chk(EN, 0xFFFFFFFF, 0, 'APB_reset_irq_en')
    v.chk(ERR, 0xFFFFFFFF, 0, 'APB_reset_err')
    # Read-write register: write then read back (11.1)
    v.add('tag APB_rw_readback')
    v.add('apbw %03x 00000009' % LEN)
    v.chk(LEN, 0xFF, 9)
    v.add('apbw %03x 00000000' % LEN)
    # Read-only register: a write is ignored
    v.add('tag APB_ro_write_ignored')
    v.add('apbw 000 ffffffff')
    v.chk(0x000, 0xFFFFFFFF, cap0)
    # Write-only seed register reads 0 without error (11.4)
    v.add('tag APB_wo_seed_read_zero')
    v.add('apbr 020')
    v.add('chkerr 0')
    # Aligned address that is not a register: read 0 and OKAY, write ignored (11.4)
    v.add('tag APB_unmapped_aligned')
    v.add('apbwerr 040 deadbeef 0')
    v.add('apbr 040')
    v.add('chkerr 0')
    v.chk(0x040, 0xFFFFFFFF, 0)
    v.add('apbr 07c')
    v.add('chkerr 0')
    v.add('apbr 3fc')
    v.add('chkerr 0')
    # Not word aligned: PSLVERR with i_slverr_en = 1 (11.4)
    v.add('tag APB_unaligned_slverr')
    v.add('apbwerr 009 00000001 1')
    v.add('apbr 009')
    v.add('chkerr 1')
    v.add('apbr 00a')
    v.add('chkerr 1')
    v.add('apbr 00b')
    v.add('chkerr 1')
    # Partial strobe write: PSLVERR and no change (11.4)
    v.add('tag APB_partial_strobe_slverr')
    v.add('pstrbw 3')
    v.add('apbwerr %03x 0000005a 1' % LEN)
    v.chk(LEN, 0xFF, 0)
    v.add('pstrbw 8')
    v.add('apbwerr %03x 0000005a 1' % LEN)
    v.add('pstrbw 0')
    v.add('apbwerr %03x 0000005a 1' % LEN)
    v.chk(LEN, 0xFF, 0)
    v.add('pstrbw f')
    # Non-secure access with i_protect_en and i_slverr_en (11.4)
    v.add('tag APB_nonsecure_slverr')
    v.add('static 1 1')
    v.add('pprot 2')
    v.add('apbwerr %03x 00000004 1' % LEN)
    v.add('apbr %03x' % LEN)
    v.add('chkerr 1')
    v.add('apbr 000')
    v.add('chkerr 1')
    v.add('pprot 0')
    v.add('apbr %03x' % LEN)
    v.add('chkerr 0')
    v.chk(LEN, 0xFF, 0, 'APB_nonsecure_write_blocked')
    v.add('pprot 1')    # privileged secure access is legal
    v.add('apbwerr %03x 00000003 0' % LEN)
    v.chk(LEN, 0xFF, 3)
    v.add('pprot 0')
    v.add('apbw %03x 0' % LEN)
    # With i_slverr_en = 0 the partial write is a whole word write and no error is signalled (11.4)
    v.add('tag APB_slverr_disabled')
    v.add('static 1 0')
    v.add('pprot 2')
    v.add('apbwerr %03x 00000005 0' % LEN)
    v.add('pprot 0')
    v.add('static 0 0')
    v.add('pstrbw 3')
    v.add('apbwerr %03x 00000006 0' % LEN)
    v.add('pstrbw f')
    v.add('apbwerr 009 00000001 0')
    v.add('static 0 1')
    v.add('apbw %03x 0' % LEN)
    # Read of every mapped register once (X policy, 15.3): values must not be X
    v.add('tag APB_read_all_registers')
    for a in (0x000, 0x004, CTRL, CMD, LEN, DMAC, SEC, STS, LVL, 0x068, 0x06C, DVLD, ERR, ERRA, RAW, EN, INJ, ISTS):
        v.add('apbr %03x' % a)
        v.add('chkerr 0')
    v.add('end')
    return v


# ---------------------------------------------------------------------------------------------
def err_file(dw, ctxn, algs):
    """TEST-016 / ERR-001..004, TEST-009 error cases of 6.3, TEST-010."""
    v = T(dw)
    wb = dw // 8
    msg = [0x1111111111111111 & ((1 << dw) - 1)]

    def one_word(ctx):
        v.add('axiw %d 1 %s' % (ctx, v.hx(0xA5A5A5A5A5A5A5A5 & ((1 << dw) - 1))))

    # ERR-001: write to a context that is not absorbing (FREE)
    v.add('static 0 1')
    v.add('tag ERR-001_write_to_free_context')
    v.sel(1, 0)
    v.add('win 0')
    one_word(0)
    v.add('expb 2')
    v.chk(ERR, 0xFFFFFFFF, 0x00001100)
    v.chk(RAW, 1 << 16, 1 << 16)
    v.srst()
    v.chk(ERR, 0xFFFFFFFF, 0, 'ERR-001_record_cleared_by_soft_reset')
    v.chk(RAW, 1 << 16, 1 << 16, 'DEC-029_raw_event_stays_after_soft_reset')
    v.clear_irq()
    # ERR-002: read of an empty output FIFO
    v.add('tag ERR-002_read_empty_output')
    e2 = 1 if ctxn > 1 else 0
    v.sel(1, e2)
    v.add('rwin 1')
    v.add('rclr')
    v.add('axir %d 1' % e2)
    v.add('expr 0')
    v.add('expz 1')
    v.chk(ERR, 0xFFFFFFFF, 0x00100200 | e2)
    v.chk(RAW, 1 << 17, 1 << 17)
    v.clear_irq()
    v.chk(RAW, 0xFFFFFFFF, 0, 'ERR-002_w1c_clears_raw')
    v.srst()
    # ERR-003: write to a digest window (wrong direction), kind 3, address recorded
    v.add('tag ERR-003_write_digest_window')
    v.sel(1, 0)
    v.cmd(INIT)
    v.add('poll 060 f00 100 2000')
    v.add('win 1')
    one_word(0)
    v.add('win 0')
    v.add('expb 2')
    v.chk(ERR, 0xFFFFFFFF, 0x00000300)
    v.chk(ERRA, 0xFFFFFFFF, 0x00000800)
    v.chk(RAW, 1 << 18, 1 << 18)
    v.clear_irq()
    v.add('apbw %03x 1' % CMD) if False else None
    # ERR-003: read of a message window (wrong direction), kind 3, data 0
    v.add('tag ERR-003_read_message_window')
    v.add('rwin 0')
    v.add('rclr')
    v.add('axir 0 1')
    v.add('rwin 1')
    v.add('expr 2')
    v.add('expz 1')
    v.chk(ERR, 0xF00, 0x300)
    v.chk(RAW, 1 << 18, 1 << 18)
    v.clear_irq()
    v.srst()
    # Unsupported transactions inside an absorbing context: kind 4 (6.3), no word is pushed
    v.add('tag ERR-003_unsupported_write_kinds')
    for name, setup, undo in (
            ('wrap_burst', ['burst 2'], ['burst 1']),
            ('narrow_size', ['wsize %d' % max(0, (wb.bit_length() - 1) - 1)], ['wsize -1']),
            ('partial_wstrb', ['strb %x' % (((1 << wb) - 1) & ~1)], ['strb %x' % ((1 << wb) - 1)])):
        v.add('tag ERR-003_write_%s' % name)
        v.sel(1, 0)
        v.cmd(INIT)
        v.add('poll 060 f00 100 2000')
        for s in setup:
            v.add(s)
        v.add('axiw 0 2 %s %s' % (v.hx(1), v.hx(2)))
        for s in undo:
            v.add(s)
        v.add('expb 2')
        v.chk(ERR, 0xF00, 0x400)
        v.chk(ERRA, 0xFFFFFFFF, 0)
        v.chk(RAW, 1 << 18, 1 << 18)
        v.chk(LVL, 0xFFFF, 0, 'ERR-003_no_word_pushed_%s' % name)
        v.clear_irq()
        v.srst()
    # Context number out of range: SLVERR and no change in the other contexts
    v.add('tag ERR-003_context_out_of_range')
    v.sel(1, 0)
    v.cmd(INIT)
    v.add('poll 060 f00 100 2000')
    if ctxn < 16:                              # with 16 contexts every window number of the 4-bit field exists
        v.add('axiw %d 1 %s' % (ctxn, v.hx(3)))
        v.add('expb 2')
        v.chk(RAW, 1 << 18, 1 << 18)
    v.chk(LVL, 0xFFFF, 0)
    v.clear_irq()
    v.srst()
    # Unsupported reads of the digest window of a context with a digest (WRAP and narrow size)
    v.add('tag ERR-003_unsupported_read_kinds')
    v.hash(1, b'abc', 0, 0, 'ERR-003_prepare_digest', exp=V.digest(1, b'abc'))
    # (the digest was read by the call above; use a new digest that stays unread)
    v.sel(1, 0)
    v.cmd(INIT)
    v.add('poll 060 f00 100 2000')
    v.add('axiw 0 1 %s' % v.hx(0x636261))
    v.add('apbw %03x 3' % LEN)
    v.cmd(FINAL)
    v.add('poll 060 4 4 20000')
    v.add('rwin 1')
    v.add('rburst 2')
    v.add('rclr')
    v.add('axir 0 1')
    v.add('rburst 1')
    v.add('expr 2')
    v.add('expz 1')
    v.chk(ERR, 0xF00, 0x400, 'ERR-003_read_wrap_kind4')
    v.add('rsize 1')
    v.add('rclr')
    v.add('axir 0 1')
    v.add('rsize -1')
    v.add('expr 2')
    v.add('expz 1')
    v.chk(RAW, 1 << 18, 1 << 18)
    v.clear_irq()
    v.chk(LVL, 0xFFFF0000, (32 if False else (32 // wb)) << 16, 'ERR-003_rejected_read_pops_nothing')
    v.cmd(ABORT)
    v.srst()
    # ERR-004: rejected commands and values (12): no state change, cfg event
    v.add('tag ERR-004_init_algorithm_not_built')
    v.add('apbw %03x %08x' % (CTRL, ctrl(6, 0)))
    v.cmd(INIT)
    v.add('wait 20')
    v.chk(RAW, 1 << 19, 1 << 19)
    v.chk(STS, 0xF00, 0)
    v.clear_irq()
    v.add('tag ERR-004_init_busy_context')
    v.sel(1, 0)
    v.cmd(INIT)
    v.add('poll 060 f00 100 2000')
    v.cmd(INIT)
    v.add('wait 20')
    v.chk(RAW, 1 << 19, 1 << 19)
    v.chk(STS, 0xF00, 0x100)
    v.clear_irq()
    v.add('tag ERR-004_final_while_free')
    v.sel(1, 1)
    v.cmd(FINAL)
    v.add('wait 20')
    v.chk(RAW, 1 << 19, 1 << 19)
    v.chk(STS, 0xF00, 0)
    v.clear_irq()
    v.add('tag ERR-004_context_select_out_of_range')
    v.add('apbw %03x %08x' % (CTRL, ctrl(1, min(ctxn, 15))))
    v.cmd(INIT)
    v.add('wait 20')
    v.chk(RAW, 1 << 19, 1 << 19) if ctxn < 16 else None
    v.clear_irq()
    v.add('tag ERR-004_tail_too_large')
    v.sel(1, 0)
    v.add('apbw %03x %x' % (LEN, wb + 1))
    v.cmd(FINAL)
    v.add('wait 30')
    v.chk(RAW, 1 << 19, 1 << 19)
    v.chk(STS, 0xF00, 0x100)
    v.clear_irq()
    v.add('apbw %03x 0' % LEN)
    v.cmd(ABORT)
    v.srst()
    v.add('end')
    return v


# ---------------------------------------------------------------------------------------------
def irq_file(dw, ctxn, algs):
    """TEST-017 / REQ-INT-001: events, enable, injection, clear; o_irq equals the OR of raw AND enable."""
    v = T(dw)
    v.add('tag IRQ_reset_state')
    v.add('chkirq 0')
    v.add('chkalarm 0')
    v.add('tag IRQ_inject_without_enable')
    v.add('apbw %03x %08x' % (INJ, 1 << 16))
    v.chk(RAW, 1 << 16, 1 << 16)
    v.chk(ISTS, 0xFFFFFFFF, 0)
    v.add('chkirq 0')
    v.add('tag IRQ_enable_sets_o_irq')
    v.add('apbw %03x %08x' % (EN, 1 << 16))
    v.chk(ISTS, 0xFFFFFFFF, 1 << 16)
    v.add('chkirq 1')
    v.add('tag IRQ_clear_with_injection_held')
    v.clear_irq()
    v.chk(RAW, 0xFFFFFFFF, 0)
    v.add('chkirq 0')       # a rising edge injects once: the held bit does not set the event again
    v.add('apbw %03x 0' % INJ)
    v.add('apbw %03x %08x' % (INJ, 1 << 16))
    v.chk(RAW, 1 << 16, 1 << 16)
    v.add('chkirq 1')
    v.add('apbw %03x 0' % INJ)
    v.clear_irq()
    v.add('apbw %03x 0' % EN)
    for bit, name in ((17, 'udf'), (18, 'axi'), (19, 'cfg'), (20, 'flt'), (21, 'ent'), (22, 'tmo'), (23, 'len')):
        v.add('tag IRQ_inject_%s' % name)
        v.add('apbw %03x %08x' % (EN, 1 << bit))
        v.add('apbw %03x %08x' % (INJ, 1 << bit))
        v.add('chkirq 1')
        v.chk(RAW, 1 << bit, 1 << bit)
        v.add('apbw %03x 0' % INJ)
        v.clear_irq()
        v.add('chkirq 0')
    v.add('tag IRQ_enable_mask_only_enabled_bits')
    v.add('apbw %03x %08x' % (EN, 1 << 17))
    v.add('apbw %03x %08x' % (INJ, 1 << 18))
    v.add('chkirq 0')
    v.chk(RAW, 1 << 18, 1 << 18)
    v.add('apbw %03x %08x' % (EN, (1 << 17) | (1 << 18)))
    v.add('chkirq 1')
    v.add('apbw %03x 0' % INJ)
    v.clear_irq()
    v.add('apbw %03x 0' % EN)
    v.add('tag IRQ_cdone_each_context_by_injection')
    for c in range(ctxn):
        v.add('apbw %03x %08x' % (EN, 1 << c))
        v.add('apbw %03x %08x' % (INJ, 1 << c))
        v.chk(RAW, 0xFFFF, 1 << c)
        v.add('chkirq 1')
        v.add('apbw %03x 0' % INJ)
        v.clear_irq()
    v.add('apbw %03x 0' % EN)
    # Real event: message done sets cdone of its context
    rng = random.Random(3)
    for c in range(min(ctxn, 4)):
        v.add('tag IRQ_cdone_real_event_ctx%d' % c)
        v.add('apbw %03x %08x' % (EN, 1 << c))
        v.hash(1, V.rnd_msg(rng, 40), c, 0, 'IRQ_real_cdone_hash_ctx%d' % c, exp=None)
        v.add('chkirq 1') if False else None
        v.chk(RAW, 0xFFFF, 1 << c)
        v.add('chkirq 1')
        v.clear_irq()
        v.add('chkirq 0')
        v.add('apbw %03x 0' % EN)
    v.add('end')
    return v


# ---------------------------------------------------------------------------------------------
def abort_file(dw, ctxn, algs):
    """TEST-007, TEST-014: abort and soft reset in each state; resets in each domain; reset in a burst."""
    v = T(dw)
    wb = dw // 8
    rng = random.Random(4)
    msg = V.rnd_msg(rng, 300)
    # abort in FREE
    v.add('tag ABORT_in_free')
    v.sel(1, 0)
    v.cmd(ABORT)
    v.add('wait 10')
    v.state(0, 0)
    # abort in ABSORBING with words in the FIFO
    v.add('tag ABORT_in_absorbing')
    v.sel(1, 0)
    v.cmd(INIT)
    v.add('poll 060 f00 100 2000')
    v.add('axiw 0 3 %s %s %s' % (v.hx(1), v.hx(2), v.hx(3)))
    v.cmd(ABORT)
    v.add('wait 20')
    v.state(0, 0)
    v.chk(LVL, 0xFFFFFFFF, 0)
    v.hash(1, b'abc', 0, 0, 'ABORT_then_hash_ok_after_absorbing')
    # abort while the core computes (FIN)
    v.add('tag ABORT_in_final_busy')
    v.sel(1, 0)
    v.cmd(INIT)
    v.add('poll 060 f00 100 2000')
    big = V.rnd_msg(rng, 2000)
    v.feed(0, big)
    v.add('apbw %03x 0' % LEN)
    v.cmd(FINAL)
    v.cmd(ABORT)
    v.add('wait 50')
    v.state(0, 0)
    v.chk(LVL, 0xFFFFFFFF, 0)
    v.chk(STS, 0x3, 0x2)
    v.hash(1, msg, 0, 0, 'ABORT_then_hash_ok_after_final')
    # abort in RDY (digest not read)
    v.add('tag ABORT_in_digest_ready')
    v.sel(1, 0)
    v.cmd(INIT)
    v.add('poll 060 f00 100 2000')
    v.feed(0, b'abc')
    v.add('apbw %03x 3' % LEN)
    v.cmd(FINAL)
    v.add('poll 060 4 4 20000')
    v.chk(STS, 0xF00, 0x300)
    v.cmd(ABORT)
    v.add('wait 20')
    v.state(0, 0)
    v.chk(LVL, 0xFFFFFFFF, 0)
    # SHAKE squeezing
    if 12 in algs:
        v.add('tag ABORT_in_squeeze')
        v.sel(12, 0)
        v.cmd(INIT)
        v.add('poll 060 f00 100 2000')
        v.feed(0, b'xyz')
        v.add('apbw %03x 3' % LEN)
        v.cmd(FINAL)
        v.add('poll 060 4 4 20000')
        v.add('wait 200')
        v.cmd(ABORT)
        v.add('wait 20')
        v.state(0, 0)
        v.chk(LVL, 0xFFFFFFFF, 0)
    if 12 in algs:
        # DEC-030: abort cancels the work of the context: init is accepted right after the abort of a SHAKE context
        # (the block that the core was computing for it is stopped and cleared)
        m25 = V.rnd_msg(random.Random(21), 25)
        v.add('tag ABORT_init_20_cycles_after_abort_of_shake')
        v.start(12, 0)
        v.feed(0, m25)
        v.finish(12, 0, len(m25))
        v.collect(12, 0, V.digest(12, m25, 30), 'ABORT_shake_digest')
        v.add('apbw 008 %08x' % (1 | (12 << 8)))
        v.cmd(ABORT)
        v.add('wait 20')
        v.cmd(INIT)
        v.add('poll 060 f00 100 300')
        v.chk(RAW, 1 << 19, 0, 'ABORT_no_cfg_event_after_init')
        v.cmd(ABORT)
        v.add('poll 060 3 2 20000')
        v.clear_irq()
    # soft reset with several contexts in different states
    v.add('tag SRST_all_contexts')
    for c in range(min(ctxn, 3)):
        v.sel(1, c)
        v.cmd(INIT)
        v.add('poll 060 f00 100 2000')
        v.add('axiw %d 2 %s %s' % (c, v.hx(5), v.hx(6)))
    v.add('apbw %03x 0000%02x0f' % (INJ, 0) if False else 'wait 1')
    v.srst()
    for c in range(ctxn):
        v.sel(1, c)
        v.chk(STS, 0xF00, 0, 'SRST_context_%d_free' % c)
        v.chk(LVL, 0xFFFFFFFF, 0)
    v.chk(ERR, 0xFFFFFFFF, 0, 'SRST_clears_error_record')
    v.chk(SEC, 0xFFFFFFFF, 0x00030001, 'SRST_keeps_security_register')
    v.add('apbw %03x 0000000d' % CTRL if False else 'wait 1')
    v.hash(1, msg, 0, 0, 'SRST_then_hash_ok')
    # srst keeps the control register (algo, ctxsel, dmaen)
    v.add('tag SRST_keeps_control_register')
    v.add('apbw %03x %08x' % (CTRL, ctrl(9, 2)))
    v.srst()
    v.chk(CTRL, 0xFFFFFFFF, ctrl(9, 2))
    # --- TEST-014 resets
    # With PARA_CSR_ASYNC = 1 the register side is in the core domain (7.3): an APB reset leaves the register values, a core reset
    # returns them to the reset values. With PARA_CSR_ASYNC = 0 the two reset ports are tied, both resets act on everything.
    v.add('tag RST_apb_domain_only')
    v.add('apbw %03x %08x' % (CTRL, ctrl(1, 0)))
    v.add('rsta 6')
    v.add('chkaif %03x ffffffff %08x 00000100' % (CTRL, ctrl(1, 0)))
    v.add('tag RST_core_domain_only')
    v.add('apbw %03x %08x' % (CTRL, ctrl(1, 0)))
    v.add('rstc 6')
    v.chk(CTRL, 0xFFFFFFFF, 0x00000100)
    v.add('tag RST_both_domains')
    v.add('apbw %03x %08x' % (DMAC, 0x00050007))
    v.add('rstb 6')
    v.chk(DMAC, 0xFFFFFFFF, 0x00000010)
    v.chk(STS, 0xFFF, 0x002)
    v.hash(1, msg, 0, 0, 'RST_then_hash_ok')
    # reset in the middle of a write burst: the burst is abandoned, registers return to reset values
    v.add('tag RST_in_write_burst')
    v.sel(1, 0)
    v.cmd(INIT)
    v.add('poll 060 f00 100 2000')
    v.add('axiabort 0 8 3')
    v.chk(STS, 0xF00, 0)
    v.chk(LVL, 0xFFFFFFFF, 0)
    v.chk(RAW, 0xFFFFFFFF, 0)
    v.hash(1, b'a' * 100, 0, 0, 'RST_burst_then_hash_ok')
    v.add('end')
    return v


# ---------------------------------------------------------------------------------------------
def open_file(dw, ctxn, algs):
    """Behaviors where the RTL and the specification text disagree or the text is ambiguous (decision pending, R-026).
    These tests are expected to FAIL until the designer decides; they are not part of the default regression."""
    v = T(dw)
    msg = V.rnd_msg(random.Random(4), 300)
    big = V.rnd_msg(random.Random(5), 2000)
    # OPEN-02: ERR-001 row of section 12 says the event is cleared by the soft reset command
    v.add('tag OPEN-02_ERR-001_raw_event_cleared_by_soft_reset')
    v.sel(1, 0)
    v.add('win 0')
    v.add('axiw 0 1 %s' % v.hx(0x1234))
    v.chk(RAW, 1 << 16, 1 << 16)
    v.srst()
    v.chk(RAW, 0xFFFFFFFF, 0)
    # OPEN-03: REQ-SEC-001 and 7.3: the core registers are zero when no context is active
    v.add('tag OPEN-03_core_registers_zero_after_reset_in_computation')
    v.sel(1, 0)
    v.cmd(INIT)
    v.add('poll 060 f00 100 2000')
    v.feed(0, big)
    v.add('apbw %03x 0' % LEN)
    v.cmd(FINAL)
    v.add('wait 40')
    v.add('rstb 6')
    v.add('wait 10')
    v.add('chkcz 1')
    v.hash(3, msg, 0, 0, 'OPEN-03_hash_after_reset_in_computation')
    # OPEN-04: SHAKE message of 25 bytes, 30 output bytes read, abort, 20 cycles later a new init. OP-006 says the context is FREE
    # 2 cycles after the abort and OP-001 accepts init in FREE; the RTL rejects the init (configuration event) because the core
    # still computes a squeeze block of the aborted context. (A message of 24 bytes does not show it: the timing depends on the length.)
    m25 = V.rnd_msg(random.Random(21), 25)
    v.add('tag OPEN-04_init_20_cycles_after_abort_of_shake')
    v.start(12, 0)
    v.feed(0, m25)
    v.finish(12, 0, len(m25))
    v.collect(12, 0, V.digest(12, m25, 30), 'OPEN-04_shake_digest')
    v.add('apbw 008 %08x' % (1 | (12 << 8)))
    v.cmd(ABORT)
    v.add('wait 20')
    v.cmd(INIT)
    v.add('poll 060 f00 100 300')
    v.chk(RAW, 1 << 19, 0, 'OPEN-04_cfg_event_after_init')
    v.add('end')
    return v


def tail_file(dw, algs):
    """TEST-003, TEST-004: every tail value, lengths around the padding boundary, empty message."""
    v = T(dw)
    wb = dw // 8
    rng = random.Random(21)
    lens = set(range(0, 2 * wb + 2))
    for c in algs:
        r = V.BLK[c]
        for base in (r, 2 * r):
            lens.update([base - 17, base - 9, base - 8, base - 1, base, base + 1, base + 7])
        # SHA-2 padding needs 9 (SHA-256 family) or 17 (SHA-512 family) bytes: edges at 55/56 and 111/112
        if c < 6:
            m = 9 if c < 2 else 17
            lens.update([r - m - 1, r - m, r - m + 1])
    lens = sorted(x for x in lens if x >= 0)
    for c in (1, 3, 9, 12):
        if c not in algs:
            continue
        for ln in lens:
            nout = 30 if c >= 12 else 0
            v.hash(c, V.rnd_msg(rng, ln), 0, nout, 'TAIL_%s_len%d' % (V.ALGNAME[c], ln))
    v.add('end')
    return v


def bp_file(dw, algs, ctxn=4):
    """TEST-009: legal traffic with random AXI back pressure and gaps, all IDs, FIXED and INCR bursts."""
    v = T(dw)
    rng = random.Random(33)
    v.add('bp 1')
    for i in range(6):
        for c in (1, 3, 9, 12):
            if c in algs:
                ln = rng.randrange(0, 400)
                v.add('awid %d' % rng.randrange(16))
                v.hash(c, V.rnd_msg(rng, ln), 0, 25 if c >= 12 else 0, 'BP_%s_%d' % (V.ALGNAME[c], i),
                       burst=rng.choice([1, 3, 8, 16]))
    v.add('awid 0')
    # two read bursts back to back with throttled RREADY: the second address waits (AXI stall rules, REQ-IF-001)
    v.add('tag AXI_read_address_stall')
    v.add('rwin 1')
    v.add('rclr')
    v.add('axir2 %d 4 3' % min(2, ctxn - 1))
    v.add('expr 0')
    v.add('rclr')
    v.srst()
    # FIXED burst of the message window: the offset is not used, words still go to the FIFO in order (6.3)
    v.add('tag FIXED_burst_message_window')
    v.add('burst 0')
    v.add('rburst 0')
    msg = V.rnd_msg(rng, 4 * (dw // 8))
    v.hash(1, msg, 0, 0, 'FIXED_burst_hash')
    v.add('burst 1')
    v.add('rburst 1')
    # maximum burst length of 256 beats into the window, then abort (the data are not a message of interest)
    v.add('tag LONG_burst_awlen_255')
    v.add('bp 0')
    v.sel(1, 0)
    v.cmd(INIT)
    v.add('poll 060 f00 100 2000')
    v.add('axiwx 0 128')
    v.cmd(ABORT)
    v.add('wait 20')
    v.add('end')
    return v


def multi2_file(dw, algs, ctxn):
    v = T(dw)
    import gen_vectors as G
    n = G.multi_file(dw, algs, ctxn, os.path.join(OUT, 'multi_more.vec'), seed=77, rounds=12)
    return None


# ---------------------------------------------------------------------------------------------
def dma_file(dw, ctxn):
    """TEST-011 / REQ-IF-004: 4-phase handshake, burst size, burst timeout and padding (section 6.3, IF-003).
    The testbench DMA controller acknowledges every request after a delay; the data are moved by the script."""
    v = T(dw)
    wb = dw // 8
    rng = random.Random(8)
    v.add('dmaman 1')
    dwords = lambda n: n * wb
    # illegal burst sizes: the request is not raised and the cfg event is set (sha_dmac limits)
    for bad in (0, 0x101):
        v.add('tag DMA_illegal_burst_%x' % bad)
        v.add('apbw %03x 00000008' % DMAC)
        v.add('apbw %03x %08x' % (CTRL, ctrl(1, 0)))
        v.add('wait 10')
        v.add('apbw %03x %08x' % (DMAC, bad))
        v.add('apbw %03x %08x' % (CTRL, ctrl(1, 0, dmaen=1)))
        v.cmd(INIT)
        v.add('poll 060 f00 100 2000')
        v.add('wait 300')
        v.chk(RAW, 1 << 19, 1 << 19)
        v.add('chkreq 0 0')
        v.clear_irq()
        v.cmd(ABORT)
        v.add('poll 060 3 2 20000')
    # DMA disabled: no request even when the FIFO can take a burst
    v.add('tag DMA_disabled_no_request')
    v.add('apbw %03x 00000008' % DMAC)
    v.sel(1, 0)
    v.cmd(INIT)
    v.add('poll 060 f00 100 2000')
    v.add('wait 300')
    v.add('chkreq 0 0')
    v.cmd(ABORT)
    v.add('poll 060 3 2 20000')
    # input and output handshakes with full bursts (SHA-512, digest of 64 bytes)
    third = 8 if dw == 128 else 9           # SHA3-224 is the only SHA-3 algorithm legal on a 128-bit bus (DEC-019)
    for burst, code, msglen in ((8, 3, 1024), (4, 1, 512), (16, third, 1088), (2, 0, 128)):
        dig = V.DLEN[code]
        nw_dig = (dig + wb - 1) // wb
        msg = V.rnd_msg(rng, msglen)
        v.add('tag DMA_full_burst%d_%s' % (burst, V.ALGNAME[code]))
        v.add('apbw %03x %08x' % (DMAC, burst))
        v.add('apbw %03x %08x' % (CTRL, ctrl(code, 0, dmaen=1)))
        v.cmd(INIT)
        v.add('poll 060 f00 100 2000')
        ws = V.words(msg, wb)
        for i in range(0, len(ws), burst):
            ch = ws[i:i + burst]
            if len(ch) == burst:
                v.add('waitin')
            v.add('axiw 0 %d %s' % (len(ch), ' '.join(v.hx(w) for w in ch)))
        v.add('apbw %03x %x' % (LEN, msglen % wb))
        v.cmd(FINAL)
        v.add('poll 060 4 4 20000')
        v.add('apbw %03x 0' % LEN)
        # output: a request when the FIFO holds a whole burst, else after the timeout
        if nw_dig >= burst:
            v.add('waitout')
            v.chk(DVLD, 0x1FF, 0)
            v.add('tag DMA_out_%d_words' % burst)
            ew = V.words(V.digest(code, msg), wb)
            v.add('rclr')
            for i in range(0, nw_dig, burst):
                n = min(burst, nw_dig - i)
                v.add('axir 0 %d' % n)
            v.add('expect %d %d %s' % (dig, nw_dig, ' '.join(v.hx(w) for w in ew)))
        else:
            v.add('rclr')
            v.add('axir 0 %d' % nw_dig)
            v.add('expect %d %d %s' % (dig, nw_dig, ' '.join(v.hx(w) for w in V.words(V.digest(code, msg), wb))))
        v.add('chkdma 1 1') if False else None
        v.add('apbw %03x 0' % CMD) if False else None
        v.cmd(ABORT)
        v.add('poll 060 3 2 20000')
    # timeout: a digest shorter than the burst is padded with zero words; sha_dvld.words gives the valid count
    msg = V.rnd_msg(rng, 77)
    code = 1
    nw_dig = (32 + wb - 1) // wb
    burst = 8 if nw_dig < 8 else nw_dig * 2
    v.add('tag DMA_timeout_padded_burst')
    v.add('apbw %03x %08x' % (DMAC, (200 << 16) | burst))
    v.add('apbw %03x %08x' % (CTRL, ctrl(code, 0, dmaen=1)))
    v.cmd(INIT)
    v.add('poll 060 f00 100 2000')
    ws = V.words(msg, wb)
    v.add('axiw 0 %d %s' % (len(ws), ' '.join(v.hx(w) for w in ws)))
    v.add('apbw %03x %x' % (LEN, 77 % wb))
    v.cmd(FINAL)
    v.add('poll 060 4 4 20000')
    v.add('waitout')
    v.chk(DVLD, 0x1FF, nw_dig, 'DMA_timeout_valid_words')
    v.chk(RAW, 1 << 22, 1 << 22, 'DMA_timeout_event')
    ew = V.words(V.digest(code, msg), wb) + [0] * (burst - nw_dig)
    v.add('rclr')
    v.add('axir 0 %d' % burst)
    v.add('expect %d %d %s' % (burst * wb, burst, ' '.join(v.hx(w) for w in ew)))
    v.chk(LVL, 0xFFFF0000, 0, 'DMA_timeout_burst_empties_fifo')
    v.clear_irq()
    v.cmd(ABORT)
    v.add('poll 060 3 2 20000')
    v.add('end')
    return v


def open_dma_file(dw):
    """OPEN-07: section 6.3 says the DMA request stays high until the acknowledge; the RTL withdraws it when the
    context is aborted or finalized. Expected to FAIL until the designer decides (R-026)."""
    v = T(dw)
    v.add('dmaman 1')
    v.add('tag OPEN-07_dma_request_withdrawn_by_abort')
    v.add('apbw %03x 00000008' % DMAC)
    v.add('apbw %03x %08x' % (CTRL, ctrl(1, 0, dmaen=1)))
    v.cmd(INIT)
    v.add('poll 060 f00 100 2000')
    v.add('wait 60')
    v.add('chkreq 1 0')
    v.cmd(ABORT)
    v.add('wait 20')
    v.add('end')
    return v


def limit_file(dw, algs):
    """TEST-008, REQ-FUNC-009: a message above 2^61 - 1 bytes sets the length-limit event and its digest is discarded. The limit cannot
    be shortened (no test parameter), so the byte counter of the context is preset near the limit with `ctot` (force, one cycle)."""
    v = T(dw)
    wb = dw // 8
    LEN_EV = 1 << 23
    for code in [c for c in (1, 3, 9, 12) if c in algs]:
        v.add('rstb 6')
        v.add('static 0 1')
        v.add('tag LIMIT_%s_below_limit_no_event' % V.ALGNAME[code])
        v.sel(code, 0)
        v.cmd(INIT)
        v.add('poll 060 f00 100 2000')
        v.add('ctot 0 %016x' % ((1 << 61) - 4 * wb))
        v.add('axiw 0 2 %s' % ' '.join(v.hx(0x100 + i) for i in range(2)))     # counter = limit - 2 words: still legal
        v.add('wait 40')
        v.chk(RAW, LEN_EV, 0, 'LIMIT_%s_two_words_below_no_event' % V.ALGNAME[code])
        v.add('tag LIMIT_%s_above_limit' % V.ALGNAME[code])
        v.add('axiw 0 4 %s' % ' '.join(v.hx(0x200 + i) for i in range(4)))     # counter reaches 2^61
        v.add('wait 80')
        v.chk(RAW, LEN_EV, LEN_EV, 'LIMIT_%s_event' % V.ALGNAME[code])
        v.chk(STS, 0xF00, 0, 'LIMIT_%s_context_freed' % V.ALGNAME[code])
        v.chk(LVL, 0xFFFF, 0, 'LIMIT_%s_no_digest_word' % V.ALGNAME[code])
        v.clear_irq()
        v.chk(RAW, LEN_EV, 0, 'LIMIT_%s_event_cleared' % V.ALGNAME[code])
        # the context works again with a short message
        v.hash(code, b'abc', 0, 20 if code >= 12 else 0, 'LIMIT_%s_digest_after_limit' % V.ALGNAME[code])
        v.srst()
    v.add('end')
    return v


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    cfgs = {'dw64': (64, 4, ALL), 'dw32': (32, 4, ALL), 'dw128': (128, 4, [0, 1, 2, 3, 4, 5, 8])}
    for name, (dw, ctxn, algs) in cfgs.items():
        apb_file(dw, ctxn, algs).save(os.path.join(OUT, 'dir_apb_%s.vec' % name))
        err_file(dw, ctxn, algs).save(os.path.join(OUT, 'dir_err_%s.vec' % name))
        irq_file(dw, ctxn, algs).save(os.path.join(OUT, 'dir_irq_%s.vec' % name))
        abort_file(dw, ctxn, algs).save(os.path.join(OUT, 'dir_abort_%s.vec' % name))
        tail_file(dw, algs).save(os.path.join(OUT, 'dir_tail_%s.vec' % name))
        bp_file(dw, algs).save(os.path.join(OUT, 'dir_bp_%s.vec' % name))
    # other context counts (COV-006): the files that depend on the number of contexts
    for n in (1, 2, 16):
        for kind, fn in (('apb', apb_file), ('err', err_file), ('irq', irq_file), ('abort', abort_file)):
            fn(64, n, ALL).save(os.path.join(OUT, 'dir_%s_c%d_dw64.vec' % (kind, n)))
    for n in (1, 2, 16):
        bp_file(64, ALL, n).save(os.path.join(OUT, 'dir_bp_c%d_dw64.vec' % n))
    for dw in (32, 64, 128):
        dma_file(dw, 4).save(os.path.join(OUT, 'dir_dma_dw%d.vec' % dw))
    open_dma_file(64).save(os.path.join(OUT, 'open_dma_dw64.vec'))
    limit_file(64, ALL).save(os.path.join(OUT, 'dir_limit_dw64.vec'))
    print('directed vectors written')


