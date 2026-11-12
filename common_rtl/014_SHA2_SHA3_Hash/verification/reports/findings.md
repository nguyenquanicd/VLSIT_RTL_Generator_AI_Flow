# Findings of the verification (R-026)

Two RTL defects were found, their cause was clear from the specification, and they are fixed (section 1). Eight points are open: the
specification and the RTL disagree, or the specification is ambiguous, so the designer decides (section 2). Their tests are in
`vec/open_dw64.vec` and `vec/open_dma_dw64.vec` and the assertions of class 8; they are not in the default regression, which would fail on them.


## 0. Status after the decisions of 2026-11-10

The designer accepted the recommendations of every item. The spec was changed for OPEN-01, 02, 07, 08 and the waveforms (DEC-028, 029, 031, 032); the RTL was changed for OPEN-03, 04, 05, 06 (DEC-030). The sections below keep the analysis as it was when the decision was asked.

| ID | Resolution | Evidence |
|---|---|---|
| OPEN-01 | Spec 7.3 changed, RTL unchanged (DEC-028) | assertions AXI-36, RST-01, RST-02 |
| OPEN-02 | Spec 12, 6.4 changed, RTL unchanged (DEC-029) | test `DEC-029_raw_event_stays_after_soft_reset` in `dir_err_*` |
| OPEN-03, 05, 06 | RTL: abort, clear and free cancel the in-flight work and clear the core at once (`m_vlsit_sha_seq`: `w_be_abort`, no new slot item or back-end start for a context that is cleared in the same cycle); a reset does not clear the datapath registers, documented (DEC-030) | assertions SVA-005, SVA-005b, SVA-005c (a block was running) pass in all suites |
| OPEN-04 | Fixed by the same RTL change: init is accepted after an abort | test `ABORT_init_20_cycles_after_abort_of_shake` in `dir_abort_*` |
| OPEN-07 | Spec 6.3 changed (DEC-031); the strict 4-phase reading stays as informational assertions STRICT-4PH-a to d and suite `strict4ph_dma64` (expected to report the withdrawal) | `logs/strict4ph_dma64.log` |
| OPEN-08 | Spec 13 changed (DEC-032) | `reports/perf_report.md` |
| Waveforms | 16 figures replaced by the simulated ones; WF-012 and WF-013 are stage 2 | `waveforms_sim/waveform_compare.md` |

## 1. Fixed

| ID | Found by | Specification says | The RTL did | Fix |
|---|---|---|---|---|
| FIX-1 | IP-AXI-09 and the scoreboard, test `ERR-003_read_message_window` | 6.3: a read of a message window gets `rresp` = SLVERR and data 0 | `m_vlsit_sha_axi_sub` returned OKAY when the output FIFO of the context was empty (the decode `case ({w_r_ok, w_r_empty})` had no branch for "not allowed and empty") | `casez` with `2'b0?` giving SLVERR (DEC-027); `rtl/m_vlsit_sha_axi_sub.sv` |
| FIX-2 | SVA-005 in the 32-bit and 64-bit SHAKE runs | REQ-SEC-001: abort zeroes the context state | When a block of the context ended in the same cycle as the abort (or clear), the result write of memory port A overwrote the zero write of port B, so message-dependent state stayed in the context memory | `w_be_kill` in `m_vlsit_sha_seq` (template `tools/tpl/m_vlsit_sha_seq.sv`, DEC-026); the sentence "a collision is not possible" of 5.x was corrected in the specification |

After both fixes: rule check PASS (0 errors), all default suites pass.

## 2. Open, decision of the designer

Each item gives: what was observed, what the specification says, what the RTL does, what the test does, candidates, impact and options. A recommendation is marked.

### OPEN-01 AWREADY, WREADY and ARREADY are high while the reset is asserted

