# QSPI RTL generation plan — designer-approved architecture

## Inputs and status

| Item | Selected value |
|---|---|
| Specification | `VLSIT_QSPI_CONTROLLER_HDS.md` (current normative revision) |
| CSR workbook | `qspi_CSR_Specification_RTL.xlsx`, sheet `CSR` |
| RTL naming/rules | `C:\Users\PC\.codex\skills\vlsit-rtl-generator\rule.md`, VLSIT RTL Design Rules v2 |
| Project / header owner | `QSPI_Controller` / `Nguyen Quan` |
| Output | Package root; synthesizable RTL in `rtl/` and generated CSR in `rtl/csr/` |
| Architecture approval | User approved Option B on 2026-11-02, including the hierarchy/ports in this plan and the external ports in Section 6.2 of the working spec |

RTL is assembled at `m_qspi`; the final rule check and Verilator lint results are recorded in `RTL_Generation_Report.md`. The working spec records independent target sample/shift clocks (DEC-018) and APB-synchronized target reset release (DEC-019). The redundant `qspi_ctrl.format` field is now reserved; indirect commands select format through `qspi_cmd.format`, while XIP selects its profile through `qspi_xip_cfg.format`.

## Approved architecture

- Separate `m_qspi_controller_engine` (`i_clk_serial`) and `m_qspi_target_engine` (`i_clk_tgt_sample`, `i_clk_tgt_shift`) share one serial IO pad interface and are mutually exclusive. Target RX runs on the selected sample edge; target TX runs on the opposite selected shift edge.
- `m_qspi_tgt_fifo_clock` has independent sample/shift selectors and captures CPHA, bit order and word length while CS is inactive. `sample_edge_rise = (CPOL == CPHA)` and `shift_edge_rise = (CPOL != CPHA)`; each selects SCLK or inverted SCLK while CS is inactive. Target FIFO side-effect enables remain low while CS is inactive. STA constrains both generated clocks.
- A one-word APB-held target TX head supplies the first MISO word before SCLK starts; the payload stays stable until the target acknowledges the completed word. Later TX words use the target TX AFIFO.
- Controller and target roles have independent 32-bit TX/RX asynchronous FIFO pairs. APB FIFO-data accesses route to the pair selected by `qspi_ctrl_role`.
- XIP and indirect commands use the controller engine only. Round-robin arbitration selects between them; one XIP burst is outstanding and is atomic after grant.
- Top-level ports and widths are the complete Section 6.2 table of the working spec; the module ports below are internal.
- Reset release uses `m_vlsit_rst_sync`; payload storage uses `m_vlsit_afifo_top`.

## Module hierarchy and port plan

Ports listed in rows are individual scalar/vector ports, not SystemVerilog interfaces. Parameters are the `PARA_*` entries in Section 8 of the working spec.

| Module | Responsibility and proposed ports |
|---|---|
| `m_qspi_reset_sync` | Inputs: APB, AXI and controller clocks/resets. Outputs synchronized APB, AXI and controller resets. Target sample/shift and target FIFO resets use the APB-synchronized target release because external SCLK can stop while idle; SoC keeps CS inactive until reset release. |
| `m_qspi_tx_fifo_ctrl` / `m_qspi_rx_fifo_ctrl` | Each is a 32-bit wrapper around `m_vlsit_afifo_top`; parameter `PARA_FIFO_DEPTH`. Controller pair clocks: APB and `i_clk_serial`. Exposes write/read enables/data, full/empty and overflow/underflow. `i_rst_n_sw` is tied inactive. |
| `m_qspi_tx_fifo_tgt` / `m_qspi_rx_fifo_tgt` | Same wrapper ports and width/depth as controller pair. TX clocks: APB write / selected target shift-edge read; RX clocks: selected target sample-edge write / APB read. `i_rst_n_sw` is tied inactive. |
| `m_qspi_target_tx_head` | APB write/data and head-full/token status; target sample-edge clock/reset and one-word-consumed event. Holds the first target TX word stable until the RX sample engine confirms the full word was sampled; the token prevents duplicate acknowledgement before APB observes the returned acknowledge. |
| `m_qspi_apb_decode` | Inputs: APB4 `i_apb_psel`, `i_apb_penable`, `i_apb_paddr[15:0]`, `i_apb_pwrite`, `i_apb_pwdata[31:0]`, `i_apb_pstrb[3:0]`, `i_apb_pprot[2:0]`; CSR response; active-role FIFO full/empty/data; target CS/head status. Outputs: APB `o_apb_pready`, `o_apb_prdata[31:0]`, `o_apb_pslverr`; generated-CSR APB request; role-selected TX push/data, RX pop and target-head push/data. Target head window is `0x1008`. |
| `m_vlsit_csr_qspi` *(generated)* | One instance from the approved workbook. Ports are the generator-derived `CSR` sheet inventory. `i_protect_en=0`, `i_slverr_en=1`; generated source is never hand-edited. |
| `m_qspi_axi_xip` | Inputs: `i_clk_axi`, `i_rst_n_axi`, all AXI4 ports from Section 6.2, XIP config/status, controller-response valid/data/resp. Outputs: AXI READY and B/R response pins, controller XIP request valid/data and response ready. Widths are `PARA_AXI_*`; requests encode one accepted INCR burst. |
| `m_qspi_indirect` | Inputs: APB-domain CSR command/address/length/config, controller TX/RX FIFO status/data and controller response. Outputs: controller command valid/data, TX FIFO read, RX FIFO write, busy/done/error updates to generated CSR. User-selected active configuration is snapshotted at acceptance. |
| `m_qspi_cdc` | Inputs/outputs: APB and AXI request/response valid-ready payloads; controller-domain XIP/indirect queues. Uses `m_vlsit_afifo_top` for payload CDC. |
| `m_qspi_event_sync` / `m_qspi_toggle_sync` | Transfer controller event pulses and target error toggles to APB with request/acknowledge CDC. |
| `m_qspi_arbiter` | Clock/reset: `i_clk_serial`, `i_rst_n_serial`. Inputs: XIP and indirect valid/payload, `i_target_active`, controller ready/done. Outputs: each source ready, selected controller command/payload, owner and response route. Round-robin between XIP and indirect; no grant in target role. |
| `m_qspi_controller_engine` | Clock/reset: `i_clk_serial`, `i_rst_n_serial`. Inputs: selected command, controller TX FIFO valid/data, RX FIFO ready, `i_spi_io_i[3:0]`. Outputs: ready/busy/done/error, TX FIFO ready, RX FIFO valid/data, `o_clk_spi_ctrl`, `o_spi_cs_ctrl_n[PARA_NUM_CS-1:0]`, controller IO data/enable `[3:0]`. Implements Standard, Dual, Quad and QPI controller formats. |
| `m_qspi_tgt_fifo_clock` | Inputs: target SCLK, CPOL/CPHA-derived sample/shift edge selectors, target frame fields, CS, TX read enable and RX write enable. Outputs: captured CPHA/bit-order/word-length settings and independently selected sample/shift clocks. Uses `VLSIT_CELL_LAT_L`, `VLSIT_CELL_CKINV` and two `VLSIT_CELL_CKMUX2` cells from common `rtl_cells`; phase selectors are held while CS is active. |
| `m_qspi_target_engine` | Independent `i_clk_tgt_sample` RX and `i_clk_tgt_shift` TX engines, with APB status clock. Inputs include captured target config, APB-held TX head/token, tail TX FIFO, RX FIFO full and target pads. Outputs: one sample-domain head acknowledgement per token/RX push, shift-domain TX pop, MISO/IO enable, APB frame events and error toggles. |
| `m_qspi_pin_mux` | Inputs: `i_role_target`, controller/target IO data and enable `[3:0]`, common `i_spi_io_i[3:0]`. Outputs common `o_spi_io_o[3:0]`, `o_spi_io_oe[3:0]` to SoC pads. Top-level controller SCLK/CS outputs and target SCLK/CS inputs remain separate ports for SoC pad mapping. |
| `m_qspi` | Structural top. Instantiates the modules above and exposes exactly Section 6.2 ports and Section 8 parameters. No serial clock mux. |

