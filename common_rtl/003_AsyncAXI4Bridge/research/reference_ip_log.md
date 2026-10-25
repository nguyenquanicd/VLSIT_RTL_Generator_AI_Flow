# Reference IP research log - Asynchronous AXI bridge

Date: 2026-10-25. Tool: `vlsit_ip_search.py search ... --source both` (GitHub and Gitee). Rules: R-010 (evidence filter), R-011 (Chinese-language sources), R-012 (no copy of reference IP).

## Queries

| Query | Source | Candidates | Qualified by the script |
|---|---|---|---|
| axi4 async bridge verilog | GitHub + Gitee | 0 | 0 |
| axi clock domain crossing bridge | GitHub + Gitee | 3 | 0 |
| AXI异步桥 clock domain crossing (Chinese) | GitHub + Gitee | 0 | 0 |

## Candidates and decisions

| Candidate | Evidence found | Licence | Decision |
|---|---|---|---|
| https://github.com/Marivenkatesh-23/Telemetry-Integrated-AXI-Bridge-for-CDC | Keywords tapeout, verification, asic-flow in the description; 1 star | none stated | EXCLUDED: no licence, and the evidence is a claim in the description only |
| https://github.com/mikolajnawr/AXI4-Stream-Chip2Chip-Bridge-with-UVM-Verification | FPGA, testbench (UVM); 3 stars | none stated | EXCLUDED: no licence; the protocol is AXI4-Stream, not AXI |
| https://github.com/troy323/AXI-to-APB-Bridge | testbench only | none stated | EXCLUDED: no licence, no tapeout or FPGA evidence; a protocol-conversion bridge, not a clock-domain-crossing bridge |

## Chinese-language sources (R-011)

The Chinese query returned no candidate, so there is no Chinese-language page to summarize. No Chinese-language source was read.

## Accepted references

None. No candidate is qualified under R-010, so none is used, and no code was downloaded or read.

## Findings that shaped the specification

None from public IP. The specification is built on the sibling IP `001_AsyncGrayFIFO` of this repository (each channel is one asynchronous Gray FIFO) and on the converted AXI standard `vlsit_axi_amba_axi_ihi0022h_c.md` (Arm IHI 0022 issue H.c).

## What was not done

- No repository was cloned or downloaded.
- No search was made on OpenCores or other sites.