| Item | Content |
|---|---|
| Failure | Assertion OPEN-01, any run, first at 5 ns: `o_axi_awready` = 1 and `o_axi_arready` = 1 while `i_rst_n_core` = 0 (cycles of the initial reset and of every reset test). |
| Specification says | 7.3: "During reset the AXI4 and APB outputs are 0". AXI4 (IHI0022 A3.1.2): during reset the subordinate drives `BVALID` and `RVALID` low; the ready signals are not constrained. |
| RTL does | `m_vlsit_sha_axi_sub.sv:270` and `:291`: `o_axi_awready` and `o_axi_arready` are decodes of the IDLE state, which is the reset state, so they are 1 in reset. `BVALID`, `RVALID`, the APB outputs and the events are 0 in reset (assertions AXI-36, APB-17, RST-01, RST-02 pass). |
| Test does | Checks the three ready signals low while the reset is low (7.3 wording). |
| Candidates | A. RTL wrong (it breaks the sentence of 7.3). B. Specification too strict: the standard allows ready high in reset (evidence: IHI0022 A3.1.2 lists only the valid signals). C. Both are acceptable if 7.3 is read as "valid and response outputs". |
| Impact | A: one flop or a gate on the ready outputs (a "released" flag), the reset-release latency grows by one cycle. B: only the text of 7.3 changes; the integration is unchanged because a manager shall not send a valid in reset. |
| Options | **Recommended: B** (change 7.3 to "valid, response and event outputs are 0"); A if the integration checker of the SoC requires every output at 0 in reset. |

### OPEN-02 `sha_irq_raw` is not cleared by the soft reset command

| Item | Content |
|---|---|
| Failure | Test `OPEN-02_ERR-001_raw_event_cleared_by_soft_reset`: after a dropped write the raw bit `ovf` is 1; after `sha_cmd.srst` it is still 1. |
| Specification says | 12, ERR-001, reset behavior: "Event and record cleared by reset and soft reset". 5.x OP-007 and 7.3 RST-SOFT: the soft reset clears "event flags" and "the error record" (the error record is cleared, as the test `SRST_clears_error_record` shows). |
| RTL does | The raw bits are the w1c fields of the generated CSR block; only software (write 1) or the reset of the register side clears them. `m_vlsit_sha_irq.sv` does not use `i_srst` for the raw bits. |
| Test does | Reads `sha_irq_raw` after `srst` and expects 0. |
| Candidates | A. RTL wrong. B. "event" in 12 means the internal event, and the sticky raw bit is a software-visible record that only software clears (6.4: "Software write 1 to the bit"). C. The text is ambiguous. |
| Impact | A needs a hardware clear of a w1c field: the generator supports "hardware load replaces the field" for w1c, so the logic is small, but a pending interrupt then disappears without software having read it. B: text change in 12 and 7.3. |
| Options | **Recommended: B** (6.4 already says the clear condition is a software write and an interrupt must not vanish silently); A if the integrator wants the soft reset to be a full interrupt clear. |

### OPEN-03, OPEN-05, OPEN-06 Zeroing is not complete 3 cycles after a context is freed while a block is in flight, and not after a reset in the middle of a computation

