# Reference IP research log - Synchronous-Clock FIFO

Date: 2026-10-23. Tool: `vlsit_ip_search.py search ... --source both` (GitHub and Gitee). Rules: R-010 (evidence filter), R-011 (Chinese-language sources), R-012 (no copy of reference IP).

## Queries

| Query | Source | Candidates | Qualified by the script |
|---|---|---|---|
| synchronous fifo verilog | GitHub + Gitee | 8 | 1 |
| fifo synchronous clocks different frequency ratio | GitHub + Gitee | 0 | 0 |
| sync fifo asic tapeout | GitHub + Gitee | 0 | 0 |
| 同步FIFO verilog (Chinese) | GitHub + Gitee | 4 | 0 |

## Candidates and decisions

| Candidate | Evidence found | Licence | Decision |
|---|---|---|---|
| https://github.com/diwakar-manikandan/fifo_verification | README says "Simulation Verified" with Vivado XSIM; single clock, 8-bit by 8-entry; no FPGA board run | MIT | EXCLUDED: the script counted a tool keyword as FPGA evidence, but the README shows simulation only; also single clock and fixed size |
| https://github.com/ultraembedded/core_ftdi_bridge | FPGA keyword; FIFO is a part of an FTDI bridge | GPL-2.0 | EXCLUDED: no verification evidence; not a FIFO IP; copyleft licence |
| https://github.com/iammituraj/fifo | FPGA keyword | none stated | EXCLUDED: no licence, no verification evidence |
| https://github.com/snbk001/Verilog-Design-Examples | testbenches | none stated | EXCLUDED: no licence, no tapeout or FPGA evidence |
| https://github.com/surangamh/synchronous-fifo | testbench | none stated | EXCLUDED: no licence, no tapeout or FPGA evidence |
| https://github.com/Kholoud-Ebrahim/Synchronous_FIFO | testbench | none stated | EXCLUDED: no licence, no tapeout or FPGA evidence |
| https://github.com/avashist003/FIFO_SystemVerilog_Assertion | assertions | none stated | EXCLUDED: no licence, no evidence |
| https://github.com/ameyjain/VERILOG-RootMeanSquareCalculator | none | none stated | EXCLUDED: not a FIFO, no evidence |
| https://github.com/cuitsj/RAM_FIFO (Chinese, read in depth) | see the English summary below | none stated | EXCLUDED: no licence |
| https://github.com/zhengzhideakang/Verilog--FIFO | none | MIT | EXCLUDED: no tapeout or FPGA evidence, no verification evidence |
| https://github.com/family5love/syn_fifo | none | none stated | EXCLUDED: no licence, no evidence |
| https://github.com/JasonYU888/Basic-Verilog-Designs | none | none stated | EXCLUDED: no licence, no evidence |

## Chinese-language source: summary (R-011)

`cuitsj/RAM_FIFO` is a Chinese user manual with Verilog modules for a single-port RAM, a simple dual-port RAM, a true dual-port RAM, a synchronous FIFO and an asynchronous FIFO. For each module it gives an instantiation template, port and parameter tables, a behavioral simulation and a comparison of the synthesis result (timing, resources, power) with the Xilinx IP core of Vivado 2018.3. The repository description claims that the modules can fully replace the Xilinx IP cores. The synchronous FIFO there uses a single clock. Confidence: low to medium (the comparison is FPGA-only, there is no silicon evidence, and the claim is from the author). Nothing was downloaded and no content was copied; the missing licence forbids reuse.

## Accepted references

None. No candidate is qualified under R-010, so none is used, and no code was downloaded or read beyond the README text of two repositories.

## Findings that shaped the specification

None from public IP. The specification inherits its structure and decisions from the sibling IP `001_AsyncGrayFIFO` of this repository and from the decisions of the designer (section 20).

## What was not done

- No repository was cloned or downloaded.
- No search was made on OpenCores or other sites; the evidence filter found nothing that would qualify for the two-synchronous-clock case.
