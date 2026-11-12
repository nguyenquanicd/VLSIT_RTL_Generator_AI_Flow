# Verification of the SHA2/SHA3 hash IP (`m_vlsit_sha_top`)

Simulation testbench, protocol assertions, code coverage and waveform evidence for `../rtl`. Nothing here is part of the
design file set (`rtl/filelist.f` does not list it; R-010, R-022). Everything was derived from the specification
`../VLSIT_SHA2_SHA3_HASH_HDS.md`, FIPS 180-4, FIPS 202, ARM IHI0024D (APB4) and ARM IHI0022 (AXI4); the RTL was read only for
port names, widths, parameters and the observation points named in `tb/tb_sha_top.sv` (R-023).

## Sources of the expected values

| Source | Use |
|---|---|
| NIST CAVP byte-oriented vectors (`ref_nist/`: `shabytetestvectors.zip`, `sha-3bytetestvectors.zip`, `shakebytetestvectors.zip`, downloaded from csrc.nist.gov on 2026-11-10) | ShortMsg and every 6th LongMsg of the 12 algorithms, every 7th SHAKE VariableOut. Not used: the Monte Carlo files (100 x 1000 chained hashes) and the bit-oriented files (the IP takes whole bytes). |
| Python `hashlib` (OpenSSL 3.0.16) | Edge lengths, FIPS example messages, random messages, long streams. Every NIST vector that is used is also hashed with `hashlib`; `scripts/vec_lib.py` stops if the two disagree (they agreed for all vectors used). |

## Layout

| Path | Content |
|---|---|
| `tb/tb_sha_top.sv` | Testbench: APB and AXI4 bus models, DMA controller model, scoreboard, command-script interpreter |
| `tb/sha_checkers.sv` | Clocked assertions (APB4, AXI4, IP behavior, cross checks, DMA, zeroing, reset) with hit and fail counters |
| `scripts/` | Python: vector generators, runner, waveform tool, coverage report (standard library only, Python 3) |
| `vec/` | Generated command scripts (`*.vec`) and suite scripts |
| `logs/` | One log per simulation run; `logs/cdc/` holds the clock-crossing runs (synthesis branch and three seeds per ratio) |
| `reports/` | `summary.md`, `coverage_report.md`, `perf_report.md`, `elab_results.md`, `mutation_report.md`, `findings.md` (RTL fixes, open decisions under R-026, interpretations) |
| `waveforms_sim/` | VCD, WaveJSON, SVG of each plan waveform and `waveform_compare.md` |
| `coverage/` | Verilator coverage data of each suite and the lists of uncovered points |
| `ref_nist/` | NIST archives (untrusted data, read only by `scripts/vec_lib.py`) |

## How to run

Tools: Python 3, Verilator 5.053 (OSS CAD Suite, `C:/Tools/oss-cad-suite`) with the msys64 `g++`; paths are set in `scripts/simlib.py`.
Windows needs the `python3` shim, `TMPDIR` and `VERILATOR_ROOT` that `simlib.env_for` creates. Free disk space is needed (a build is about 250 MB; suite builds are deleted after the run).

```
cd scripts
python run_all.py            # everything, writes reports/summary.md (add --skip-boot to skip the two 4 MiB runs)
python run_regress.py main64 # one suite (names in run_regress.SUITES)
python wf_tool.py WF-001     # one waveform scenario
python elab_tests.py         # TEST-002 and TEST-015
python cov_report.py         # merge the coverage data
python mutate.py             # inject 10 bugs one at a time into a copy of the RTL and run a quick regression
```

Debug helpers (not part of the regression): `scripts/smoke.py` (build once, run chosen vectors), `scripts/dbg.py` (run with a VCD), `scripts/vcd_sel.py` and `scripts/vcd_tool.py` (print chosen signals at clock edges from a VCD).

## Suites (R-048: focused tests first, then combined flows)

