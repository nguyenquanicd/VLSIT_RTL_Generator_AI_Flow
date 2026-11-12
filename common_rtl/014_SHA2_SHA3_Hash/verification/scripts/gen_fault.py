"""Fault-detection test scripts (TEST-020, REQ-SEC-002): a bit flip of a core register is injected by force, the
detection mechanism of the configuration shall raise the fault event, apply the responses of sha_sec.resp and keep the
digest of the faulty block from being returned (DEC-033 to DEC-035). Expected values come from section 6.4, 11, 12, 18.
Run: python gen_fault.py
"""
import os
import random

import vec_lib as V
from gen_directed import T, CTRL, CMD, LEN, STS, RAW, INIT, FINAL, ABORT, SRST, SEC, ctrl

OUT = os.path.join(V.VER, 'vec')
FLT = 1 << 20
CFG = 1 << 19


def sec(resp, dup=0, par=0, redo=0, fault=1):
    return (resp << 16) | (redo << 10) | (par << 9) | (dup << 8) | (fault << 4) | 1


def case(v, tag, code, tgt, resp, msg, mech, dly=10, bit=5, inject=True):
    """One injected fault with the responses `resp`; mech = (dup, par, redo)."""
    dup, par, redo = mech
    v.add('tag F_%s' % tag)
    v.add('apbw %03x %08x' % (CMD, SRST))
    v.add('wait 20')
    v.add('apbw %03x %08x' % (RAW, 0xFFFFFFFF))
    v.add('apbw %03x %08x' % (SEC, sec(resp, dup, par, redo)))
    v.sel(code, 0)
    v.cmd(INIT)
    v.add('poll 060 f00 100 2000')
    if inject:
        v.add('inj %d %d %d' % (tgt, dly, bit))
    v.feed(0, msg)
    v.add('apbw %03x %x' % (LEN, len(msg) % v.wb))
    v.cmd(FINAL)
    v.add('wait 3000')
    if inject:
        v.add('chkinj_inc')
    cst = 0 if resp & 4 else 0xF
    v.chk(RAW, FLT, FLT, 'F_%s_fault_event' % tag)
    v.chk(STS, 0xF00, cst << 8, 'F_%s_context_state' % tag)
    v.chk(STS, 0x8, 0x8 if resp & 2 else 0, 'F_%s_locked' % tag)
    v.add('chkalarm %d' % (1 if resp & 8 else 0))
    if resp & 2:
        v.add('tag F_%s_lock_rejects' % tag)
        v.cmd(INIT)
        v.add('wait 20')
        v.chk(RAW, CFG, CFG)
        v.add('win 0')
        v.add('axiw 0 1 %s' % v.hx(7))
        v.add('expb 2')
    if resp & 1:
        v.add('tag F_%s_gate_rejects_digest_read' % tag)
        v.add('rwin 1')
        v.add('rclr')
        v.add('axir 0 1')
        v.add('expr 2')
        v.add('expz 1')
    if resp == 0:
        v.cmd(ABORT)
        v.add('poll 060 3 2 20000')
        v.chk(STS, 0xF00, 0, 'F_%s_abort_frees_faulty_context' % tag)
    # recovery by the soft reset command, then a correct hash with the detection still on
    v.cmd(SRST)
    v.add('wait 20')
    v.chk(STS, 0x8, 0, 'F_%s_unlocked_by_soft_reset' % tag)
    v.add('chkalarm 0')
    v.add('apbw %03x %08x' % (RAW, 0xFFFFFFFF))
    v.hash(code, msg, 0, 25 if code >= 12 else 0, 'F_%s_digest_after_recovery' % tag)
    v.chk(RAW, FLT, 0, 'F_%s_no_false_fault_after_recovery' % tag)


