# Performance results (TEST-018)

Cycles are counted by the testbench from just before the first message word to `sha_sts.ready` (core clock). Cycles per block is the slope between a 40-block and a 120-block message (the padding block is counted).

| Configuration | Algorithm | Unroll | Cycles per block (measured) | Formula max(R/UNR+2, words+4) | Difference | Bits per cycle | Gbit/s at 500 MHz | Result |
|---|---|---|---|---|---|---|---|---|
| perf_u1 | sha256 | 1 | 66.00 | 66 | +0.00 | 7.76 | 3.88 | PASS |
| perf_u1 | sha512 | 1 | 82.00 | 82 | +0.00 | 12.49 | 6.24 | PASS |
| perf_u1 | sha3_256 | 1 | 26.00 | 26 | +0.00 | 41.85 | 20.92 | PASS |
| perf_u1 | sha3_512 | 1 | 26.00 | 26 | +0.00 | 22.15 | 11.08 | PASS |
| perf_u2 | sha256 | 2 | 34.00 | 34 | +0.00 | 15.06 | 7.53 | PASS |
| perf_u2 | sha512 | 2 | 42.00 | 42 | +0.00 | 24.38 | 12.19 | PASS |
| perf_u2 | sha3_256 | 2 | 21.00 | 21 | +0.00 | 51.81 | 25.90 | PASS |
| perf_u2 | sha3_512 | 2 | 14.00 | 14 | +0.00 | 41.14 | 20.57 | PASS |
| perf_u4 | sha256 | 4 | 18.00 | 18 | +0.00 | 28.44 | 14.22 | PASS |
| perf_u4 | sha512 | 4 | 22.00 | 22 | +0.00 | 46.55 | 23.27 | PASS |
| perf_u4 | sha3_256 | 4 | 21.00 | 21 | +0.00 | 51.81 | 25.90 | PASS |
| perf_u4 | sha3_512 | 4 | 13.00 | 13 | +0.00 | 44.31 | 22.15 | PASS |

| Check | Measured | Limit | Result |
|---|---|---|---|
| PERF-001 4 MiB sha256, CFG-BOOT | 2228283 cycles = 4.46 ms at 500 MHz; minimum clock for 5 ms: 446 MHz | 2,500,000 cycles (5 ms at 500 MHz) | PASS |
| PERF-001 4 MiB sha384, CFG-BOOT | 1376339 cycles = 2.75 ms at 500 MHz; minimum clock for 5 ms: 275 MHz | 2,500,000 cycles (5 ms at 500 MHz) | PASS |
| PERF-002 sha256 unroll 4, one stream | 14.22 Gbit/s at 500 MHz | >= 8 Gbit/s | PASS |
| PERF-002 sha3_256 unroll 2, one stream | 25.90 Gbit/s at 500 MHz | >= 8 Gbit/s | PASS |

| Recompute detection (unroll 1) | Cycles per block (measured) | 2 x (R/UNR + 2) | Result |
|---|---|---|---|
| sha256 | 132.00 | 132 | PASS |
| sha512 | 164.00 | 164 | PASS |
| sha3_256 | 52.00 | 52 | PASS |
| sha3_512 | 52.00 | 52 | PASS |

| Masked Keccak (unroll 1, pipe 2) | Cycles per block (measured) | 2 x 24 + 2 | Bits per cycle | Gbit/s at 500 MHz | Result |
|---|---|---|---|---|---|
| sha3_256 | 50.00 | 50 | 21.76 | 10.88 | PASS |
| sha3_512 | 50.00 | 50 | 11.52 | 5.76 | PASS |
