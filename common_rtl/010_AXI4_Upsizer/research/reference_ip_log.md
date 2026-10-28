# Reference IP research log (rule R-010, R-011, R-012)

Date: 2026-10-27. Purpose: find silicon- or FPGA-proven AXI data width converters to study the design choices of an upsizer. Only searches and pages were read; nothing was downloaded. No text or code of any IP is copied into the specification (R-012); ideas only.

## Searches (script `vlsit_ip_search.py search`)

| Source | Query | Result |
|---|---|---|
| GitHub and Gitee | `axi data width converter upsizer` | 0 candidates |
| GitHub and Gitee | `axi dw converter` | 0 candidates |
| GitHub and Gitee | `axi adapter width` | 1 candidate, `Germanyy0410/axi-data-width-adapter`: EXCLUDED (no licence, no tapeout or FPGA evidence, no verification evidence) |
| Gitee | `AXI 位宽转换` (Chinese), `axi upsizer`, `AXI data width converter` | 0 candidates; no Chinese-language source was found, so none was read (R-011) |

## Evaluation of known IP (script `vlsit_ip_search.py evaluate`, pages read with curl)

| IP | Licence read on the page | Evidence | Verdict | Used for |
|---|---|---|---|---|
| `https://github.com/pulp-platform/axi` (module `axi_dw_upsizer`, with `axi_dw_converter` and `axi_dw_downsizer`) | Solderpad Hardware License v0.51 (LICENSE file) | README: synthesizable modules, verification infrastructure, parametrizable data width and transaction concurrency. The script scores FPGA and verification evidence. The README read does not state a tapeout, so the tapeout evidence is not confirmed | QUALIFIED by the script (score 3) | Idea: an upsizer is a separate module from a downsizer; packing only of Modifiable bursts |
| `https://github.com/alexforencich/verilog-axi` (`axi_adapter`) | MIT (GitHub API) | cocotb testbenches (cocotbext-axi), FPGA-oriented; README says the repository is deprecated in favour of `fpganinja/taxi`; supports INCR and narrow bursts only | QUALIFIED by the script (score 3) | Idea: separate write and read adapters; narrow bursts kept |
| `https://github.com/ZipCPU/wb2axip` | Not shown by the GitHub API | Formal verification stated in the README | EXCLUDED: licence not confirmed | None |

## Design ideas taken (no copy)

- Split the converter into a write path and a read path with their own order queues.
- Pack only when the protocol allows it (Modifiable, REF-001 A4.3.1); keep Non-modifiable transactions as narrow transfers on the wide bus.
- The WRAP burst needs a start address aligned to the transfer size, so a WRAP burst is packed only when the aligned container fits (DEC-015, decided by this specification, not taken from a reference).