def fault_file(dw, algs, mech, name):
    v = T(dw)
    rng = random.Random(77)
    dup, par, redo = mech
    msg = lambda n: V.rnd_msg(rng, n)
    # 1. detection on, no fault: digests are right and no event (no false positive)
    v.add('tag F_baseline_no_fault')
    v.add('apbw %03x %08x' % (SEC, sec(3, dup, par, redo)))
    for c in (1, 3, 9, 12):
        if c in algs:
            v.hash(c, msg(300), 0, 25 if c >= 12 else 0, 'F_baseline_%s' % V.ALGNAME[c])
    v.chk(RAW, FLT, 0, 'F_baseline_no_event')
    v.chk(STS, 0x8, 0, 'F_baseline_not_locked')
    v.add('chkalarm 0')
    # 2. detection off (sha_sec.fault = 0): the same bit flip is not detected
    v.add('tag F_detection_disabled')
    v.add('apbw %03x %08x' % (SEC, sec(3, dup, par, redo, fault=0)))
    v.sel(1, 0); v.cmd(INIT); v.add('poll 060 f00 100 2000')
    v.add('inj 0 10 5')
    v.feed(0, msg(200)); v.add('apbw %03x %x' % (LEN, 200 % v.wb)); v.cmd(FINAL)
    v.add('wait 1500')
    v.chk(RAW, FLT, 0, 'F_disabled_no_event')
    v.chk(STS, 0xF00, 0x300, 'F_disabled_context_ready')
    v.cmd(ABORT); v.add('poll 060 3 2 20000')
    return v, rng, msg


