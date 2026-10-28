"""Equivalence of the optimized forms with the reference functions of the model (specification section 10.2).

Run: UPS_S=32 UPS_M=128 python check_equivalence.py   (exit code 0 when no difference)
Compares, for every legal combination of start address (all offsets of a 4KB page), size, burst type and length:
  - the converted attributes and the pack flag (convert_fast against convert),
  - for a packed burst the slot and the word-last flag of every beat (slot_fast, word_last_fast against beat_addr and word_last),
  - for a burst that is not packed the slot of every beat from the incremental low-bit address (next_low_fast against beat_addr).
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import ups_cycle_model as M  # noqa: E402

errors = 0
cases = 0
beats = 0
R, LS, LM, MB, SB = M.RATIO, M.LS, M.LM, M.MB, M.SB
for burst in (M.INCR, M.WRAP, M.FIXED):
    for size in range(0, LS + 1):
        nb = 1 << size
        lens = [1, 3, 7, 15] if burst == M.WRAP else (list(range(0, 16)) + [31, 63, 255] if burst == M.INCR else list(range(0, 16)))
        for length in lens:
            for addr in range(0, 4096, 1 if (burst != M.WRAP) else nb):
                if burst == M.WRAP and addr % nb:
                    continue
                if burst == M.INCR:
                    last = (addr // nb) * nb + length * nb
                    if addr // 4096 != (last + nb - 1) // 4096:
                        continue
                for cache in (0, 2):
                    for lock in (0, 1):
                        if lock and cache:
                            continue
                        a = dict(addr=addr, length=length, size=size, burst=burst, lock=lock, cache=cache)
                        ref = M.convert(**a)
                        fast = M.convert_fast(**a)
                        cases += 1
                        if ref != fast:
                            errors += 1
                            if errors < 5:
                                print('convert differs', a, ref, fast)
                            continue
                        txn = dict(ref, orig=dict(a))
                        cur = addr & ((1 << M.LA) - 1)
                        for idx in range(length + 1):
                            full = M.beat_addr(addr, size, length, burst, idx)
                            if idx:
                                cur = M.next_low_fast(cur, size, length, burst)
                            beats += 1
                            ref_slot = (full % MB) // SB
                            if ref['pack']:
                                if M.slot_fast(addr, length, burst, idx) != ref_slot or M.word_last_fast(addr, length, burst, idx) != M.word_last(txn, idx):
                                    errors += 1
                                    if errors < 5:
                                        print('packed slot or word-last differs', a, idx)
                            else:
                                if ((cur >> LS) & (R - 1)) != ref_slot:
                                    errors += 1
                                    if errors < 5:
                                        print('lane slot differs', a, idx, cur, full)
print('ratio %d (S %d bit, M %d bit): %d cases, %d beats, %d low address bits, errors %d' % (R, M.S_W, M.M_W, cases, beats, M.LA, errors))
sys.exit(1 if errors else 0)