| Suite | Configuration | Content | Tests of the specification |
|---|---|---|---|
| `main64`, `main32`, `main128` | 64, 32, 128-bit AXI; 4 contexts; all algorithms (128-bit: SHA-2 and SHA3-224, DEC-019) | NIST vectors, edge lengths, FIPS examples, random messages with random AXI back pressure, interleaved contexts, APB cases of 11.4, error cases of 6.3 and 12, interrupts, abort, soft reset, resets, tail values and padding boundaries, FIXED bursts, read-address stall | TEST-001, 003, 004, 005, 006, 007, 009, 010, 014, 016, 017, 019 |
| `dma64`, `dma32`, `dma128` | `PARA_DMA` = 1 | 4-phase handshake, burst sizes, timeout, padded burst, illegal burst sizes, plus the main64 error and protocol tests | TEST-011 |
| `async_<ratio>_synth`, `async_<ratio>_seed1..3` | `PARA_CSR_ASYNC` = 1; APB:core clock ratios 1:1, 1:3, 7:2, 2:7 | Hash, APB, error, interrupt and abort tests; each ratio runs with `VLSIT_SYNTHESIS` (library cells) and with the metastability model, seeds 1 to 3 (`+AFIFO_MSYNC_SEED`) | TEST-013, CDC-001, R-034 |
| `fault_dup64`, `fault_par64`, `fault_redo64`, `fault_all64` | `PARA_FAULT_DUP`, `PARA_FAULT_PAR`, `PARA_FAULT_REDO` alone and together, `PARA_ALARM` = 1 | Bit flips injected by `force` into the cores, the context memory and the FIFOs; the fault event, the responses of `sha_sec.resp` (gate, lock, clear, alarm), the rejected window accesses and commands, recovery by the soft reset, no false fault, detection disabled | TEST-020 |
| `mask_reg64`, `mask_reg32` | `PARA_MASK` = 1, seed registers | Masked digests of the six SHA-3 and SHAKE algorithms (lengths 0, 1, rate-1, rate, rate+1, 2 x rate + 5) with three seeds, unmasked control messages on the same core, ERR-006 (masked message before the seed, event, then digest after the seed), soft reset clears `seeded` | TEST-012, TEST-021 |
| `mask_ent64` | `PARA_MASK` = 1, `PARA_SEED_SRC` = 0 | Eight entropy words after reset and after a soft reset, `sha_cmd.seed` rejected, masked digests | TEST-012 |
| `mask_stat64`, `mask_statctl64` | `PARA_MASK` = 1 | 300 blocks, fixed against random message (testbench command `hwgrp`), Hamming weight of both shares in each of the 48 cycles (`hwdump`); `scripts/mask_stat.py` computes the Welch t; the control run has `sha_ctrl.mask` = 0 and must exceed the limit | TEST-021 |
| `mask_fault64` | masked, all fault detections, alarm | Bit flips in a share, in the context memory (share 1) with the responses of 2a; recovery needs a new seed | TEST-020, TEST-021 |
| `main64_mask` | `PARA_MASK` = 1 | The whole `main64` set on the masked build (messages without masking compute on the same core) | TEST-001..006 |
| `ctx1`, `ctx2`, `ctx8`, `ctx16`, `dirctx1`, `dirctx2`, `dirctx16` | 1, 2, 8, 16 contexts | Edge, random, interleaved (`multi_c<N>`), and for 1, 2, 16: APB, error, interrupt, abort, tail and back-pressure tests that depend on the number of contexts | TEST-005, COV-006 |
| `limit64` | 2 contexts | Length limit (TEST-008): the byte counter of context 0 is preset 2 words below 2^61 with the testbench command `ctot` (force of the next-state signal for one clock); two words more are legal, four words more set `sha_irq_raw.len`, free the context and discard the digest; the context hashes again | TEST-008 |
| `xcheck.py` | zero and random power-up (3 seeds) | The same vectors with zero and with random initial register and memory values give the same output hash (testbench `OUTHASH`) and scoreboard; a control mutant (error read data from the resetless FIFO memory) must make the hashes differ | TEST-025 (15.3 X policy, two-state substitute) |
| `static_checks.py` | no simulator | Clock structure without gating, names of the SDC of section 17 | TEST-023, TEST-024 (structure and names only) |
| `perf_u1`, `perf_u2`, `perf_u4`, `perf_redo`, `boot` | unroll 1, 2, 4; recompute on; CFG-BOOT | Cycles per block, the halving by recompute, 4 MiB SHA-256 and SHA-384 | TEST-018 |
| `elab_tests.py` | verilator `--lint-only` | each algorithm alone; every illegal combination of section 8 | TEST-002, TEST-015 |
| `strict4ph_dma64` | not in the default regression | A DMA request withdrawn by abort (allowed by DEC-031); the strict 4-phase assertions STRICT-4PH-a to d report it | informational |
| `wf_tool.py` | 19 scenarios | One simulation per waveform of section 10.3 | R-033 |