def case2(v, tag, code, tgt, resp, msg, mech, dly=10, bit=5, cst='F', late=False, out=False, afin=False):
    """Like case() with the options of the parity and recompute tests: cst = 'F' (the context goes to the fault state) or
    'any'; late = the fault is injected after the message words are in the FIFO and before final; out = the fault is injected
    into the output FIFO after the digest is ready and a digest word is read."""
    dup, par, redo = mech
    v.add('tag F_%s' % tag)
    v.add('apbw %03x %08x' % (CMD, SRST))
    v.add('wait 20')
    v.add('apbw %03x %08x' % (RAW, 0xFFFFFFFF))
    v.add('apbw %03x %08x' % (SEC, sec(resp, dup, par, redo)))
    if getattr(v, 'reseed', None):
        v.reseed()
    v.sel(code, 0)
    v.cmd(INIT)
    v.add('poll 060 f00 100 2000')
    if not late and not out and not afin:
        v.add('inj %d %d %d' % (tgt, dly, bit))
    v.feed(0, msg)
    if late:
        v.add('wait 10')
        v.add('inj %d %d %d' % (tgt, dly, bit))
        v.add('wait 10')
    v.add('apbw %03x %x' % (LEN, len(msg) % v.wb))
    v.cmd(FINAL)
    if afin:
        v.add('inj %d %d %d' % (tgt, dly, bit))
    if out:
        v.add('poll 060 4 4 20000')
        v.add('wait 30')
        v.add('inj %d %d %d' % (tgt, 0, bit))
        v.add('wait 10')
        v.add('rwin 1')
        v.add('rclr')
        v.add('axir 0 %d' % max(1, (32 // v.wb)))
    v.add('wait 3000')
    v.add('chkinj_inc')
    v.chk(RAW, FLT, FLT, 'F_%s_fault_event' % tag)
    lockchk = resp & 2
    if cst == 'F':
        v.chk(STS, 0xF00, (0 if resp & 4 else 0xF) << 8, 'F_%s_context_state' % tag)
    elif resp & 4:
        v.chk(STS, 0xF00, 0, 'F_%s_context_state_wiped' % tag)
    v.chk(STS, 0x8, 0x8 if resp & 2 else 0, 'F_%s_locked' % tag)
    v.add('chkalarm %d' % (1 if resp & 8 else 0))
    if lockchk:
        v.add('tag F_%s_lock_rejects' % tag)
        v.cmd(INIT)
        v.add('wait 20')
        v.chk(RAW, CFG, CFG)
        v.add('win 0')
        v.add('axiw 0 1 %s' % v.hx(7))
        v.add('expb 2')
    if resp & 1 and not out:
        v.add('tag F_%s_gate_rejects_digest_read' % tag)
        v.add('rwin 1')
        v.add('rclr')
        v.add('axir 0 1')
        v.add('expr 2')
        v.add('expz 1')
    v.cmd(SRST)
    v.add('wait 20')
    v.chk(STS, 0x8, 0, 'F_%s_unlocked_by_soft_reset' % tag)
    v.add('chkalarm 0')
    v.add('apbw %03x %08x' % (RAW, 0xFFFFFFFF))
    v.add('rclr')
    if getattr(v, 'reseed', None):
        v.reseed()
    v.hash(code, msg, 0, 25 if code >= 12 else 0, 'F_%s_digest_after_recovery' % tag)
    v.chk(RAW, FLT, 0, 'F_%s_no_false_fault_after_recovery' % tag)


def par_file(dw, algs, mech, name):
    v, rng, msg = fault_file(dw, algs, mech, name)
    for resp in (3, 0, 4, 8):
        case2(v, 'par_sha256_core_resp%x' % resp, 1, 0, resp, msg(200), mech, cst='any')
    case2(v, 'par_sha256_core_resp15', 1, 0, 15, msg(200), mech, cst='any')
    case2(v, 'par_sha256_window', 1, 6, 3, msg(200), mech, dly=20, bit=100, cst='any')
    case2(v, 'par_sha512_core', 3, 1, 3, msg(300), mech, cst='any')
    case2(v, 'par_sha512_window', 3, 7, 3, msg(300), mech, dly=20, bit=300, cst='any')
    case2(v, 'par_keccak_state', 9, 2, 3, msg(300), mech, dly=4, bit=700, cst='any')
    case2(v, 'par_context_memory', 1, 8, 3, msg(200), mech, dly=0, bit=9, cst='any')
    case2(v, 'par_context_memory_keccak', 9, 8, 3, msg(300), mech, dly=0, bit=1500, cst='any')
    if not mech[2]:      # with recompute the push window moves and the flip has to be timed again; not tested there
        case2(v, 'par_context_memory_digest_read', 11, 8, 3, msg(40), mech, dly=38, bit=7, cst='any', afin=True)
    case2(v, 'par_input_fifo', 1, 9, 3, msg(40), mech, dly=0, bit=2, cst='any', late=True)
    case2(v, 'par_output_fifo', 1, 10, 3, msg(40), mech, dly=0, bit=2, cst='any', out=True)
    v.add('end')
    v.save(os.path.join(OUT, name))


def redo_file(dw, algs, mech, name):
    v, rng, msg = fault_file(dw, algs, mech, name)
    # first pass (delay 10) and second pass (delay after the first pass ends) of each core
    for resp in (3, 0, 4):
        case2(v, 'redo_sha256_first_pass_resp%x' % resp, 1, 0, resp, msg(200), mech, dly=10)
    case2(v, 'redo_sha256_first_pass_resp15', 1, 0, 15, msg(200), mech, dly=10)
    case2(v, 'redo_sha256_second_pass', 1, 0, 3, msg(200), mech, dly=80, bit=7)
    case2(v, 'redo_sha512_first_pass', 3, 1, 3, msg(300), mech, dly=10)
    case2(v, 'redo_sha512_second_pass', 3, 1, 3, msg(300), mech, dly=100, bit=9)
    case2(v, 'redo_keccak_first_pass', 9, 2, 3, msg(300), mech, dly=4, bit=300)
    case2(v, 'redo_keccak_second_pass', 9, 2, 3, msg(300), mech, dly=30, bit=900)
    v.add('end')
    v.save(os.path.join(OUT, name))


def dup_file(dw, algs, name):
    v, rng, msg = fault_file(dw, algs, (1, 0, 0), name)
    mech = (1, 0, 0)
    for resp in (3, 1, 0, 4, 8, 15):
        case(v, 'sha256_core_resp%x' % resp, 1, 0, resp, msg(200), mech)
    case(v, 'sha256_window_resp3', 1, 6, 3, msg(200), mech, dly=20, bit=100)
    case(v, 'sha512_core_resp3', 3, 1, 3, msg(300), mech)
    case(v, 'sha512_window_resp3', 3, 7, 3, msg(300), mech, dly=20, bit=300)
    case(v, 'sha3_256_core_resp3', 9, 2, 3, msg(300), mech, dly=4, bit=700)
    case(v, 'sha3_512_core_resp15', 11, 2, 15, msg(200), mech, dly=3, bit=1200)
    case(v, 'shake128_core_resp3', 12, 2, 3, msg(400), mech, dly=5, bit=17)
    v.add('end')
    v.save(os.path.join(OUT, name))


if __name__ == '__main__':
    os.makedirs(OUT, exist_ok=True)
    dup_file(64, V.ALL_ALGS, 'fault_dup_dw64.vec')
    par_file(64, V.ALL_ALGS, (0, 1, 0), 'fault_par_dw64.vec')
    redo_file(64, V.ALL_ALGS, (0, 0, 1), 'fault_redo_dw64.vec')
    par_file(64, V.ALL_ALGS, (1, 1, 1), 'fault_all_dw64.vec')
    print('fault vectors written')