| Item | Content |
|---|---|
| Failure | Assertions OPEN-05 (core registers) and OPEN-06 (context memory) and test `OPEN-03_core_registers_zero_after_reset_in_computation`. In the default regression the same effect shows in every SHAKE run in which the output was read and the context was aborted while the next squeeze block was queued or running (the assertions SVA-005 and SVA-005b are limited to "no block in flight" for this reason, see below). |
| Specification says | REQ-SEC-001: the IP clears the context state and the core registers after the last digest word or after abort and holds the core registers at zero while idle. ASM-005: clearing completes within 3 cycles. 7.3: with `PARA_ZERO` the clearing of 5.3 step 6 additionally removes message-dependent data (also after reset). |
| RTL does | `m_vlsit_sha_seq.sv:634` to `:636`: the core clear is given when a block ends (`w_be_done`), not at the abort. A block (or the queued item of the aborted context, `reg_pf_valid`) keeps running after the abort and the core holds the intermediate state until it ends and the clear follows one cycle later: up to 24/UNR + 3 cycles for Keccak, 64/UNR + 3 (SHA-256) or 80/UNR + 3 (SHA-512) cycles. A reset does not clear the datapath registers (they are not reset flops), so a reset in the middle of a block leaves message-dependent data in the core registers until the next block ends. |
| Test does | After the last context is free: the core registers (`reg_v`, `reg_w`, `reg_st` by name) are zero 3 cycles later. SVA-005, SVA-005b test the case in which no block is in flight; OPEN-05 and OPEN-06 the literal reading. |
| Candidates | A. RTL wrong: the clear shall be given at the abort and the queued item shall be cancelled. B. ASM-005 is too strict: the bound is "3 cycles after the core is idle" (what the default assertions check). C. A reset does not need to clear the datapath (the reset is a power-on or a fault recovery, not a key-erase function). |
| Impact | A: the sequencer gives `o_*_clr` at the abort for the core of the context and drops the prefetch slot; the cost is small, the core then finishes a block of zeros (the permutation of a zero state is a constant, no message data). Message data that lives in the core for up to about 100 cycles after an abort is a remanence risk only for an attacker with physical access, which the specification does not claim to defend (18). B: change ASM-005 and REQ-SEC-001 to "within 3 cycles after the core is idle". |
| Options | **Recommended: A for the abort** (it is a security feature of the product, FEAT-011) and B for the reset (state the limitation in 7.3). |

### OPEN-04 `sha_cmd.init` right after the abort of a SHAKE context is rejected

| Item | Content |
|---|---|
| Failure | Test `OPEN-04_init_20_cycles_after_abort_of_shake`: a SHAKE128 message of 25 bytes, 30 output bytes read, abort, 20 cycles later `init`: the init is lost and `sha_irq_raw.cfg` is set; the context stays FREE. A message of 24 bytes does not show it (the timing depends on the length). |
| Specification says | OP-006: after the abort the context is FREE after 2 cycles. OP-001: `init` is accepted when the context is FREE and the algorithm is built; 12, ERR-004 lists "context busy" as a reason to reject. `sha_sts.busy` says "poll it ... before the soft reset command". |
| RTL does | `m_vlsit_sha_seq.sv:341` and `:373`: `init` needs `!w_cx_busy`; the context is busy while the prefetch slot, the front end or the back end still holds an item of that context. After an abort the back end finishes the running squeeze block (the output FIFO refill) and the slot is cleared only then. `sha_sts.cstate` already reads FREE. |
| Test does | Abort, wait 20 cycles, `init`, poll `cstate` = ABSORBING; the main regression waits for `sha_sts.idle` after every abort (assumption of the testbench: software polls idle before reusing a context; ASM added in the README). |
| Candidates | A. RTL wrong: an aborted context shall accept `init` at once (the back end discards the result: `w_be_alive` already does). B. Specification: add the rule "poll `sha_sts.idle` between abort and init". |
| Impact | A removes the hazard (software cannot see the difference between FREE and busy-FREE); costs one condition in `w_do_init`. B is a text change but leaves a trap. |
| Options | **Recommended: A.** |

### OPEN-07 The DMA request is withdrawn without an acknowledge when the context is aborted or finalized

| Item | Content |
|---|---|
| Failure | Assertions OPEN-07a to OPEN-07d, test `OPEN-07_dma_request_withdrawn_by_abort`: `o_dma_in_req` is 1 and not acknowledged; the abort command makes it fall. The same happens to the input request when `final` ends the absorbing state and to a pending output request when the context is aborted or reset. |
| Specification says | 6.3 IF-003: "`o_dma_in_req` rises and stays high until `i_dma_in_ack` rises; then `o_dma_in_req` falls". 15.3 SVA-004: each channel follows the 4-phase order. |
| RTL does | `m_vlsit_sha_dma.sv:123` to `:161`: the FSM leaves REQ when the condition of the request disappears (context not absorbing, FIFO empty after abort) or on `i_clr`, before the acknowledge. |
| Test does | Request pending, abort, observe the request low without an acknowledge. In the default DMA suites every request is acknowledged by the controller model before the next command, so SVA-004a, 004d, 004g and 004h pass. |
| Candidates | A. RTL wrong: a 4-phase request must be held until it is acknowledged, and the DMA controller must be told by an empty burst or by the status. B. Specification: a request that is no longer needed may be withdrawn (usual for a DMA request line: the controller then sees the request low without an acknowledge). |
| Impact | A: the IP keeps the request and must account for words that nobody will send (abort clears the promise counters, so the next burst would be dropped). More logic and a new corner. B: a text change; the integrator's DMA controller must accept a withdrawn request. |
| Options | **Recommended: B** (describe the withdrawal in 6.3 and in the integration notes), A only if the DMA controller of the SoC requires a strict 4-phase. |


