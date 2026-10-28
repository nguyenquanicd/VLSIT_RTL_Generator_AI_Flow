# CRC Reference IP Research Log

Date: 2026-10-27

## Search

- Query: `CRC generator SystemVerilog`.
- Required `vlsit_ip_search.py` query to GitHub and Gitee could not resolve DNS in this environment. A web-search fallback was used to inspect public GitHub repository pages.
- No RTL was downloaded or copied.

## Candidate review

| Candidate | Verification and implementation evidence | License | Decision |
|---|---|---|---|
| [UofT-HPRC/Tbps_CRC](https://github.com/UofT-HPRC/Tbps_CRC) | README lists a SystemVerilog CRC core, cocotb simulation, randomized software-reference comparisons, FPGA bitstream/on-board validation, and an Alveo U250 based performance setup. It cites the 2022 ICFPT paper and a Zenodo DOI. These claims are from the repository; board logs and paper details were not independently checked. | MIT, as identified by the repository | USED as an architecture/interface reference only; medium confidence in the repository's FPGA-validation claim. No source code copied. |

## Findings used in this specification

- A configurable CRC engine can expose elaboration-time polynomial/data-width choices and support byte enables for partial final words.
- A frame-oriented stream interface can pair valid/data/last/byte-enable fields with a separately qualified CRC result.
- The reference's throughput and FPGA timing claims are not transferred to this ASIC specification.
- No external CRC profile is selected. The local `crcCalculator/README.md` and `common_rtl/003_CRC/README.md` describe the existing project behavior and are used to identify legacy semantics, not to override approved requirements here.

## Limits

- GitHub/Gitee access from the required local search script failed because hostname resolution was unavailable.
- The fallback review did not download the source, independently reproduce FPGA results, or establish ASIC PPA.
- No candidate code is used as an implementation source.