Unit tests (`run_all.py`, `scripts/unit_mask.py`): the masked core against the plain core with random shares (60 runs) and the random bit source
against a Python Keccak model (seed registers and entropy port).

Not simulated: TEST-022 (static, `run_all.py` runs the rule check, lint and CSR verify),
TEST-023, TEST-024 (need SoC flows). A four-state X check is not possible with Verilator (two-state) and iverilog cannot compile the RTL (packed multi-dimensional indexing); the checkers
test `$isunknown` but a two-state simulator never shows X. `xcheck.py` is the substitute (random power-up values, TEST-025).

## Command-script format (`vec/*.vec`)

One command per line. `include <file>` (relative to `+VECDIR`), `tag <name>` (names the following checks), `apbw addr data`, `apbr addr`,
`chka addr mask value` (APB read compared), `chkerr 0|1` (PSLVERR of the last access), `apbwerr addr data 0|1`, `poll addr mask value tmo`,
`waitlvl n tmo` (output FIFO level), `axiw ctx n words...`, `axir ctx n`, `expect nbytes nwords words...` (digest compare, masks the unused bytes
of the last word), `expb`/`expr` (expected BRESP/RRESP), `expz`, `strb`, `strbl`, `win`, `rwin`, `burst`, `rburst`, `wsize`, `rsize`, `awid`,
`pprot`, `pstrbw`, `pstrbr`, `static protect slverr`, `bp 0|1` (random back pressure), `rstc|rsta|rstb|rstov`, `axiabort`, `stream`, `perf0`, `perf1`,
`chkirq`, `chkalarm`, `hwgrp g` / `hwdump` (share statistics), `entdly n` (entropy source delay), `dmaman`, `waitin`, `waitout`, `chkreq`, `cov alg class`, `wait n`, `end`. Plusargs: `+VEC`, `+VECDIR`, `+CLASSES=<hex>`, `+VCD=<file>`,
`+TIMEOUT_NS`, `+AFIFO_MSYNC_SEED`.

## Assertions (R-024, R-025)

`tb/sha_checkers.sv` holds the assertions with ids; each name carries the standard clause or the specification requirement. A run prints the table
(`ASSERT <id> hits=<n> fails=<n> <name>`) and the last line `assertion failures: <n>, assertions never exercised: <n>`. The run fails when a
count is not 0. Class bits of `+CLASSES` select what the run enables: 0 APB protocol, 1 APB IP errors, 2 AXI protocol, 3 AXI IP errors,
4 cross checks, 5 DMA, 6 zeroing, 7 reset, 8 open findings (off in the default regression), 9 fault responses, 10 masking. A suite enables only classes whose stimulus it makes.
Stimulus-legality rules (APB-13, AXI-33 to AXI-35) are masked for exactly the cycles in which a test breaks them on purpose.

## Coverage (R-047)

Metrics: line and toggle (Verilator `--coverage-line --coverage-toggle`; branch points come with the line option). The covergroups of SystemVerilog are not
supported by Verilator, so the functional coverage COV-006 (algorithm x length class x context count x width) is counted from the `cov` lines of the logs
by `scripts/cov_report.py`. Status: `baseline_only` (the designer gave no target). See `reports/coverage_report.md`.
