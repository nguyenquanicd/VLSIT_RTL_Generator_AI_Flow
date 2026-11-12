# Mutation check of the testbench

Each bug was injected alone into a copy of the RTL (`work/mut/`, deleted afterwards); the delivered RTL was not changed. Quick regression used: edge, APB, error, interrupt, abort, back pressure vectors of the 64-bit configuration (`scripts/mutate.py`).

| Bug | Requirement | Result | What fired |
|---|---|---|---|
| M01 SHA-256 constant K0 bit flipped | REQ-FUNC-001 | CAUGHT | scoreboard (35 fails, first in ABORT_then_hash_ok_after_absorbing) |
| M02 Keccak round constant RC[1] changed | REQ-FUNC-001 | CAUGHT | scoreboard (67 fails, first in ABORT_shake_digest) |
| M03 partial WSTRB accepted | REQ-IF-002 | CAUGHT | scoreboard (4 fails, first in ERR-003_no_word_pushed_partial_wstrb); assertion 67: IP-AXI-06 partial WSTRB gives SLVERR (6.3, REQ-IF-002); assertion 75: X-AXI-APB-02 a rejected write beat pushes no word (6.3, REQ-IF-002) |
| M04 BID not the AWID of the burst | REQ-IF-001 | CAUGHT | assertion 52: AXI-29 BID equals the AWID of the burst (A5.3.1) |
| M05 o_irq ignores the context-done events | REQ-INT-001 | CAUGHT | scoreboard (8 fails, first in IRQ_cdone_each_context_by_injection); assertion 78: SVA-003 o_irq equals the OR of the masked events (6.4, 15.3) |
| M06 SHA-256 core not cleared after a block (zeroing removed) | REQ-SEC-001 | CAUGHT | assertion 87: SVA-005b core registers zero within 3 cycles after the last context is freed wit; assertion 91: SVA-005c core registers zero within 3 cycles after the last context is freed, al |
| M07 write to a digest window accepted (direction check removed) | REQ-IF-002 | CAUGHT | scoreboard (4 fails, first in ERR-003_write_digest_window); assertion 64: IP-AXI-03 write to the digest window gives SLVERR (6.3, REQ-IF-002); assertion 75: X-AXI-APB-02 a rejected write beat pushes no word (6.3, REQ-IF-002) |
| M08 DMA input request not raised (promise ignored: request when free >= burst only after 1 word) | REQ-IF-004 | NOT CAUGHT | no check fired |
| M09 error record kind not kept (read of empty FIFO not counted) | REQ-ERR-001 | CAUGHT | scoreboard (2 fails, first in ERR-002_read_empty_output) |
| M10 WLAST not required: write response one beat early | REQ-IF-001 | CAUGHT | assertion 50: AXI-27 BVALID only after the last write beat (A3.3.1); global timeout |
| F01 duplicate compare disabled | REQ-SEC-002 | CAUGHT | scoreboard (53 fails, first in F_sha256_core_resp0_context_state) |
| F02 lock response never set | REQ-SEC-002 | CAUGHT | scoreboard (13 fails, first in F_par_context_memory_keccak_locked); assertion 97: FLT-03 the responses of sha_sec.resp are active one cycle after the fault event  |
| F03 gate does not reject digest reads | REQ-SEC-002 | CAUGHT | scoreboard (1 fails, first in F_sha256_core_resp1_gate_rejects_digest_read); assertion 96: FLT-02 a read burst accepted while locked or gated gets SLVERR and data 0 (DEC-0 |
| F04 parity flags ignored | REQ-SEC-002 | CAUGHT | scoreboard (16 fails, first in F_par_context_memory_fault_event) |
| F05 recompute compare disabled | REQ-SEC-002 | CAUGHT | scoreboard (40 fails, first in F_redo_keccak_first_pass_context_state) |
| F06 soft reset does not clear the lock | REQ-SEC-002 | CAUGHT | global timeout |
| F07 result of a faulty block still stored | REQ-SEC-002 | NOT CAUGHT | no check fired |
| F08 parity of the input FIFO not checked | REQ-SEC-002 | CAUGHT | scoreboard (8 fails, first in F_par_input_fifo_fault_event) |
| F09 alarm never raised | REQ-SEC-002 | CAUGHT | scoreboard (2 fails, first in F_par_sha256_core_resp15_locked) |
| F11 parity of the context memory not checked when the output unit reads | REQ-SEC-002 | CAUGHT | scoreboard (4 fails, first in F_par_context_memory_digest_read_fault_event) |
| F10 clear response does not wipe | REQ-SEC-002 | CAUGHT | scoreboard (2 fails, first in F_par_sha256_core_resp15_context_state_wiped) |
| K01 digest not unmasked (share 1 ignored by the output unit) | REQ-SEC-003 | CAUGHT | scoreboard (111 fails, first in H_sha3_224_len0) |
| K02 masked block starts without a seed | ERR-006 | CAUGHT | scoreboard (2 fails, first in M_ERR006_ent_event); assertion 102: MASK-02 the random bits change from cycle to cycle while a masked block runs (RE; assertion 104: MASK-04 a masked block starts only when the random bit source is seeded (ERR-006 |
| K03 share 1 not refreshed at the start of a block | REQ-SEC-003 | CAUGHT | scoreboard (111 fails, first in H_sha3_224_len0); assertion 101: MASK-01 share 1 is not zero in any cycle of a masked block (REQ-SEC-003) |
| K04 round constant not added to share 0 | REQ-SEC-003 | CAUGHT | scoreboard (117 fails, first in H_sha3_224_len0) |
| K05 random bits of chi at the bit position of the refresh word (first design, DEC-037) | REQ-SEC-003 | CAUGHT | Welch t-test: max |t| = 8.9 (limit 4.5) |
| K06 no random bits in chi (cross terms unmasked) | REQ-SEC-003 | NOT CAUGHT | no check fired |
| L01 length limit never raised | REQ-FUNC-009 | CAUGHT | scoreboard (16 fails, first in LIMIT_sha256_context_freed) |

Caught: 25 of 28.
