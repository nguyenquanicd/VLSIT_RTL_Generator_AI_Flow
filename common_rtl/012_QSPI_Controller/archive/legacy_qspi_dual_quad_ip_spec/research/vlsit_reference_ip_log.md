# Reference IP Research Log

Research date: 2026-11-01

## Queries and search status

- Query: `QSPI SPI slave dual quad controller`; sources: GitHub and Gitee through `vlsit_ip_search.py search --source both --limit 10`. Both endpoints failed DNS resolution in this environment; the script returned zero candidates. `vlsit_ip_search.py evaluate` also failed DNS for the known GitHub repositories.
- Manual follow-up: reviewed official OpenTitan IP documentation and DV documents, the already downloaded pinned OpenTitan source tree, the Synopsys databook supplied by the user, and Chinese-language product/design documentation. No additional source code or document was downloaded.
- The decisions below apply the qualification filter: public license + testbench/verification evidence + ASIC tapeout or FPGA validation evidence. A synthesis report alone does not count as board-level FPGA validation.

## Candidate decisions

| Candidate | Relevant role / feature | Evidence inspected | License | Decision |
|---|---|---|---|---|
| OpenTitan `spi_host` | Standard/Dual/Quad controller; command and FIFO organization | Upstream HWIP document reports tapeout in Earl Grey 1.0.0; upstream DV document describes an SV/UVM testbench and protocol agent; pinned local source has `hw/ip/spi_host/dv/` collateral. | Apache-2.0 | **USED** for controller-side architecture and verification patterns. It is not a target/slave reference. [HWIP](https://opentitan.org/book/hw/ip/spi_host/index.html), [DV](https://opentitan.org/book/hw/ip/spi_host/dv/index.html), [repository license](https://github.com/lowRISC/opentitan/blob/master/LICENSE). |
| OpenTitan `spi_device` | Standard target/device behavior; flash-emulation and passthrough examples | Upstream HWIP document reports tapeout in Earl Grey 1.0.0; upstream DV document describes an SV/UVM testbench; pinned local source has `hw/ip/spi_device/dv/` collateral. | Apache-2.0 | **USED**, only for standard-target architecture and software-assisted buffering patterns. It does not implement full Dual-I/O/Quad-I/O/QPI target transfers. [HWIP](https://opentitan.org/book/hw/ip/spi_device/index.html), [DV](https://opentitan.org/book/hw/ip/spi_device/dv/index.html), [repository license](https://github.com/lowRISC/opentitan/blob/master/LICENSE). |
| Ayoub Achour `spi-fpga-core` | Both SPI controller and target, single data lane | Repository documents loopback/random tests and synthesis reports for FPGA families; no named board-level run or bitstream validation was found in the evidence inspected. | GPL-3.0-or-later or commercial terms stated upstream | **EXCLUDED** under the evidence filter: verification and license evidence exist, but FPGA validation or tapeout evidence was not established. Also single-lane only. [Repository](https://github.com/ayoub-ac/spi-fpga-core). |
| Synopsys DW_apb_ssi | Vendor reference for standard SPI and controller-side enhanced Dual/Quad | User-provided DW_apb_ssi Databook v4.05a; it documents parameter-gated Enhanced SPI and controller-only Dual/Quad configuration. No public RTL or testbench evidence was inspected. | Synopsys proprietary documentation/license | **EXCLUDED** as a qualified public reference IP. The supplied databook is used only as a cited implementation reference; no RTL or source prose is copied into the specification. |
| ArtInChip QSPI controller documentation | Vendor product documentation describing controller and target modes, including configurable Dual/Quad target mode | Official Chinese product documentation says controller mode generates SCLK; target mode uses external SCLK/CS and routes TX/RX through FIFOs; it says target mode can be configured for Dual or Quad. No public RTL, testbench, license, or independent silicon/FPGA evidence was found in the inspected material. | Not established from inspected source | **EXCLUDED** from qualified IP references. It is recorded as a product-document claim only. [Chinese source](https://aicdoc.artinchip.com/topics/ic/qspi/qspi-working-mode-2.html). |
| CSDN SPI/QSPI article by Xu Xiaokang | General SPI timing and single/dual/quad data-line concepts | Secondary-language article discusses CPOL/CPHA, CS/SCLK timing, shared IO0/IO1 in Dual mode, and four data lines/half-duplex in Quad mode. It is not an IP repository or verification artifact. | Not applicable | **EXCLUDED** as an IP reference and as a normative protocol source; retained only as a low-confidence cross-check. [Chinese source](https://openvela.csdn.net/694c90d45b9f5f31781a654f.html). |

## Chinese-language source findings (English summaries)

### ArtInChip QSPI working modes

The product document describes a configurable controller/target peripheral. In controller mode, the block produces SPI clock and moves TX FIFO data toward the external device while receiving into RX FIFO. In target mode, the external controller supplies SCLK and chip select; the IP sends queued data and receives host data. The document says target mode defaults to one lane and can be configured for Dual or Quad operation with the target output-enable setting. This is useful as a product-level architectural example, but the document alone does not establish the underlying implementation, timing closure, verification completeness, or license for reuse. **Confidence: low** for the implementation claim because only a product document was available. The planned IP scope remains the user-confirmed choice: Standard SPI in both roles; Dual/Quad controller-only.

### CSDN SPI master/target and QSPI overview

The article describes the four CPOL/CPHA combinations, explains that Dual mode reuses two bidirectional IO lines, and describes Quad mode as four shared data lines with half-duplex transfers. It also emphasizes chip-select and SCLK timing. These points are a useful cross-check, but the article is secondary and contains broad historical/performance simplifications; it is not used to define normative timing or command behavior. The selected external device datasheet and the supplied Synopsys databook take precedence. **Confidence: low.**

## Findings that shape the specification

1. Separate the base SPI frame format from the number of data lanes in the nomenclature and configuration model; the Synopsys databook uses distinct frame-format and enhanced-SPI fields.
2. Keep Standard SPI controller and target paths in scope. The user selected Dual/Quad controller-only; do not silently imply Dual/Quad target support.
3. Define chip-select behavior, CPOL/CPHA, bit order, transfer phase layout, dummy cycles, and target timing against an explicit target-device profile. SPI is a de-facto interface with device-specific command/timing details.
4. OpenTitan `spi_host` and `spi_device` are qualified, complementary references for the host and target roles respectively, but neither alone implements the complete requested architecture.

## What was not done

- Automated GitHub/Gitee search/evaluation could not complete because DNS resolution failed. Manual inspection used official upstream project documentation and locally downloaded source, with the evidence cited above.
- No new IP source or external document was downloaded.
- No RTL, simulation, lint, synthesis, FPGA validation, formal verification, or PPA was performed for the proposed IP.