### OPEN-08 Cycles per block of Keccak at unroll 2 or more are limited by the 64-bit window, not by the core (section 13, PERF-003)

| Item | Content |
|---|---|
| Failure | `reports/perf_report.md`: SHA3-256 at unroll 2 and 4 needs 21 cycles per block (formula 14 and 8), SHA3-512 at unroll 4 needs 13 (formula 8). All SHA-2 rows, SHA3-256 and SHA3-512 at unroll 1 and SHA3-512 at unroll 2 equal the formula exactly. |
| Specification says | 13: cycles per block = R/UNR + 2, PERF-003 "Hard", tolerance 2 cycles; SHA3-256 unroll 2 reaches 38.9 Gbit/s; "the AXI4 window at 64-bit and 500 MHz carries 32 Gbit/s, so the bus does not limit these cases". |
| RTL does | The input window takes one 64-bit word per cycle. A SHA3-256 block is 136 bytes = 17 words, a SHA3-512 block 72 bytes = 9 words. The measured time equals words + 4 cycles (17 + 4 = 21, 9 + 4 = 13) at every unroll above the point where the core is faster than the bus, so the block time is set by the bus. |
| Test does | Streams 40 and 120 full blocks with the testbench write task at the maximum rate (burst 256, no gap) and takes the slope of the cycles. |
| Candidates | A. The specification is wrong: 38.9 Gbit/s exceeds the 32 Gbit/s of the 64-bit bus (the sentence of 13 contradicts its own table), so the formula holds only while the core is slower than the bus. B. The RTL is wrong: a wider or second window would be needed, which DEC-019 excludes for SHA3-256 (rate 136 is not a multiple of 16). |
| Impact | The requirements REQ-PERF-001 (4.46 ms and 2.75 ms for 4 MiB, limit 5 ms) and REQ-PERF-002 (14.2 Gbit/s SHA-256 unroll 4, 25.9 Gbit/s SHA3-256 unroll 2, limit 8 Gbit/s) are met. Only the PERF-003 formula and the table of 13 are wrong for Keccak at unroll above 1 on a 64-bit bus. A larger Keccak unroll does not speed up a 64-bit system beyond 21 cycles per block. |
| Options | **Recommended: A** (change 13: cycles per block = max(R/UNR + 2, words per block + 4), correct the SHA3 rows to 25.9 Gbit/s, note that Keccak unroll above 1 is useless on the 64-bit window). |

## 3. Interpretations used by the testbench (decisions of the author, listed for review)

| ID | Interpretation | Source |
|---|---|---|
| T-1 | With `PARA_CSR_ASYNC` = 0 the two reset ports are tied (7.1 says the integrator ties the two clocks; the generated block then uses the APB reset for the register side). Single-domain reset tests (`rsta`, `rstc`) apply both resets in that case and are real only in the `async_*` suites. | 7.1, `m_vlsit_csr_sha` |
| T-2 | Software polls `sha_sts.idle` between an abort and the next `init` (see OPEN-04). | `vec_lib.py` |
| T-3 | `sha_err.kind` and the cfg event are checked for the cases whose kind the specification fixes (1 for a write to a non-absorbing context, 2 for an empty read, 3 for the wrong direction, 4 for WRAP, narrow size and partial strobe). A context number out of range is checked by `bresp`, the event and the unchanged FIFO only (6.3 says "3 or 4"). | 6.3, 12 |
| T-4 | Whether an AXI error also sets `sha_irq_raw.axi` when the cause is a write to a non-absorbing context (ERR-001 names only `ovf`) is not checked: the specification is ambiguous. | 6.4, 12 |
| T-5 | A burst larger than the input FIFO depth (`PARA_IN_DEPTH`) is treated as illegal by the RTL (cfg event), and the specification limit is 256 words; only values 0 and 0x101 are tested as illegal. | 8, `sha_dmac` |

