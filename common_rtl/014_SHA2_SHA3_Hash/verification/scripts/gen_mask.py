"""Masked-core test scripts (TEST-021, REQ-SEC-003, ERR-006, OP-009): masked digests of the Keccak algorithms with several
seeds, the error before seeding, the command seed, the entropy-port start and the share statistics run.
Expected digests come from hashlib (via vec_lib); the masking does not change the digest (spec 18).
Run: python gen_mask.py
"""
import os
import random

import vec_lib as V
from gen_directed import T, CTRL, CMD, STS, RAW, INIT, FINAL
from gen_fault import fault_file, case2

OUT = os.path.join(V.VER, 'vec')
KEC = [8, 9, 10, 11, 12, 13]
SEED, ENT = 1 << 5, 1 << 21


def seed_cmd(v, rng):
    """Write the eight seed words and the seed command, wait for sha_sts.seeded (OP-009)."""
    for i in range(8):
        v.add('apbw %03x %08x' % (0x20 + 4 * i, rng.getrandbits(32)))
    v.add('apbw %03x %x' % (CMD, SEED))
    v.add('poll 060 20 20 2000')


def reg_file(dw, name, seeds=(1, 2, 3)):
    """Masked digests, several seeds (seed re-written between groups), unmasked control messages in the same build."""
    v = T(dw)
    rng = random.Random(77)
    v.add('rstb 6')
    v.add('static 0 1')
    for sd in seeds:
        seed_cmd(v, random.Random(sd))
        for c in KEC:
            r = V.BLK[c]
            for ln in (0, 1, r - 1, r, r + 1, 2 * r + 5):
                v.mask = 1
                v.hash(c, V.rnd_msg(rng, ln), 0, 37 if c >= 12 else 0)
        v.mask = 0
        for c in (9, 13):
            v.hash(c, V.rnd_msg(rng, 200), 0, 32 if c >= 12 else 0, tag='U_%s_unmasked' % V.ALGNAME[c])
    v.mask = 1
    # two interleaved contexts, one masked and one not, share the one core
    for c in (9, 11):
        v.hash(c, b'abc', 0, 0)
    v.add('end')
    v.save(os.path.join(OUT, name))


def err_file(dw, name):
    """ERR-006: a masked message before the seed stalls, raises sha_irq_raw.ent and finishes after the seed."""
    v = T(dw)
    v.add('rstb 6')
    v.add('static 0 1')
    v.mask = 1
    msg = b'masked message before seed'
    v.chk(STS, 0x20, 0, 'M_not_seeded_after_reset')
    v.sel(9, 0)
    v.add('apbw %03x %08x' % (CTRL, 1 | (9 << 8) | (1 << 24)))
    v.cmd(INIT)
    v.add('poll 060 f00 100 2000')
    v.feed(0, msg)
    v.add('apbw 010 %x' % (len(msg) % v.wb))
    v.cmd(FINAL)
    v.add('wait 300')
    v.chk(RAW, ENT, ENT, 'M_ERR006_ent_event')
    v.chk(STS, 0x4, 0, 'M_ERR006_no_digest_yet')
    v.add('apbw %03x %08x' % (RAW, ENT))
    seed_cmd(v, random.Random(9))
    v.add('poll 060 4 4 200000')
    v.collect(9, 0, V.digest(9, msg), 'M_ERR006_digest_after_seed')
    v.chk(RAW, ENT, 0, 'M_ERR006_no_new_ent_event')
    # srst clears seeded (7.3)
    v.cmd(8)
    v.add('wait 40')
    v.chk(STS, 0x20, 0, 'M_srst_clears_seeded')
    v.add('end')
    v.save(os.path.join(OUT, name))


def ent_file(dw, name):
    """Entropy-port start (SEED_SRC = 0): eight words supplied through IF-004, then masked digests; the seed command is rejected."""
    v = T(dw)
    rng = random.Random(5)
    v.add('rstb 6')
    v.add('static 0 1')
    v.add('tag E_seeded_from_entropy_port')
    v.add('poll 060 20 20 4000')
    v.add('apbw %03x %x' % (CMD, SEED))
    v.add('wait 20')
    v.chk(RAW, 1 << 19, 1 << 19, 'E_cmd_seed_rejected_cfg')
    v.mask = 1
    for c in KEC:
        v.hash(c, V.rnd_msg(rng, 100 + c), 0, 20 if c >= 12 else 0)
    v.cmd(8)
    v.add('wait 40')
    v.add('tag E_reseeds_after_srst')
    v.add('poll 060 20 20 4000')
    v.hash(9, b'second', 0, 0)
    v.add('end')
    v.save(os.path.join(OUT, name))


def stat_file(dw, name, nrun=300, masked=1):
    """Share statistics (REQ-SEC-003, TEST-021): fixed message (group 0) against random messages (group 1); the
    testbench sums the Hamming weights of both shares for every cycle of a block (hwdump); analysis in mask_stat.py."""
    v = T(dw)
    rng = random.Random(31)
    fixed = bytes(range(100))
    v.add('rstb 6')
    v.add('static 0 1')
    seed_cmd(v, random.Random(4))
    v.mask = masked
    for i in range(nrun):
        v.add('hwgrp %d' % (0 if i % 2 == 0 else 1))
        msg = fixed if i % 2 == 0 else V.rnd_msg(rng, 100)
        v.hash(9, msg, 0, 0, tag='S%d' % i)
    v.add('hwgrp 2')
    v.add('hwdump')
    v.add('end')
    v.save(os.path.join(OUT, name))


def mfault_file(dw, name, mech=(1, 1, 1)):
    """Fault detection with the masked core (REQ-SEC-002 with REQ-SEC-003): a bit flip of a share, of the context memory
    (share 1) and of the output FIFO is detected; recovery needs a new seed because the soft reset clears it."""
    v, rng, msg = fault_file(dw, V.ALL_ALGS, mech, name)
    v.mask = 0
    seed_cmd(v, random.Random(21))
    v.mask = 1
    v.reseed = lambda: seed_cmd(v, random.Random(22))
    case2(v, 'mask_keccak_share0_first_pass', 9, 2, 3, msg(300), mech, dly=4, bit=300, cst='any')
    case2(v, 'mask_keccak_share0_second_pass', 9, 2, 3, msg(300), mech, dly=60, bit=900, cst='any')
    case2(v, 'mask_keccak_share0_resp0', 11, 2, 0, msg(200), mech, dly=10, bit=1200, cst='any')
    case2(v, 'mask_keccak_share0_alarm', 9, 2, 15, msg(200), mech, dly=10, bit=50, cst='any')
    case2(v, 'mask_context_memory_share1', 9, 8, 3, msg(300), mech, dly=0, bit=2500, cst='any')
    v.add('end')
    v.save(os.path.join(OUT, name))


if __name__ == '__main__':
    for dw in (64, 32):
        reg_file(dw, 'mask_reg_dw%d.vec' % dw)
        err_file(dw, 'mask_err_dw%d.vec' % dw)
    ent_file(64, 'mask_ent_dw64.vec')
    stat_file(64, 'mask_stat_dw64.vec')
    stat_file(64, 'mask_statctl_dw64.vec', masked=0)
    mfault_file(64, 'mask_fault_dw64.vec')
    print('mask vectors written')
