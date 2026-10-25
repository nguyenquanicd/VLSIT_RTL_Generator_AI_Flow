# Reference IP research log - Asynchronous APB bridge

Date: 2026-10-25. Tool: `vlsit_ip_search.py search ... --source both` (GitHub and Gitee). Rules: R-010 (evidence filter), R-011 (Chinese-language sources), R-012 (no copy of reference IP).

## Queries

| Query | Source | Candidates | Qualified by the script |
|---|---|---|---|
| apb async bridge clock domain crossing | GitHub + Gitee | 1 | 0 |
| apb cdc bridge verilog | GitHub + Gitee | 2 | 0 |
| apb cdc | GitHub + Gitee | 10 | 0 |
| apb clock domain crossing | GitHub + Gitee | 10 | 0 |
| apb async bridge 2-phase handshake | GitHub + Gitee | 0 | 0 |
| Chinese queries (asynchronous APB bridge, APB across clock domains) | GitHub + Gitee | 0 | 0 |

## Candidates and decisions

| Candidate | Evidence found | Licence | Decision |
|---|---|---|---|
| github.com/pulp-platform/apb_asynch_cdc | none found by the script (the repository is the known PULP APB clock-domain-crossing block, stars 9) | NOASSERTION | EXCLUDED: no licence and no tapeout, FPGA or verification evidence recognised by the script. Not read. |
| github.com/noammalca1/AXI4-Lite-to-APB-Bridge-with-Asynchronous-CDC | verification only | MIT | EXCLUDED: no tapeout or FPGA evidence; AXI4-Lite to APB bridge, not an APB to APB bridge |
| github.com/pravin1245/CDC_2_APB | FPGA keyword, verification | none | EXCLUDED: no licence |
| github.com/ketan-jamdar/AMBA-AHB-to-APB-Bridge-with-Clock-Domain-Crossing-CDC | FPGA keyword, verification | none | EXCLUDED: no licence; AHB to APB bridge |
| github.com/rvishal2006/APB-Integrated-Asynchronous-FIFO | FPGA keyword, verification | none | EXCLUDED: no licence; FIFO based |
| github.com/ghosharya28/Chipcraft-NIELIT | FPGA keyword, verification | none | EXCLUDED: no licence |
| github.com/Apurvkm/AMBA-APB4-TrustZone-CDC-Bridge | verification | none | EXCLUDED: no licence, no tapeout or FPGA evidence |
| github.com/karthdjd/APB_async_CDC, PranavJois/Multi-Clock-APB-System-with-CDC, kumarkhandagle/cdc_axi2apb | none | none | EXCLUDED: no licence, no evidence |
| AHB to APB bridge repositories (6 candidates) | FPGA keyword, verification | none | EXCLUDED: no licence; wrong protocol pair |

## Chinese-language sources (R-011)

Two Chinese queries returned no candidate on GitHub or Gitee. No Chinese page was read and none is cited. Confidence in "no useful Chinese source exists": low (the search engine of the script is limited to repository search, not CSDN or Zhihu articles).

## Accepted references

None. No candidate is qualified under R-010, so none is used, and nothing was downloaded or read beyond the search listings.

## Findings that shaped the specification

None from public IP. The architecture (toggle or 4-phase handshake with bundled data held stable) follows the sibling IP `001_AsyncGrayFIFO` of this repository for the software-reset handshake and the synchronizer cell selection, and the AMBA APB protocol of `reference/md_doc/vlsit_apb_amba_apb_ihi0024d.md`.

## What was not done

- No repository was cloned or downloaded.
- CSDN, Zhihu and OpenCores were not searched.