## 4. Waveform evidence: all 15 simulated waveforms are DIFFERENT from the figures (R-026, R-088 to R-091)

`waveforms_sim/waveform_compare.md` gives the row-level differences of each figure (the first three per figure; `waveforms_sim/<stem>_diff.json` lists all), the simulated
WaveJSON and SVG are next to it. WF-012 and WF-013 are NOT-SIMULATED (stage 2). No waveform is MATCH.

| Item | Content |
|---|---|
| Failure | Every simulated window differs from its figure in 8 to 34 slots (14 compared rows for WF-001; the rows that name a net the RTL does not have, for example `w_pad_last`, `w_blk_kind`, `r_tmo_cnt`, `w_core_req_sync`, are listed and not compared). |
| Specification says | Section 10.3 and the figures of `figures/wf_*.svg`, drawn in the specification phase before the RTL existed, as timing sketches of the behavior text of 10.3 (for example "AWREADY comes one cycle after AWVALID"). |
| RTL does | Differences by kind: (a) the AXI address channels have the ready high in idle (`m_vlsit_sha_axi_sub.sv:270`, `:291`), so the handshake takes place in the first cycle of AWVALID or ARVALID; the figures show one wait cycle (WF-001, 002, 005, 006, 010). (b) The command bits of the generated CSR block reach the sequencer and clear one cycle earlier or later than drawn (`i_hw_we_sha_cmd_*`, WF-004, 014, 017). (c) The core start, busy and context-state transitions are shifted by 1 to 3 cycles from the sketch (WF-004, 008, 009, 017, 018, 019). (d) DMA request, acknowledge and burst timing follow the acknowledge delay of the testbench controller model (3 cycles) and the promise counters, not the drawn 2-cycle delay (WF-010, 011). (e) WF-015: the ready outputs are high in reset (OPEN-01). (f) WF-016: with the APB clock at 4 core cycles (as in the figure) the write needs more than the drawn latency: `o_sha_ctrl_en` changes in slot 11 (drawn: slot 9) and `PREADY` is still low at the end of the 16-slot window (drawn: slot 11), the asynchronous register crossing takes longer than the sketch. |
| Test does | Runs the scenario alone, cuts the window of the figure (same clock, same slot grid, anchored on the event named in `wf_plan.json`) and compares the 1-bit rows slot by slot and the value-change slots of the bus rows. The stimulus of the scenario follows the text of 10.3; wait cycles between commands are the testbench's. |
| Candidates | A. The figures are illustrative sketches and the RTL is right: the assertions of `tb/sha_checkers.sv` (AXI-01 to AXI-38, APB-01 to APB-17, IP-AXI, IP-APB) show that the RTL meets the protocol rules and the behavior text of 6.3 at the same cycles. B. The RTL shall follow the figures (add the wait cycles and the one-cycle shifts). C. Mixed: correct the figures where the RTL is right and change the RTL only where a requirement needs it (OPEN-01). |
| Impact | A: replace the 15 figures by the simulated SVGs (same names), 10.3 text adjusted to the measured latencies; no RTL change. B: extra register stages on the ready outputs and command paths: more latency, no benefit; each of the 15 waveforms would be re-simulated. |
| Options | **Recommended: A with the exception of WF-015, which follows the decision of OPEN-01.** The designer decides; after the decision the figures or the RTL are changed and `python wf_tool.py` is run again. |

## 5. Stage 2b (masking) findings, 2026-11-10

