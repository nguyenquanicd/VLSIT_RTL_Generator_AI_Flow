<a id="english-version"></a>
# OpenCoreLabsX AXI QSPI Controller — RTL Design Review

[English](#english-version) | [Tiếng Việt](#vietnamese-version)

**Review type:** static source and documentation review  
**Source revision:** [`35a2ae97eb1752c5fe173e9341d43f1c3b2654c6`](https://github.com/OpenCoreLabsX/axi-qspi-controller/commit/35a2ae97eb1752c5fe173e9341d43f1c3b2654c6)  
**Review date:** 2026-11-01  
**Disposition:** useful QSPI flash-master prototype and architectural reference; **not demonstrated tapeout-ready**. Findings below are source-based risks, not simulation-proven failures.

## 1. Executive assessment

The design combines an AXI register slave, a read-only AXI memory/XIP response path, a shared SPI/Dual/Quad flash engine, TX/RX FIFOs, and a single interrupt output. The modular structure is easy to follow, and the package includes a register map, UVM bring-up tests, a lint target, and a permissive MIT license.

Its strongest use case is an SoC master reading a serial flash through a 32-bit XIP window. The source is **master-only** and does not implement a QSPI slave endpoint. It also has important protocol and flash-profile constraints: one chip-select, fixed SCLK polarity/phase behavior, a 24-bit serialized flash address, 32-bit XIP beats, and only a subset of AXI register transactions. These constraints must become explicit integration requirements or be fixed before the design is treated as a reusable ASIC IP.

The highest-priority review items are:

1. The XIP read path uses `ARLEN` but does not use `ARSIZE` or `ARBURST`; it always interprets each response beat as four bytes.
2. The serial engine emits only three address bytes, while the AXI/XIP address and base are 32 bits.
3. SCLK is fixed idle-low and has no CPOL/CPHA setting. The state machine changes output data on one SCLK edge and samples input on the other; the intended flash mode and setup timing need confirmation against the selected flash datasheet.
4. Register-driven reads/writes support only 32-bit single-beat accesses. FIFO overflow and command-start collision behavior need an explicit software contract.
5. There is no command-level flash model in the provided UVM tests; the current verification collateral does not establish correct flash data, QSPI timing, XIP burst behavior, or ASIC PPA.

## 2. Source set reviewed

| File | Role reviewed |
|---|---|
| [`axi_qspi_wrapper.sv`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/rtl/axi_qspi_wrapper.sv) | Top-level port set, connection of AXI register and XIP paths, shared-core arbitration, QSPI pads |
| [`axi_qspi_axi4_interface.sv`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/rtl/axi_qspi_axi4_interface.sv) | Register access, response generation, FIFOs, interrupt state, start control |
| [`axi_qspi_mem_interface.sv`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/rtl/axi_qspi_mem_interface.sv) | XIP address decode, flash-read request, AXI R-channel assembly/backpressure |
| [`axi_qspi_core.sv`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/rtl/axi_qspi_core.sv) | Serial command/address/mode/dummy/data FSM, clock divider, IO direction |
| [`axi_qspi_fifo.sv`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/rtl/axi_qspi_fifo.sv) | Synchronous circular FIFO and parameterized depth behavior |
| [`axi_qspi_pkg.sv`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/rtl/axi_qspi_pkg.sv) | Operation/mode/state enums, register offsets, command constants |
| [`uvm/README.md`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/uvm/README.md), [`Makefile`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/Makefile), [`docs/index.html`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/docs/index.html) | Test intent, build targets, stated feature/verification limitations |

The primary hierarchy is `axi_qspi_wrapper` → AXI register interface + XIP interface + shared `axi_qspi_core`; the register interface instantiates TX/RX FIFOs. The design uses one `i_qspi_aclk` for all these blocks and an active-low asynchronous reset. The external QSPI pins are represented as four input bits, four output bits and four output-enable bits rather than an RTL `inout`; the pad wrapper must implement the correct IO-cell direction and reset behavior.

## 3. Detailed architecture and behavior

### 3.1 AXI register interface

The AXI subordinate exposes a register window from offsets `0x00` through `0x44`. Normal register reads and writes are 32-bit, single-beat transfers. AW and W are captured independently, then the write commits when both are available. `WSTRB` updates register bytes. Unsupported writes are answered with `SLVERR`; burst writes drain the remaining W beats before returning an error. Unsupported register reads return an error response, including a generated response sequence for requested read bursts.

### 3.2 Register inventory and reset values

The inventory below is extracted from `axi_qspi_pkg.sv` and reset assignments in `axi_qspi_axi4_interface.sv`. It is not yet the VLSIT CSR workbook.

| Offset | Register | Observed purpose | RTL reset value |
|---:|---|---|---:|
| `0x00` | `CTRL` | Start, operation selection, FIFO clear | `0x00000000` |
| `0x04` | `STATUS` | Busy/done/error, TX empty, RX valid, XIP active | read-only combination |
| `0x08` | `CLKDIV` | Serial clock divider | `3` |
| `0x0C` | `MODE` | SPI / Dual / Quad lane selection | `0` (SPI) |
| `0x10` | `CMD` | Manual command byte | `0x0B` |
| `0x14` | `FLASH_ADDR` | Manual command address | `0` |
| `0x18` | `LEN` | Manual data length | `0` |
| `0x1C` | `DUMMY` | Dummy cycles | `8` |
| `0x20` | `TXDATA` | TX FIFO write port | FIFO empty |
| `0x24` | `RXDATA` | RX FIFO read port | FIFO empty |
| `0x28` | `IRQ_EN` | Enables done/error interrupt causes | `0` |
| `0x2C` | `IRQ_STAT` | Sticky done/error status; write-one-to-clear | `0` |
| `0x30` | `VERSION` | Version constant `0x0001_0000` | `0x00010000` |
| `0x34` | `XIP_CTRL` | XIP enable | `0` |
| `0x38` | `XIP_BASE` | Host address window base | `0` |
| `0x3C` | `XIP_MASK` | XIP address decode mask | `0xFF000000` |
| `0x40` | `XIP_CMD` | XIP read command override | `0x0B` |
| `0x44` | `XIP_MODE` | Continuous-read enable and mode byte | `0x000001A0` |

The exact bit definitions, access policy and software programming sequence still need validation from the full RTL and intended software contract before they are placed in the CSR workbook/specification.

### 3.3 XIP memory interface

The XIP block decodes the host read address with `(ARADDR & XIP_MASK) == (XIP_BASE & XIP_MASK)`. A hit becomes one QSPI read of `(ARLEN + 1) × 4` bytes. The engine collects four serial bytes per 32-bit AXI R beat and asserts `RLAST` for the final beat. If `RREADY` is low, the block stops consuming additional QSPI RX bytes until the held AXI beat is accepted. An XIP window miss returns an error response.

The default mask `0xFF000000` describes a 16 MB host window when the base is aligned to that mask. The serial command path itself sends three address bytes, so the flash-side offset is limited to 24 bits in the current wrapper.

### 3.4 Serial engine and FIFO data flow

The core supports the lane selection `SPI`, `DUAL`, and `QUAD`; it emits the command on one lane, then emits address on one lane except for the XIP Quad-I/O path. Quad-I/O XIP can append a mode byte and dummy clocks. Read bytes flow into the RX FIFO/XIP assembler; program bytes are consumed from the TX FIFO. One QSPI chip-select is present.

The operation enum selects read, program, or erase. Command constants include fast-read (`0x0B`), Dual read (`0x3B`), Quad Output read (`0x6B`), Quad I/O read (`0xEB`), write-enable, status/config/ID, page-program and erase commands. The presence of a constant does not prove that every command can be executed correctly: the wrapper hardwires a three-byte address for all manual transactions and disables mode-byte/quad-address behavior for that path.

The default FIFO depth is 16 bytes. The FIFO uses a pointer width of `$clog2(DEPTH)` and naturally wraps at a power of two; a non-power-of-two override needs an explicit restriction or pointer-wrap logic.

## 4. Feature list

### Implemented in the reviewed source

- SystemVerilog modular flash controller with one shared QSPI engine.
- AXI register access path with independent AW/W acceptance, byte strobes and error responses for unsupported register transactions.
- Read-only AXI XIP path with base/mask decode, multi-beat 32-bit responses and downstream R-channel backpressure handling.
- SPI, Dual SPI and Quad SPI master data paths; four IO input/output/output-enable bits.
- Command, address, data-length, dummy-cycle and clock-divider configuration.
- Read/program/erase operation values and a set of common flash command constants.
- TX/RX FIFO, done/error sticky interrupt causes, IRQ enable and version register.
- Reset values and an asynchronous active-low reset in the current implementation.
- UVM test sources for register reset/read/write, XIP register setup, FIFO/IRQ smoke behavior and independent AW/W skew.
- Verilator lint target and an MIT license.

### Not implemented or not established by the reviewed package

- SPI slave/target mode.
- More than one flash chip-select.
- Configurable CPOL/CPHA; serial clock idles low in RTL.
- Four-byte flash addressing or configurable address-byte count at the wrapper.
- A programmable manual-transfer address phase or mode-byte phase.
- Automatic write-in-progress polling, completion timeout, command sequencer or flash reset recovery.
- A QSPI flash behavioral model in the UVM environment; the UVM README says command-level flash modeling should be added.
- Verified FPGA board execution, ASIC synthesis/PPA, silicon/tapeout evidence or external integration results.

## 5. Potential bugs and design risks

Severity is based on effect if the IP is used as a general AXI/QSPI controller. “Confirmed in RTL” means the code has the described behavior; it does not mean a testbench has demonstrated a failure on hardware.

| ID / severity | Finding and evidence | Impact | Recommended disposition |
|---|---|---|---|
| RSK-01 — High; confirmed behavior | **XIP does not qualify AXI transfer size/type.** `axi_qspi_mem_interface.sv` receives `ARLEN`, `ARSIZE`, and `ARBURST`, but computes bytes as four per beat and uses only `ARLEN` for the transaction. It does not reject narrow, fixed, or wrapping transfers. | A byte/halfword transfer can return four bytes as a word; a fixed/wrapping burst is served as sequential flash bytes. Software can see incorrect data or duplicate/skip addresses. | Accept only the supported aligned 32-bit INCR profile and return a defined error for other profiles, or implement AXI byte-lane and burst semantics. Add 4 KB boundary checks if required by the selected AXI revision. |
| RSK-02 — High; confirmed constraint | **Flash address is only 24 bits.** `axi_qspi_wrapper.sv` ties the core address-byte count to three; `load_addr_byte()` emits `[23:16]`, `[15:8]`, and `[7:0]`, never `[31:24]`. | XIP offsets above `0x00FF_FFFF` alias/truncate. The default 16 MB window fits, but a larger window or 32-bit-address flash does not. | Either explicitly limit and validate the flash window to 16 MB, or add configurable three/four-byte addressing and tests at the boundary. |
| RSK-03 — High; profile/timing confirmation required | **SCLK mode is fixed.** RTL resets/idles SCLK low and has no CPOL/CPHA configuration. The FSM updates output data on one SCLK edge and samples input on the opposite edge; the intended sampling mode and first-bit setup must be checked against the chosen flash datasheet. | A flash requiring another mode, or a timing interpretation different from the FSM, can return corrupt data or fail to recognize commands. | Name the supported mode explicitly and prove CS/SCLK/DQ timing with a flash model and timing waveforms. Add CPOL/CPHA only if required by the target device. |
| RSK-04 — High; confirmed behavior | **Manual command path always includes a three-byte address.** The wrapper hardwires `addr_bytes=3`; manual path forces address-mode and mode-byte enables low. | Commands that expect no address bytes (for example status/ID/write-enable sequences) cannot be represented as their normal command phases through this path. QPI/Quad-I/O manual address/mode phases are also unavailable. | Add an address-byte count and phase controls, or narrow the software-visible command set to the transactions the RTL really supports. |
| RSK-05 — High; confirmed behavior | **TX FIFO starvation aborts immediately.** In program state, when the core requests a byte and `TX_VALID` is low, it sets error and moves to STOP instead of waiting. | Software refill latency can terminate a long program early, especially when the transfer is longer than the default 16-byte FIFO. | Specify a prefill/streaming contract and timeout behavior; preferably stall SCLK/CS while waiting for TX data, or provide an explicit underflow response that software can recover from. |
| RSK-06 — High; confirmed behavior | **FIFO-full TX write can be acknowledged without storing data.** The AXI register write can return OKAY based on address/size; FIFO write enable is separately suppressed by FIFO full. Full sets a sticky generic error cause, but no `TX_FULL` bit is exposed in STATUS. | A full FIFO can silently drop the newly written byte from the transaction's perspective; software learns only through the shared error IRQ/status. | Gate the register write with FIFO availability and return an error/backpressure, or expose full status and define the software sequence. Separate overrun causes if software must diagnose them. |
| RSK-07 — High; width constraint | **Parameterized bus widths are not fully generic.** Register logic uses `[31:0]` data and four WSTRB lanes; XIP assembly uses 32-bit words and four bytes per beat. The parameter declarations allow other widths, but the datapath behavior is fixed around 32 bits. | Width overrides can truncate, extend, mis-index strobes or fail elaboration; integrators may assume a supported width that has not been implemented. | Constrain parameters to 32-bit data with elaboration assertions/documentation, or generalize all datapaths and byte-lane logic. Address-width slices also need legal-width constraints. |
| RSK-08 — Medium; confirmed parameter hazard | **FIFO pointer wrap assumes power-of-two depth.** The FIFO pointer increments modulo `2**$clog2(DEPTH)` and has no explicit wrap at `DEPTH-1`. | A non-power-of-two `FIFO_DEPTH` can address outside the declared memory range. | Assert `DEPTH` is a power of two and at least the supported minimum, or add explicit pointer wrap. |
| RSK-09 — Medium; priority ambiguity | **W1C can clear an event arriving in the same cycle.** Hardware sets `IRQ_STAT` bits and the later software-write case assigns the whole register from the old value masked by WDATA. | A same-cycle new event and W1C may lose the event instead of retaining it. | Define set-versus-clear priority. For sticky event capture, normally compute the next state explicitly so a simultaneous new event is preserved, then verify that rule. |
| RSK-10 — Medium; control semantics | **FIFO clear is a level (`CTRL[8]`), not a self-clearing pulse.** It is connected directly to both FIFOs' clear input and remains asserted until software writes it low. | If software leaves the bit set, every FIFO operation is continuously cleared. | Either self-clear it after one cycle or document a write-one-then-write-zero sequence and test it. |
| RSK-11 — Medium; potential lost request | **Start while busy is not queued.** `START` is edge-detected only while `!busy`; if software sets it while busy, the edge detector can consume the edge without launching a transfer. There is also no explicit pending-request arbitration between a register start and an accepted XIP request. | A software command may be acknowledged but never executed if issued during a transfer or concurrently with XIP acceptance. | Reject the write while busy, hold a pending start until accepted, or define strict software exclusion and add a collision test. |
| RSK-12 — Medium; byte-order contract | **XIP assembles first flash byte into `RDATA[31:24]`.** AXI byte lanes are address-dependent; the mapping needs to be explicit. | A little-endian CPU executing from flash may observe byte-swapped words if the system expects the lowest address in the lowest byte lane. | Define endianness and implement/verify the `ARADDR` byte-lane mapping against the selected CPU and AXI revision. |
| RSK-13 — Medium; XIP configuration constraint | **Base/mask decode and subtraction rely on a consistent window base.** Decode compares masked addresses but flash offset subtracts the full base. | A base with ignored mask bits set, or a non-contiguous mask, can accept addresses whose offset is unexpected. | Require base alignment and a contiguous region mask; validate or document legal values. |
| RSK-14 — Low/medium; verification gap | **No flash command-level model or reset-recovery regression is included.** The UVM README identifies a need for a flash model; the HTML docs also list WIP polling and reset-recovery coverage as future work. | The strongest functional claims (opcode, address, dummy cycles, data order, XIP burst) are not established by the provided tests. | Add a behavioral flash model, directed tests for each supported command/mode, error/backpressure tests, and coverage before tapeout review. |

### Other implementation observations

- `r_beat_idx`, `r_aw_err`, and `r_rd_err` appear unused beyond bookkeeping; remove them or use them to clarify control intent.
- Reading an empty RX FIFO returns zero with an OKAY register response and does not pop. This may be acceptable if software polls `STATUS`, but the underflow contract is not explicit.
- The shared-core priority is XIP when `w_mem_start` is asserted; an overlap with the register start pulse needs a directed test because the register block may clear its start bit independently.
- The external `io_oe` polarity and mapping to pad-cell `OE`/`IE` are not described in the RTL interface documentation. Confirm pad behavior, reset isolation and DFT interaction at SoC integration.

## 6. Strengths and weaknesses

### Strengths

- Clear top-level partition between AXI register access, XIP sequencing and serial bit engine.
- XIP R-channel backpressure is propagated to the serial receiver rather than blindly consuming bytes.
- Independent AW and W capture and byte-strobe handling are considered in the register interface and have a directed UVM skew test.
- No FPGA vendor primitive was found in the reviewed RTL files; the core appears to use ordinary synthesizable SystemVerilog constructs.
- MIT license is comparatively straightforward for product integration, subject to the project's full license terms.
- UVM and lint collateral provide a useful starting point for verification, even though they are not proof of passing results in this review.

### Weaknesses

- The public implementation is a flash master only; no slave/target endpoint exists.
- AXI control is not APB; a FU3 APB control map needs a wrapper/bridge or an RTL modification. XIP data path is read-only.
- The external serial profile is narrow: one CS, fixed clock polarity/phase behavior, three address bytes, and no automatic flash-ready polling.
- Several parameters appear wider in declaration than the implementation actually supports.
- No observed ASIC synthesis, STA, PPA, DFT review, silicon validation, or command-level flash model.

## 7. Performance assessment

### Serial clock and theoretical payload rate

The counter reloads at `CLKDIV` and toggles SCLK once per `(CLKDIV + 1)` system-clock cycles. Therefore the nominal full SCLK period is two toggles:

`f_SCLK = f_SYS / (2 × (CLKDIV + 1))`

For `L` active data lanes, the ideal raw payload rate is:

`R_raw = f_SCLK × L / 8 bytes/s`, where `L = 1, 2, or 4`.

Example only: at a 100 MHz controller clock and `CLKDIV=0`, the ideal Quad payload ceiling is 25 MB/s before command/address/mode/dummy overhead, AXI stalls, FIFO refill gaps and flash timing limits. This is a mathematical estimate from the RTL divider, **not a measured performance result**.

### Throughput and latency limits

- XIP uses one flash command/address phase for the requested AXI burst, amortizing command overhead across beats.
- Each 32-bit XIP beat requires four serial data bytes; at Quad width this is eight SCLK data cycles per beat. Command, address, mode and dummy phases add initial latency.
- Only one shared QSPI transfer is active at a time. The memory interface does not accept another AR until the active transaction and R response complete.
- `RREADY` backpressure stalls serial byte consumption. Program traffic can also stop with error when the TX FIFO becomes empty.
- There are no measured maximum clock, area, power, or post-layout timing values. Maximum usable SCLK depends on the target flash, pad delays, IO timing, library, floorplan and clock constraints.

## 8. Tapeout-readiness judgment

| Area | Assessment | Evidence/remaining work |
|---|---|---|
| RTL portability | Promising, preliminary | Standard SystemVerilog observed; run target synthesis/lint and check parameter constraints |
| Functional completeness | Limited for a general QSPI IP | Master-only, one CS, fixed SCLK mode, 24-bit addresses, command/profile gaps |
| Bus integration | Partial | Single-beat AXI register profile and fixed 32-bit XIP beats; FU3 APB integration needs a decision |
| Verification | Prototype level | Directed UVM tests exist; no command-level flash model or reported run was verified here |
| ASIC PPA/physical | Unknown | No standard-cell synthesis, STA, power, DFT, or physical implementation result in the package |
| License | Favorable | MIT license file is included |

**Recommendation:** keep this source as a candidate/reference for a master-only flash/XIP function, but do not freeze it for tapeout until RSK-01 through RSK-07 are resolved or explicitly constrained. For FU3, first decide whether this IP is expected to replace the APB-controlled QSPI controller, provide only the AXI XIP read path, or be redesigned to match both buses and the required roles.

## 9. Evidence, protocol references and review limits

- Source repository and license: [OpenCoreLabsX/axi-qspi-controller](https://github.com/OpenCoreLabsX/axi-qspi-controller), pinned to the commit above. The source reports AXI4-Full register control, AXI memory-mapped reads/XIP, three lane modes and UVM collateral.
- The skill-bundled AXI reference is **AMBA AXI Protocol Specification v1.0 (AXI3-era), Arm IHI 0022B v1.0**, not a confirmed AXI4 revision. Relevant sections read for this review: Chapter 3.1 (VALID/READY and stable information while waiting), Chapter 4.2–4.5 (burst length, size, type and addressing), Chapter 9.3–9.4 (byte lanes and byte-invariant mapping). Local file: `C:\Users\PC\.codex\skills\vlsit-asic-ip-microspec\reference\md_doc\vlsit_axi_amba_axi_ihi0022b_v1_0.md`. A production AXI4 specification must cite the exact revision adopted by the FU3 project.
- No SPI/QSPI flash datasheet was selected. Therefore the supported flash command profile, clock mode, address width, status/WIP sequence and timing limits remain open design inputs.
- This review read the six RTL source files, package/constants, Makefile, UVM README and HTML documentation. It did **not** run simulation, lint, synthesis, formal, CDC, timing, FPGA, ASIC PPA or silicon tests. Findings described as potential must be confirmed or cleared by those checks and by user-approved flash requirements.
<a id="vietnamese-version"></a>
# Bản tiếng Việt — Rà soát thiết kế RTL

[English / Tiếng Anh](#english-version) | [Tiếng Việt](#vietnamese-version)

### 1. Đánh giá tổng quan

Thiết kế kết hợp một giao diện thanh ghi AXI subordinate, đường phản hồi bộ nhớ/XIP AXI chỉ đọc, engine flash SPI/Dual/Quad dùng chung, FIFO TX/RX và một đầu ra ngắt. Cấu trúc module tương đối dễ theo dõi; gói mã có register map, một số test UVM khởi đầu, mục tiêu lint và giấy phép MIT.

Trường hợp sử dụng phù hợp nhất là SoC đọc flash nối tiếp qua cửa sổ XIP 32-bit. RTL chỉ hoạt động ở vai trò **master**, không có đầu cuối QSPI slave. Thiết kế còn giới hạn đáng kể về giao thức và profile flash: một chip-select, hành vi cực tính/pha SCLK cố định, địa chỉ flash nối tiếp 24-bit, beat XIP 32-bit và chỉ hỗ trợ một phần các giao dịch AXI. Trước khi xem đây là IP ASIC có thể tái sử dụng, cần đưa các giới hạn này thành yêu cầu tích hợp rõ ràng hoặc sửa RTL.

Các điểm cần ưu tiên cao nhất:

1. Đường đọc XIP dùng `ARLEN` nhưng không dùng `ARSIZE` hoặc `ARBURST`; mỗi beat luôn được hiểu là bốn byte.
2. Engine nối tiếp chỉ phát ba byte địa chỉ, trong khi địa chỉ AXI/XIP và base rộng 32-bit.
3. SCLK luôn idle-low và không có cấu hình CPOL/CPHA. FSM cập nhật dữ liệu đầu ra ở một cạnh SCLK và lấy mẫu đầu vào ở cạnh còn lại; cần đối chiếu mode flash và timing setup với datasheet của flash được chọn.
4. Đường đọc/ghi thanh ghi chỉ hỗ trợ giao dịch 32-bit một beat. Cần quy định rõ phần mềm phải xử lý FIFO tràn và va chạm khi khởi động lệnh như thế nào.
5. UVM hiện có không kèm mô hình flash cấp lệnh; các collateral kiểm chứng chưa chứng minh dữ liệu flash, timing QSPI, hành vi burst XIP hay PPA ASIC.

### 2. Tập mã nguồn đã rà soát

| Tệp | Nội dung đã rà soát |
|---|---|
| [`axi_qspi_wrapper.sv`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/rtl/axi_qspi_wrapper.sv) | Các cổng top-level, kết nối đường thanh ghi AXI và XIP, phân xử core dùng chung, các chân QSPI |
| [`axi_qspi_axi4_interface.sv`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/rtl/axi_qspi_axi4_interface.sv) | Truy cập thanh ghi, tạo phản hồi, FIFO, trạng thái ngắt, điều khiển khởi động |
| [`axi_qspi_mem_interface.sv`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/rtl/axi_qspi_mem_interface.sv) | Giải mã địa chỉ XIP, yêu cầu đọc flash, gom dữ liệu AXI R và xử lý backpressure |
| [`axi_qspi_core.sv`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/rtl/axi_qspi_core.sv) | FSM lệnh/địa chỉ/mode/dummy/data nối tiếp, bộ chia clock, hướng IO |
| [`axi_qspi_fifo.sv`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/rtl/axi_qspi_fifo.sv) | FIFO vòng đồng bộ và hành vi theo độ sâu tham số hóa |
| [`axi_qspi_pkg.sv`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/rtl/axi_qspi_pkg.sv) | Enum operation/mode/state, offset thanh ghi, hằng số lệnh |
| [`uvm/README.md`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/uvm/README.md), [`Makefile`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/Makefile), [`docs/index.html`](../../../../../../100_ForMe/013_Opencore/QSPI_Controller/OpenCoreLabsX-axi-qspi-controller/source_snapshot/axi-qspi-controller-35a2ae97eb1752c5fe173e9341d43f1c3b2654c6/docs/index.html) | Mục tiêu kiểm thử, build target, các giới hạn tính năng/kiểm chứng đã nêu |

Phân cấp chính là `axi_qspi_wrapper` → giao diện thanh ghi AXI + giao diện XIP + `axi_qspi_core` dùng chung; giao diện thanh ghi tạo các FIFO TX/RX. Tất cả khối dùng chung `i_qspi_aclk` và reset bất đồng bộ active-low. Chân QSPI ngoài được biểu diễn thành bốn bit input, bốn bit output và bốn bit output-enable thay vì RTL `inout`; pad wrapper phải hiện thực đúng hướng IO-cell và trạng thái reset.

### 3. Kiến trúc và hành vi chi tiết

#### 3.1 Giao diện thanh ghi AXI

AXI subordinate cung cấp vùng thanh ghi từ offset `0x00` đến `0x44`. Giao dịch đọc/ghi thanh ghi thông thường là 32-bit, một beat. AW và W được nhận độc lập; việc ghi chỉ commit khi cả hai đã có mặt. `WSTRB` cập nhật các byte tương ứng. Ghi không được hỗ trợ trả `SLVERR`; với burst write, các beat W còn lại được nhận hết trước khi trả lỗi. Đọc thanh ghi không hợp lệ cũng trả lỗi, bao gồm cả chuỗi phản hồi được tạo cho burst read được yêu cầu.

#### 3.2 Danh mục thanh ghi và giá trị reset

Danh mục dưới đây được trích từ `axi_qspi_pkg.sv` và các phép gán reset trong `axi_qspi_axi4_interface.sv`. Đây chưa phải workbook CSR của VLSIT.

| Offset | Thanh ghi | Chức năng quan sát được | Giá trị reset RTL |
|---:|---|---|---:|
| `0x00` | `CTRL` | Khởi động, chọn operation, xóa FIFO | `0x00000000` |
| `0x04` | `STATUS` | Busy/done/error, TX empty, RX valid, XIP active | tổ hợp chỉ đọc |
| `0x08` | `CLKDIV` | Bộ chia clock nối tiếp | `3` |
| `0x0C` | `MODE` | Chọn lane SPI / Dual / Quad | `0` (SPI) |
| `0x10` | `CMD` | Byte lệnh thủ công | `0x0B` |
| `0x14` | `FLASH_ADDR` | Địa chỉ lệnh thủ công | `0` |
| `0x18` | `LEN` | Độ dài dữ liệu thủ công | `0` |
| `0x1C` | `DUMMY` | Số chu kỳ dummy | `8` |
| `0x20` | `TXDATA` | Cổng ghi FIFO TX | FIFO rỗng |
| `0x24` | `RXDATA` | Cổng đọc FIFO RX | FIFO rỗng |
| `0x28` | `IRQ_EN` | Cho phép nguồn ngắt done/error | `0` |
| `0x2C` | `IRQ_STAT` | Trạng thái sticky done/error; ghi 1 để xóa | `0` |
| `0x30` | `VERSION` | Hằng số phiên bản `0x0001_0000` | `0x00010000` |
| `0x34` | `XIP_CTRL` | Bật XIP | `0` |
| `0x38` | `XIP_BASE` | Base cửa sổ địa chỉ host | `0` |
| `0x3C` | `XIP_MASK` | Mask giải mã địa chỉ XIP | `0xFF000000` |
| `0x40` | `XIP_CMD` | Lệnh đọc XIP ghi đè | `0x0B` |
| `0x44` | `XIP_MODE` | Bật continuous-read và byte mode | `0x000001A0` |

Cần xác thực thêm định nghĩa bit chính xác, quyền truy cập và trình tự phần mềm từ toàn bộ RTL cùng hợp đồng phần mềm dự kiến trước khi đưa các thông tin này vào CSR workbook/specification.

#### 3.3 Giao diện bộ nhớ XIP

Khối XIP giải mã địa chỉ đọc host theo biểu thức `(ARADDR & XIP_MASK) == (XIP_BASE & XIP_MASK)`. Khi khớp, khối yêu cầu một lần đọc QSPI với độ dài `(ARLEN + 1) × 4` byte. Engine gom bốn byte nối tiếp cho mỗi beat AXI R và đặt `RLAST` ở beat cuối. Nếu `RREADY` thấp, khối ngừng lấy thêm byte QSPI RX cho đến khi beat AXI đang giữ được chấp nhận. Địa chỉ ngoài cửa sổ XIP trả về phản hồi lỗi.

Mask mặc định `0xFF000000` mô tả cửa sổ host 16 MB khi base được căn theo mask này. Tuy vậy, lệnh nối tiếp chỉ phát ba byte địa chỉ, nên offset phía flash bị giới hạn ở 24-bit trong wrapper hiện tại.

#### 3.4 Engine nối tiếp và luồng dữ liệu FIFO

Core hỗ trợ chọn lane `SPI`, `DUAL` và `QUAD`; lệnh được phát trên một lane, sau đó địa chỉ được phát trên một lane, ngoại trừ đường XIP Quad-I/O. XIP Quad-I/O có thể phát thêm byte mode và các chu kỳ dummy. Byte đọc đi vào FIFO RX/bộ gom XIP; byte ghi chương trình được lấy từ FIFO TX. Thiết kế có một chip-select QSPI.

Enum operation chọn read, program hoặc erase. Hằng số lệnh gồm fast-read (`0x0B`), Dual read (`0x3B`), Quad Output read (`0x6B`), Quad I/O read (`0xEB`), write-enable, status/config/ID, page-program và erase. Có hằng số lệnh không đồng nghĩa mọi lệnh đều chạy đúng: wrapper luôn đặt địa chỉ dài ba byte cho giao dịch thủ công và tắt byte mode/hành vi địa chỉ quad trong đường đó.

Độ sâu FIFO mặc định là 16 byte. FIFO dùng độ rộng con trỏ `$clog2(DEPTH)` và tự wrap đúng khi depth là lũy thừa của hai; nếu override sang depth không phải lũy thừa hai thì cần giới hạn rõ hoặc bổ sung logic wrap.

### 4. Danh sách tính năng

#### Đã có trong RTL được rà soát

- Bộ điều khiển flash SystemVerilog dạng module, dùng chung một QSPI engine.
- Đường truy cập thanh ghi AXI với AW/W nhận độc lập, byte strobe và phản hồi lỗi cho giao dịch thanh ghi không hỗ trợ.
- Đường XIP AXI chỉ đọc, giải mã base/mask, phản hồi nhiều beat 32-bit và xử lý backpressure của kênh R.
- Đường dữ liệu master SPI, Dual SPI và Quad SPI; bốn bit IO input/output/output-enable.
- Cấu hình lệnh, địa chỉ, độ dài dữ liệu, chu kỳ dummy và bộ chia clock.
- Các giá trị operation read/program/erase và một tập hằng số lệnh flash phổ biến.
- FIFO TX/RX, nguồn ngắt sticky done/error, IRQ enable và thanh ghi version.
- Giá trị reset và reset bất đồng bộ active-low trong implementation hiện tại.
- Mã nguồn test UVM cho reset/đọc/ghi thanh ghi, cấu hình thanh ghi XIP, smoke test FIFO/IRQ và AW/W đến lệch thời điểm.
- Mục tiêu lint Verilator và giấy phép MIT.

#### Chưa có hoặc chưa được chứng minh trong gói mã đã rà soát

- Chế độ SPI slave/target.
- Nhiều hơn một chân chip-select flash.
- Cấu hình CPOL/CPHA; RTL để serial clock idle-low.
- Địa chỉ flash bốn byte hoặc cấu hình số byte địa chỉ tại wrapper.
- Cấu hình pha địa chỉ hoặc pha mode-byte cho truyền thủ công.
- Tự polling write-in-progress, timeout hoàn tất, bộ lập lịch lệnh hoặc phục hồi reset flash.
- Mô hình hành vi flash QSPI trong môi trường UVM; README UVM nói cần bổ sung mô hình flash cấp lệnh.
- Bằng chứng chạy trên board FPGA, tổng hợp/PPA ASIC, silicon/tapeout hoặc kết quả tích hợp bên ngoài.
### 5. Lỗi tiềm ẩn và rủi ro thiết kế

Mức độ nghiêm trọng được đánh giá theo tác động nếu dùng IP như một bộ điều khiển AXI/QSPI đa dụng. “Đã xác nhận trong RTL” nghĩa là hành vi được mô tả thể hiện trong mã; không có nghĩa testbench đã chứng minh lỗi trên phần cứng.

| ID / mức độ | Phát hiện và bằng chứng | Ảnh hưởng | Khuyến nghị xử lý |
|---|---|---|---|
| RSK-01 — Cao; hành vi đã xác nhận | **XIP không kiểm tra loại/kích thước giao dịch AXI.** `axi_qspi_mem_interface.sv` nhận `ARLEN`, `ARSIZE`, `ARBURST`, nhưng luôn tính bốn byte mỗi beat và chỉ dùng `ARLEN` để xác định giao dịch. Không từ chối giao dịch hẹp, fixed hoặc wrapping. | Giao dịch byte/halfword có thể trả về cả word bốn byte; burst fixed/wrapping bị xử lý như các byte flash tuần tự. Phần mềm có thể nhận dữ liệu sai hoặc địa chỉ bị lặp/bỏ qua. | Chỉ chấp nhận profile aligned 32-bit INCR và trả lỗi xác định cho profile khác, hoặc triển khai đúng byte-lane và semantics burst của AXI. Thêm kiểm tra biên 4 KiB nếu revision AXI đã chọn yêu cầu. |
| RSK-02 — Cao; giới hạn đã xác nhận | **Địa chỉ flash chỉ rộng 24-bit.** `axi_qspi_wrapper.sv` cố định số byte địa chỉ ở ba; `load_addr_byte()` phát `[23:16]`, `[15:8]`, `[7:0]`, không phát `[31:24]`. | Offset XIP lớn hơn `0x00FF_FFFF` bị cắt cụt hoặc alias. Cửa sổ mặc định 16 MB vừa giới hạn này, nhưng cửa sổ lớn hơn hoặc flash dùng địa chỉ 32-bit thì không. | Giới hạn và kiểm tra cửa sổ flash ở 16 MB, hoặc bổ sung địa chỉ ba/bốn byte có cấu hình và test tại biên. |
| RSK-03 — Cao; cần xác nhận profile/timing | **Mode SCLK cố định.** RTL reset/idle SCLK ở mức thấp và không có cấu hình CPOL/CPHA. FSM cập nhật dữ liệu đầu ra ở một cạnh SCLK và lấy mẫu đầu vào ở cạnh đối diện; cần đối chiếu mode flash dự kiến và timing setup bit đầu tiên với datasheet flash được chọn. | Flash yêu cầu mode khác hoặc có cách hiểu timing khác có thể trả dữ liệu sai hoặc không nhận lệnh. | Nêu rõ mode được hỗ trợ và chứng minh timing CS/SCLK/DQ bằng mô hình flash và waveform. Chỉ bổ sung CPOL/CPHA nếu flash mục tiêu yêu cầu. |
| RSK-04 — Cao; hành vi đã xác nhận | **Đường lệnh thủ công luôn có địa chỉ ba byte.** Wrapper cố định `addr_bytes=3`; đường thủ công tắt pha address-mode và mode-byte. | Không thể biểu diễn đúng pha lệnh thông thường của lệnh không có địa chỉ (ví dụ đọc status/ID/write-enable). Pha địa chỉ/mode thủ công QPI/Quad-I/O cũng không có. | Bổ sung số byte địa chỉ và điều khiển từng pha, hoặc giới hạn tập lệnh phần mềm ở các giao dịch RTL thực sự hỗ trợ. |
| RSK-05 — Cao; hành vi đã xác nhận | **FIFO TX hết dữ liệu làm hủy ngay.** Trong trạng thái program, nếu core yêu cầu byte nhưng `TX_VALID` thấp, core đặt error rồi chuyển sang STOP thay vì chờ. | Phần mềm nạp bù chậm có thể làm dừng sớm một thao tác program dài, nhất là dữ liệu lớn hơn FIFO mặc định 16 byte. | Quy định cách nạp trước/streaming và timeout; tốt hơn là dừng SCLK/CS khi chờ dữ liệu TX, hoặc cung cấp phản hồi underflow rõ để phần mềm phục hồi. |
| RSK-06 — Cao; hành vi đã xác nhận | **Ghi TX khi FIFO đầy vẫn có thể được ACK nhưng không lưu byte.** AXI write có thể trả OKAY dựa trên địa chỉ/kích thước; FIFO write enable bị chặn riêng khi FIFO đầy. FIFO đầy đặt lỗi sticky tổng quát nhưng STATUS không có bit `TX_FULL`. | Byte ghi vào FIFO có thể bị mất mà giao dịch bus vẫn có vẻ thành công; phần mềm chỉ biết qua IRQ/status lỗi dùng chung. | Chặn giao dịch thanh ghi khi FIFO không còn chỗ và trả lỗi/backpressure, hoặc công khai trạng thái full và quy định trình tự phần mềm. Tách nguồn overrun nếu cần chẩn đoán. |
| RSK-07 — Cao; giới hạn độ rộng | **Tham số độ rộng bus không thực sự tổng quát.** Logic thanh ghi dùng dữ liệu `[31:0]` và bốn WSTRB; bộ gom XIP dùng word 32-bit và bốn byte/beat. Khai báo tham số cho phép độ rộng khác nhưng datapath cố định theo 32-bit. | Override độ rộng có thể cắt/nối sai, đánh chỉ số strobe sai hoặc lỗi elaboration; tích hợp có thể giả định hỗ trợ độ rộng chưa được làm. | Ràng buộc tham số dữ liệu ở 32-bit bằng assertion/tài liệu hoặc tổng quát hóa toàn datapath và byte lane. Cũng cần giới hạn hợp lệ cho các slice độ rộng địa chỉ. |
| RSK-08 — Trung bình; nguy cơ tham số đã xác nhận | **Wrap con trỏ FIFO giả định depth là lũy thừa của hai.** Con trỏ tăng theo modulo `2**$clog2(DEPTH)` và không wrap rõ tại `DEPTH-1`. | Override `FIFO_DEPTH` không phải lũy thừa hai có thể trỏ ra ngoài vùng nhớ đã khai báo. | Assertion depth là lũy thừa hai và không thấp hơn mức hỗ trợ, hoặc thêm logic wrap tường minh. |
| RSK-09 — Trung bình; ưu tiên xử lý chưa rõ | **W1C có thể xóa event đến đúng chu kỳ ghi clear.** Phần cứng set bit `IRQ_STAT`, sau đó nhánh ghi phần mềm gán cả thanh ghi từ giá trị cũ được mask bởi WDATA. | Event mới có thể bị mất nếu đồng thời ghi W1C. | Quy định ưu tiên set/clear. Với sticky event, thường tính next-state rõ ràng để giữ event mới nếu cùng chu kỳ, sau đó xác minh hành vi. |
| RSK-10 — Trung bình; semantics điều khiển | **Xóa FIFO là mức (`CTRL[8]`), không tự clear thành pulse.** Bit này nối thẳng đến cả hai FIFO và giữ trạng thái cho đến khi phần mềm ghi về 0. | Nếu phần mềm để bit ở 1, FIFO tiếp tục bị xóa trong mọi chu kỳ và không thể vận hành bình thường. | Tự clear sau một chu kỳ hoặc tài liệu hóa trình tự ghi 1 rồi ghi 0 và kiểm thử. |
| RSK-11 — Trung bình; có thể mất yêu cầu | **START khi busy không được xếp hàng.** START chỉ phát hiện cạnh khi `!busy`; nếu phần mềm set khi đang busy, bộ phát hiện cạnh có thể tiêu thụ cạnh mà không khởi chạy. Phân xử yêu cầu chờ giữa register-start và XIP được nhận cũng chưa tường minh. | Lệnh phần mềm có thể được ACK nhưng không chạy nếu gửi trong khi transfer khác đang chạy hoặc cùng lúc nhận XIP. | Từ chối write khi busy, giữ yêu cầu pending đến lúc nhận, hoặc quy định phần mềm tuyệt đối không tạo xung đột và bổ sung collision test. |
| RSK-12 — Trung bình; quy ước thứ tự byte | **Byte flash đầu tiên của XIP được ghép vào `RDATA[31:24]`.** Byte lane AXI phụ thuộc địa chỉ nên cần định nghĩa cách ánh xạ. | CPU little-endian chạy trực tiếp từ flash có thể đọc word bị đảo byte nếu hệ thống mong địa chỉ thấp nhất nằm ở lane thấp nhất. | Định nghĩa endianness và triển khai/xác minh ánh xạ byte lane theo `ARADDR`, CPU mục tiêu và revision AXI đã chọn. |
| RSK-13 — Trung bình; ràng buộc cấu hình XIP | **Giải mã base/mask và phép trừ offset cần base cửa sổ nhất quán.** So sánh địa chỉ dùng mask, nhưng offset flash trừ toàn bộ base. | Base có bit bị mask bỏ nhưng đặt khác 0, hoặc mask không liên tục, có thể nhận địa chỉ nhưng tạo offset không như mong muốn. | Yêu cầu base căn chỉnh và mask mô tả vùng liên tục; kiểm tra hoặc tài liệu hóa các giá trị hợp lệ. |
| RSK-14 — Thấp/trung bình; thiếu kiểm chứng | **Không có mô hình flash cấp lệnh hoặc hồi quy phục hồi reset.** README UVM nêu cần mô hình flash; tài liệu HTML cũng ghi polling WIP và phục hồi reset là việc tương lai. | Các chức năng chính như opcode, địa chỉ, dummy cycle, thứ tự dữ liệu và burst XIP chưa được collateral hiện có chứng minh. | Bổ sung mô hình flash hành vi, test từng lệnh/mode được hỗ trợ, test lỗi/backpressure và coverage trước khi review tapeout. |

#### Các quan sát triển khai khác

- `r_beat_idx`, `r_aw_err` và `r_rd_err` có vẻ không được dùng ngoài bookkeeping; nên xóa hoặc dùng chúng để làm rõ ý đồ điều khiển.
- Đọc FIFO RX đang rỗng trả zero với phản hồi thanh ghi OKAY và không pop. Cách này có thể chấp nhận nếu phần mềm poll `STATUS`, nhưng hợp đồng underflow chưa rõ.
- Ưu tiên core dùng chung thuộc XIP khi `w_mem_start` được assert; cần test trực tiếp trường hợp trùng xung register-start vì khối thanh ghi có thể tự clear bit start.
- Tài liệu giao diện RTL không mô tả cực tính `io_oe` và cách ánh xạ với `OE`/`IE` của pad-cell. Cần xác nhận hành vi pad, cách cô lập khi reset và tương tác DFT ở mức SoC.

### 6. Ưu điểm và nhược điểm

#### Ưu điểm

- Phân chia top-level rõ giữa truy cập thanh ghi AXI, điều khiển XIP và engine bit nối tiếp.
- Backpressure kênh R của XIP được truyền ngược về bộ nhận nối tiếp thay vì tiếp tục tiêu thụ byte một cách mù quáng.
- Giao diện thanh ghi xét đến việc nhận AW và W độc lập cùng byte strobe; có UVM test riêng cho AW/W đến lệch thời điểm.
- Không thấy primitive riêng của hãng FPGA trong các RTL đã rà soát; core có vẻ dùng cấu trúc SystemVerilog tổng hợp được thông thường.
- Giấy phép MIT tương đối dễ tích hợp sản phẩm, tùy điều kiện đầy đủ của dự án.
- UVM và lint collateral hữu ích làm điểm khởi đầu kiểm chứng, dù review này không xác nhận chúng đã chạy pass.

#### Nhược điểm

- Implementation công khai chỉ là flash master; không có đầu cuối slave/target.
- Điều khiển dùng AXI chứ không phải APB; FU3 cần wrapper/bridge hoặc sửa RTL để có bản đồ điều khiển APB. Đường dữ liệu XIP chỉ đọc.
- Profile nối tiếp hẹp: một CS, mode cực tính/pha clock cố định, địa chỉ ba byte và không tự polling flash-ready.
- Một số tham số khai báo rộng hơn mức implementation thực sự hỗ trợ.
- Chưa thấy tổng hợp ASIC, STA, PPA, review DFT, xác nhận silicon hay mô hình flash cấp lệnh.

### 7. Đánh giá hiệu năng

#### Clock nối tiếp và thông lượng dữ liệu lý thuyết

Bộ đếm reload theo `CLKDIV` và đảo SCLK một lần sau mỗi `(CLKDIV + 1)` chu kỳ clock hệ thống. Do đó, một chu kỳ SCLK đầy đủ gồm hai lần đảo mức:

`f_SCLK = f_SYS / (2 × (CLKDIV + 1))`

Với `L` lane dữ liệu hoạt động, tốc độ payload thô lý tưởng là:

`R_raw = f_SCLK × L / 8 byte/s`, trong đó `L = 1, 2 hoặc 4`.

Ví dụ minh họa: clock controller 100 MHz và `CLKDIV=0` cho trần lý tưởng Quad là 25 MB/s, chưa tính overhead command/address/mode/dummy, AXI stall, khoảng trống nạp FIFO và giới hạn timing flash. Đây chỉ là ước tính toán học từ bộ chia RTL, **không phải kết quả đo hiệu năng**.

#### Giới hạn throughput và latency

- XIP dùng chung một pha command/address cho burst AXI được yêu cầu, giúp phân bổ overhead command trên nhiều beat.
- Mỗi beat XIP 32-bit cần bốn byte nối tiếp; Quad cần tám chu kỳ SCLK dữ liệu/beat. Pha command, address, mode và dummy làm tăng latency ban đầu.
- Mỗi lần chỉ có một transfer QSPI dùng engine chung. Memory interface không nhận AR mới cho đến khi giao dịch đang chạy và phản hồi R hoàn tất.
- Backpressure `RREADY` làm dừng tiêu thụ byte nối tiếp. Luồng program cũng có thể dừng kèm lỗi khi FIFO TX hết dữ liệu.
- Chưa có số đo clock tối đa, diện tích, công suất hay timing sau layout. SCLK hữu dụng tối đa phụ thuộc flash mục tiêu, trễ pad, timing IO, thư viện, floorplan và ràng buộc clock.

### 8. Đánh giá mức sẵn sàng tapeout

| Hạng mục | Đánh giá | Bằng chứng / việc còn lại |
|---|---|---|
| Khả năng chuyển cổng RTL | Có triển vọng, mức sơ bộ | Quan sát thấy SystemVerilog chuẩn; cần tổng hợp/lint theo công nghệ đích và kiểm tra ràng buộc tham số |
| Độ đầy đủ chức năng | Hạn chế nếu xem là IP QSPI đa dụng | Chỉ master, một CS, mode SCLK cố định, địa chỉ 24-bit, còn thiếu profile/lệnh |
| Tích hợp bus | Một phần | Thanh ghi AXI chỉ một beat và XIP cố định beat 32-bit; cần quyết định cách tích hợp APB của FU3 |
| Kiểm chứng | Mức prototype | Có một số UVM test; chưa có mô hình flash cấp lệnh và review này không xác minh kết quả chạy |
| PPA/vật lý ASIC | Chưa biết | Gói mã không có kết quả tổng hợp standard-cell, STA, công suất, DFT hoặc physical implementation |
| Giấy phép | Thuận lợi | Có kèm tệp giấy phép MIT |

**Khuyến nghị:** giữ source này làm ứng viên/tham chiếu cho chức năng flash-master/XIP chỉ master, nhưng chưa chốt tapeout cho đến khi giải quyết hoặc giới hạn rõ RSK-01 đến RSK-07. Với FU3, trước tiên cần quyết định IP này sẽ thay bộ điều khiển QSPI điều khiển qua APB, chỉ cung cấp đường đọc XIP AXI, hay được thiết kế lại để đáp ứng cả hai bus và các vai trò cần thiết.

### 9. Bằng chứng, tham chiếu giao thức và giới hạn review

- Repository và giấy phép: [OpenCoreLabsX/axi-qspi-controller](https://github.com/OpenCoreLabsX/axi-qspi-controller), ghim tại commit nêu ở đầu báo cáo. Source công bố AXI4-Full để điều khiển thanh ghi, AXI memory-mapped read/XIP, ba chế độ lane và collateral UVM.
- Tài liệu AXI đi kèm skill là **AMBA AXI Protocol Specification v1.0 (thời AXI3), Arm IHI 0022B v1.0**, không phải revision AXI4 đã được xác nhận. Các mục đã đọc: Chương 3.1 (VALID/READY và giữ ổn định thông tin khi chờ), 4.2–4.5 (độ dài/kích thước/loại burst và addressing), 9.3–9.4 (byte lane và ánh xạ byte bất biến). Tệp cục bộ: `C:\Users\PC\.codex\skills\vlsit-asic-ip-microspec\reference\md_doc\vlsit_axi_amba_axi_ihi0022b_v1_0.md`. Tài liệu AXI4 dùng cho sản phẩm phải trích đúng revision mà dự án FU3 lựa chọn.
- Chưa chọn datasheet flash SPI/QSPI. Vì vậy profile lệnh flash hỗ trợ, clock mode, độ rộng địa chỉ, trình tự status/WIP và giới hạn timing vẫn là đầu vào thiết kế còn mở.
- Review đã đọc sáu tệp RTL, package/constants, Makefile, UVM README và tài liệu HTML. Review **không** chạy simulation, lint, synthesis, formal, CDC, timing, FPGA, PPA ASIC hay kiểm thử silicon. Các rủi ro tiềm ẩn cần được xác nhận hoặc loại trừ bằng các bước đó và bằng yêu cầu flash được phê duyệt.