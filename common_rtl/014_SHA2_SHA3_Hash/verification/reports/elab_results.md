# Elaboration tests

Tool: verilator --lint-only (OSS CAD Suite). TEST-002 and TEST-015 of the specification.

## TEST-002: each algorithm alone, only its core is built

| Algorithm | Elaborates | core256 | core512 | keccak | Result |
|---|---|---|---|---|---|
| SHA224 | yes | True | False | False | PASS |
| SHA256 | yes | True | False | False | PASS |
| SHA384 | yes | False | True | False | PASS |
| SHA512 | yes | False | True | False | PASS |
| SHA512_224 | yes | False | True | False | PASS |
| SHA512_256 | yes | False | True | False | PASS |
| SHA3_224 | yes | False | False | True | PASS |
| SHA3_256 | yes | False | False | True | PASS |
| SHA3_384 | yes | False | False | True | PASS |
| SHA3_512 | yes | False | False | True | PASS |
| SHAKE128 | yes | False | False | True | PASS |
| SHAKE256 | yes | False | False | True | PASS |

## TEST-015: illegal combinations stop the elaboration

| Combination | Elaboration | Error names | Result |
|---|---|---|---|
| all PARA_EN_* = 0 | stopped | `m_vlsit_sha_ERR_no_algorithm_built` found | PASS |
| PARA_S256_UNR = 3 (not a divisor of 64) | stopped | `m_vlsit_sha_ERR_s256_unr_not_divisor` found | PASS |
| PARA_S512_UNR = 3 (not a divisor of 80) | stopped | `m_vlsit_sha_ERR_s512_unr_not_divisor` found | PASS |
| PARA_KEC_UNR = 5 (not a divisor of 24) | stopped | `m_vlsit_sha_ERR_kec_unr_not_divisor` found | PASS |
| PARA_S256_PIPE = 2 (only 1 in this revision) | stopped | `m_vlsit_sha_ERR_pipe_stage_unsupported` found | PASS |
| PARA_S256_PIPE = 0 | stopped | `m_vlsit_sha_ERR_pipe_stage_unsupported` found | PASS |
| PARA_CTX_N = 0 | stopped | `m_vlsit_sha_ERR_ctx_n_out_of_range` found | PASS |
| PARA_CTX_N = 17 | stopped | `m_vlsit_sha_ERR_ctx_n_out_of_range` found | PASS |
| PARA_AXI_DW = 48 | stopped | `m_vlsit_sha_ERR_axi_dw_value` found | PASS |
| PARA_AXI_DW = 128 with SHA3-256 (rate 136 B) | stopped | `m_vlsit_sha_ERR_axi_dw_128_block_size` found | PASS |
| PARA_AXI_AW = 8 | stopped | `m_vlsit_sha_ERR_axi_aw_below_16` found | PASS |
| PARA_IN_DEPTH = 6 (not a power of 2) | stopped | `m_vlsit_sha_ERR_in_depth` found | PASS |
| PARA_IN_DEPTH = 8 with 32-bit bus (32 B < 64 B + 2 words) | stopped | `m_vlsit_sha_ERR_in_depth` found | PASS |
| PARA_OUT_DEPTH = 4 with 32-bit bus (16 B < 64 B) | stopped | `m_vlsit_sha_ERR_out_depth` found | PASS |
| PARA_CTX_MEM = 1 (reserved, DEC-016) | stopped | `m_vlsit_sha_ERR_ctx_mem_unsupported` found | PASS |
| PARA_MASK = 2 (legal values 0 and 1) | stopped | `m_vlsit_sha_ERR_mask_value` found | PASS |
| PARA_SEED_SRC = 2 (legal values 0 and 1) | stopped | `m_vlsit_sha_ERR_mask_value` found | PASS |
| PARA_SEED_SRC = 1 without PARA_MASK | stopped | `m_vlsit_sha_ERR_mask_value` found | PASS |
| PARA_MASK = 1 without a Keccak algorithm | stopped | `m_vlsit_sha_ERR_mask_needs_keccak_unr1` found | PASS |
| PARA_MASK = 1 with PARA_KEC_UNR = 2 | stopped | `m_vlsit_sha_ERR_mask_needs_keccak_unr1` found | PASS |
| PARA_MASK = 1 with PARA_KEC_PIPE = 1 | stopped | `m_vlsit_sha_ERR_pipe_stage_unsupported` found | PASS |
| PARA_KEC_PIPE = 2 without masking | stopped | `m_vlsit_sha_ERR_pipe_stage_unsupported` found | PASS |
| PARA_FAULT_DUP = 2 (legal values 0 and 1) | stopped | `m_vlsit_sha_ERR_fault_value` found | PASS |
| PARA_ALARM = 2 (legal values 0 and 1) | stopped | `m_vlsit_sha_ERR_fault_value` found | PASS |
| PARA_ALARM = 1 without a fault parameter | stopped | `m_vlsit_sha_ERR_alarm_needs_fault` found | PASS |

## Legal reference configurations elaborate

| Configuration | Result |
|---|---|
| CFG-BASE (defaults) | PASS |
| CFG-BOOT | PASS |
| 64-bit, 4 contexts, all algorithms | PASS |
| 128-bit, SHA-2 and SHA3-224 | PASS |
| stage 2a: all fault detections and the alarm, one algorithm | PASS |
| stage 2a: all fault detections, alarm, all algorithms, 4 contexts | PASS |
| stage 2a: parity only, 128-bit | PASS |
| stage 2b: masked Keccak, seed registers | PASS |
| stage 2b: masked Keccak, entropy port, all faults | PASS |
| stage 2b: all algorithms, 16 contexts, masked, seed registers | PASS |