| Item | Content |
|---|---|
| Failure | The Welch t-test of the first masked RTL (`mask_stat64`, fixed against random message, 150 blocks each) gave max abs t = 8.9 for share 0 in the cycles after round 0 (Hamming weight 780.7 against 799.8); the control run without masking gave 75.6. |
| Cause | The random bits of the chi step in round 0 are the next state of the random bit source, a public function F of the refresh word R. At the same bit position the linear part of F(R) cancels the mask of share 0, so lin(message) appears in the share. |
| Fix (DEC-037) | The chi step takes the refresh word moved by five lanes (`w_rc` in `m_vlsit_sha_keccak_dom.sv`). After the fix: max abs t = 2.5 (share 0) and 2.2 (share 1), digests unchanged. Mutant K05 (the old design) is caught by the t-test (8.9). |
| Not shown | Mutant K06 (no random bits in chi) is not caught: the single-wire Hamming-weight statistic does not see it, because the refresh word already masks every register value individually. Random bits in chi matter for the pairs of values that glitches or transitions combine; this IP makes no claim for them (ASM-013), and no test here covers that. 300 blocks is a small sample: a leak with a smaller effect than about 4 standard errors would not show. |
| Other test-side fixes | Context-memory injection of the masked build was cut at 1600 bits (the TB width is 3200 now); the fault tests re-seed after a soft reset because it clears the seed. |

## 6. Open items closed on 2026-11-10 (context counts, parity, static checks)

| Item | Content |
|---|---|
| RTL bug found by the 16-context run (fixed) | `m_vlsit_sha_axi_sub.sv` compared the window number with `PARA_CTX_N[3:0]`, which is 0 for `PARA_CTX_N` = 16 (the maximum of section 8): every AXI access was answered with SLVERR. Now a 5-bit compare. Found by the new suites `ctx16` and `dirctx16`; the suites for 1, 2, 4, 8 and 16 contexts pass. |
| Test-side fixes | Several directed tests used context 1, 2 or an out-of-range context number that does not exist with 1, 2 or 16 contexts; they now follow the number of contexts. The zeroing assertion SVA-005 allows k extra cycles after a soft reset (sweep of one context per cycle, DEC-038); it held with 4 contexts only because of rounding. |
| Parity on the second read port | The context-memory parity is checked when the output unit reads a state word (mutant F11 checks the test). The test times the flip into the push window of the digest (`par_context_memory_digest_read`); it is not run with recompute because the window moves. |
| Static checks | TEST-023 and TEST-024 are covered by `scripts/static_checks.py` for the clock structure and the SDC names only. The scan insertion trial and the load of the SDC into an STA tool are not done (no tool). |
| Still open | TEST-008 (the length limit cannot be shortened: no test parameter, adding one changes the RTL interface: needs your decision), four-state X checks (Verilator is two-state; a four-state simulator is not available), the COV-006 context-count dimension is run with `ctx*` and `dirctx*` suites but the covergroup is counted from the log lines only. |

## 7. TEST-008 and the X policy (2026-11-10)

| Item | Content |
|---|---|
| TEST-008 length limit | Done without an RTL change: the testbench command `ctot` presets the byte counter of context 0 two words below 2^61 (force of the next-state signal for one clock; Verilator does not allow force on the register itself). Suite `limit64` (SHA-256, SHA-512, SHA3-256, SHAKE128): no event two words below the limit, the event, the freed context and no digest word above it, and a correct digest afterwards. Mutant L01 (limit never raised) is caught. The limit value 2^61 - 1 is not shortened, so the test relies on the counter width being the only decision point. |
| X policy (15.3) | A four-state check is not possible: Verilator is two-state and iverilog cannot compile the RTL (packed multi-dimensional indexing) without changing the design for the simulator. Substitute `scripts/xcheck.py` (TEST-025): the same vectors with zero power-up values and with random power-up values (three seeds) give the same output hash and scoreboard; the control mutant (SLVERR read data from the resetless FIFO memory) makes the hash differ, so the check sees such a dependence. It does not find X pessimism or optimism, covers the unmasked configuration only, and leaves out random back pressure and the entropy model because they follow the random seed. |
| Test-side detail | The first cycle before the first reset edge is not hashed (outputs are defined from the reset on, 7.3); `irq` and the ready outputs can differ there. |