## Reuse and source dependencies

- Reuse `m_vlsit_afifo_top` unchanged for four role-specific TX/RX queues and AXI/controller CDC queues. Include its modules and dependencies listed by the common RTL filelists.
  - Reuse `m_vlsit_rst_sync` unchanged for APB, AXI, controller and target reset release. Target reset release is synchronized to APB and distributed to both target phase domains; no external SCLK edge is needed to release reset.
- Generate CSR RTL from the workbook with APB-CSR-Generator; place generated files in `rtl\csr` and verify their manifest. Do not hand-edit generated RTL.
  - Both target sample and shift clocks are selected while CS is inactive; reset release is APB-synchronized and settled before CS assertion. Side-effect enables remain inactive until CS is asserted.

## Implementation review notes

- XIP admission also requires `qspi_ctrl_en=1`; otherwise the AXI read returns SLVERR. This avoids accepting a request when the controller engine cannot accept it.
- Unsupported AXI exclusive reads (`ARLOCK=1`) are rejected with SLVERR; the XIP endpoint does not implement exclusive access.
- Lane format is configured per transaction class: `qspi_cmd.format` for indirect commands and `qspi_xip_cfg.format` for XIP reads. The former `qspi_ctrl.format` bit range is reserved and reads as zero; no global format output is generated or connected.
- Target RX partial-word indication is synchronized into APB before it contributes to the sticky error event. APB-visible frame completion is already derived in APB from synchronized CS.
- There is no simulation testbench in this output because none was requested. CDC timing, target setup/hold, generated-clock constraints, and functional waveforms still require verification against the SoC clock/pad constraints and the approved waveform plan.

## Approved implementation choices recorded in the working spec

- Multi-lane MSB-first maps the next highest-order bit to the highest active IO lane, descending; LSB-first maps the next lowest-order bit to IO0, ascending.
- XIP accepts naturally aligned 1-, 2- or 4-byte reads, rejects misaligned reads with SLVERR and emits no flash command for rejected requests.
- Target RX FIFO overflow drops the newest complete word, sets sticky `rx_err` and continues to CS deassertion. Target TX underflow transmits ones; partial final RX words are discarded and set `rx_err`.
- Busy configuration writes apply to later commands; a busy `start` is cleared and sets sticky `fl_err`.

The designer approved this hierarchy and external port list. Proceed with leaf modules first, run the RTL rule checker after each module, generate CSR only with the generator, then create `filelist.f` and run final rule check/lint. No testbench is included because none was requested.
3. Target RX samples on `i_clk_tgt_sample` and writes the RX FIFO on that same edge. Target TX shifts on `i_clk_tgt_shift`; its TX FIFO read pointer uses that clock. Both phase selectors remain fixed from CS assertion through frame completion. The target head is acknowledged after the matching RX word sample completes.
