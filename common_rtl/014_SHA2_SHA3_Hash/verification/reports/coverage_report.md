# Code coverage report

Simulator and version: Verilator 5.053 (OSS CAD Suite) with `--coverage-line --coverage-toggle` (branch points are produced by the line option). Merged data of 48 suites (async_r1_1_seed1, async_r1_1_seed2, async_r1_1_seed3, async_r1_1_synth, async_r1_3_seed1, async_r1_3_seed2, async_r1_3_seed3, async_r1_3_synth, async_r2_7_seed1, async_r2_7_seed2, async_r2_7_seed3, async_r2_7_synth, async_r7_2_seed1, async_r7_2_seed2, async_r7_2_seed3, async_r7_2_synth, boot, ctx1, ctx16, ctx2, ctx8, dirctx1, dirctx16, dirctx2, dma128, dma32, dma64, fault_all64, fault_dup64, fault_par64, fault_redo64, limit64, main128, main32, main64, main64_mask, mask_ent64, mask_fault64, mask_reg32, mask_reg64, mask_stat64, mask_statctl64, perf_mask, perf_redo, perf_u1, perf_u2, perf_u4, strict4ph_dma64). DUT scope: the 15 files of `rtl/` (`m_vlsit_sha_*` and the generated `csr/`); instances of the same module in different hierarchy paths count separately. Excluded: library cells and library modules, the testbench, the checkers. No exclusion file is used: unreachable and stage-2 points are counted as uncovered. Status: `baseline_only` (no target was given, R-047).

| Scope | Line covered / total | Branch covered / total | Toggle covered / total |
|---|---|---|---|
| design | 1544 / 1682 (91.8 %) | 439 / 520 (84.4 %) | 31210 / 47872 (65.2 %) |
| csr (generated) | 78 / 85 (91.8 %) | 198 / 222 (89.2 %) | 3626 / 5250 (69.1 %) |

## Per file (design files and generated CSR files)

| File | Line | Branch | Toggle |
|---|---|---|---|
| m_vlsit_csr_sha.sv | 78 / 85 (91.8 %) | 198 / 222 (89.2 %) | 3618 / 5242 (69.0 %) |
| m_vlsit_csr_sync.sv | n/a | n/a | 8 / 8 (100.0 %) |
| m_vlsit_sha_axi_sub.sv | 49 / 58 (84.5 %) | 73 / 92 (79.3 %) | 1529 / 2568 (59.5 %) |
| m_vlsit_sha_core256.sv | 309 / 327 (94.5 %) | 14 / 16 (87.5 %) | 8755 / 10878 (80.5 %) |
| m_vlsit_sha_core512.sv | 366 / 381 (96.1 %) | 14 / 16 (87.5 %) | 878 / 1038 (84.6 %) |
| m_vlsit_sha_ctx_fifo.sv | 46 / 50 (92.0 %) | 28 / 28 (100.0 %) | 4426 / 6540 (67.7 %) |
| m_vlsit_sha_ctxmem.sv | 16 / 17 (94.1 %) | 18 / 18 (100.0 %) | 924 / 1066 (86.7 %) |
| m_vlsit_sha_dma.sv | 14 / 16 (87.5 %) | 42 / 42 (100.0 %) | 266 / 894 (29.8 %) |
| m_vlsit_sha_fault.sv | 7 / 7 (100.0 %) | 13 / 16 (81.2 %) | 1091 / 1094 (99.7 %) |
| m_vlsit_sha_irq.sv | 3 / 3 (100.0 %) | 4 / 4 (100.0 %) | 416 / 418 (99.5 %) |
| m_vlsit_sha_keccak.sv | 281 / 299 (94.0 %) | 14 / 16 (87.5 %) | 442 / 490 (90.2 %) |
| m_vlsit_sha_keccak_dom.sv | 174 / 198 (87.9 %) | 16 / 16 (100.0 %) | 860 / 864 (99.5 %) |
| m_vlsit_sha_outp.sv | 44 / 51 (86.3 %) | 28 / 36 (77.8 %) | 900 / 1368 (65.8 %) |
| m_vlsit_sha_pad.sv | 17 / 17 (100.0 %) | 10 / 10 (100.0 %) | 458 / 564 (81.2 %) |
| m_vlsit_sha_prng.sv | 80 / 82 (97.6 %) | 14 / 14 (100.0 %) | 1627 / 1668 (97.5 %) |
| m_vlsit_sha_sel.sv | 2 / 2 (100.0 %) | 2 / 2 (100.0 %) | 84 / 88 (95.5 %) |
| m_vlsit_sha_seq.sv | 136 / 174 (78.2 %) | 149 / 194 (76.8 %) | 3844 / 10782 (35.7 %) |
| m_vlsit_sha_top.sv | n/a | n/a | 4710 / 7552 (62.4 %) |
## Functional coverage COV-006 (algorithm x length class x AXI width)

Bins: length classes of TEST-001 (0, 1, rate-1, rate, rate+1, 2 x rate bytes, other) for every algorithm legal at the width (128-bit: SHA-2 and SHA3-224). Context counts simulated with hashing: [1, 2, 4, 8, 16] (the specification cross also lists other counts; they were not simulated).

| Width | Algorithms | Bins | Hit | Missing |
|---|---|---|---|---|
| 32 | 12 | 84 | 84 | none |
| 64 | 12 | 84 | 84 | none |
| 128 | 7 | 49 | 49 | none |

Uncovered points are listed in `coverage/uncovered_line.txt`, `uncovered_branch.txt` and `uncovered_toggle.txt`.

