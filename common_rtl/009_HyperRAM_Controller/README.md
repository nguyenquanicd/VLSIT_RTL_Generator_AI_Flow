# HyperRAM Controller

## Scope

This folder contains the design specification and research for one structural AXI4-to-HyperRAM controller top. The top has six RTL child modules: APB4 interface, APB CDC, CSR register file, AXI4 frontend, HyperBus controller, and HyperBus PHY.

- One clock `CLK-CORE`, at twice the CK frequency (400 MHz for a 200 MHz CK), drives AXI4, the control logic and the PHY; CK is derived from it without a PLL, and a SoC delay line positions the read capture. APB4 uses a separate asynchronous `CLK-APB` domain.
- DQ/RWDS cross the RTL top as separate input, output, and active-high output-enable ports; the SoC pad wrapper connects physical bidirectional pads.
- Reset values are safe for all five target OPNs, so software only sets enable for a 200 MHz CK. Enable runs the RESET#-low wait, the startup waits, the CR0 and CR1 writes and an ID0 read before AXI requests are accepted.
- One elaboration-time parameter selects HyperBus x8 or Extended-I/O x16. AXI data width is 32 or 64 bits. The default is CFG-X8-32.
- The approved AXI profile uses 32-bit byte addresses, 4-bit IDs, INCR/WRAP bursts, partial writes with WSTRB, and up to four outstanding reads and writes. USER, QOS, REGION, and exclusive transactions are excluded.
- APB4 resets independently when its bus and CDC endpoint are idle. A core reset resets HyperRAM and invalidates its data; `o_idle` reports a fully drained, pin-idle controller.
- Every device timing is a CSR field counted in CK periods, per chip select (one or two); a run-time device preset loads the values of each OPN. Fixed and variable latency, posted writes, request merging, and a software command port for the device registers are supported.
- Five device OPNs are approved as initial qualification targets, at up to 200 MHz. This is not a completed qualification claim.

## Files

| Path | Purpose |
|---|---|
| `HyperRAM_Controller_Design_Specification.md` | VLSIT design contract and open decisions in Section 20. |
| `HyperRAM_Controller_CSR_Specification.xlsx` | VLSIT CSR workbook. The `ASYNC_CSR` sheet contains the 34-register map with the prefix `hr_` (2026-10-29) for configuration, status, device commands, diagnostics, interrupts and one timing group per chip select; it is pending designer approval. Unmapped addresses return APB `PSLVERR` through the decode of the APB interface module. |
| `research/hyperram_protocol_and_product_research.md` | Protocol scope, target devices, and reference-source audit. |
| `research/repair_pdf_md_pages.py` | Rebuilds selected converted document pages from their PDF text layer. |
| `reference/md_doc/` | Locally converted standards and selected-device datasheets. Redistribution restrictions are recorded and enforced by `.gitignore`. |
| `figures/block_diagram/` | Editable six-module block diagram and rendered SVG/PNG. |
| `figures/waveforms/` | Sixteen WaveDrom figures (`.svg`), offline viewers (`.html`), and editable sources (`.json`); the plan was confirmed on 2026-10-28. Timing is illustrative where noted. |

## Status

The specification was rewritten on 2026-10-28 from the designer's decisions DEC-022 to DEC-033 (single 400 MHz clock, CSR timing in CK periods, run-time presets, latency modes, write response and ordering, chip selects, device command port). `vlsit_spec_tool.py check` passes. The Winbond timing values were read from the datasheet PDFs (DEC-034; the PDFs are in `reference/pdf_winbond/` and are git-ignored). Open: the performance targets (TBD-001, TBD-002), the delay-line characteristics (TBD-006), the redraw of the block diagram (OI-004), and the designer's approval of the register map.

---

# Bộ điều khiển HyperRAM

## Phạm vi

Thư mục này chứa đặc tả thiết kế và tài liệu nghiên cứu cho một module top cấu trúc, chuyển tiếp AXI4 tới HyperRAM. Top có sáu module RTL con: giao diện APB4, CDC APB, bộ thanh ghi CSR, AXI4 frontend, bộ điều khiển HyperBus và PHY HyperBus.

- Một clock `CLK-CORE` bằng hai lần tần số CK (400 MHz cho CK 200 MHz) cấp cho AXI4, phần điều khiển và PHY; CK được tạo từ nó, không cần PLL, và delay line của SoC đặt vị trí lấy mẫu dữ liệu đọc. APB4 dùng miền `CLK-APB` bất đồng bộ riêng.
- DQ/RWDS qua top RTL bằng các cổng input, output và output-enable active-high riêng; SoC pad wrapper nối tới pad vật lý hai chiều.
- Giá trị reset an toàn cho cả năm OPN mục tiêu, nên với CK 200 MHz phần mềm chỉ cần bật enable. Enable chạy thời gian RESET#-low, các startup wait, ghi CR0 và CR1 rồi đọc ID0 trước khi nhận request AXI.
- Một parameter lúc elaboration chọn HyperBus x8 hoặc Extended-I/O x16. Độ rộng data AXI là 32 hoặc 64 bit. Cấu hình mặc định là CFG-X8-32.
- Profile AXI đã duyệt dùng địa chỉ byte 32 bit, ID 4 bit, burst INCR/WRAP, ghi từng byte bằng WSTRB và tối đa bốn giao dịch đọc, bốn giao dịch ghi đang chờ. USER, QOS, REGION và exclusive không thuộc phạm vi.
- APB4 có thể reset độc lập khi bus APB và endpoint CDC idle. Reset core reset HyperRAM và làm mất hiệu lực dữ liệu; `o_idle` báo controller đã drain và các chân bộ nhớ đã idle.
- Mọi timing của thiết bị là trường CSR tính theo chu kỳ CK, riêng cho từng chip select (một hoặc hai); preset thiết bị lúc chạy nạp giá trị của từng OPN. Hỗ trợ fixed và variable latency, ghi posted, gộp request liên tiếp và cổng lệnh phần mềm tới thanh ghi của thiết bị.
- Năm mã OPN được duyệt làm mục tiêu qualification ban đầu, tối đa 200 MHz. Đây chưa phải kết quả qualification.

## Tệp

| Đường dẫn | Mục đích |
|---|---|
| `HyperRAM_Controller_Design_Specification.md` | Đặc tả thiết kế VLSIT; các quyết định còn mở nằm ở Mục 20. |
| `HyperRAM_Controller_CSR_Specification.xlsx` | Workbook CSR theo mẫu VLSIT. Sheet `ASYNC_CSR` có 34 thanh ghi (2026-10-28) cho cấu hình, trạng thái, lệnh thiết bị, chẩn đoán, interrupt và một nhóm timing cho mỗi chip select; đang chờ người thiết kế duyệt. Địa chỉ chưa ánh xạ trả APB `PSLVERR` nhờ bộ giải mã của module giao diện APB. |
| `research/hyperram_protocol_and_product_research.md` | Phạm vi protocol, linh kiện mục tiêu và kiểm tra nguồn tham chiếu. |
| `research/repair_pdf_md_pages.py` | Dựng lại một số trang tài liệu đã chuyển đổi từ text layer của PDF. |
| `reference/md_doc/` | Bản Markdown cục bộ của chuẩn và datasheet đã chọn. `.gitignore` áp dụng giới hạn tái phân phối. |
| `figures/block_diagram/` | Sơ đồ sáu module có thể sửa và bản render SVG/PNG. |
| `figures/waveforms/` | Mười sáu waveform WaveDrom, gồm ảnh (`.svg`), viewer offline (`.html`) và tệp nguồn chỉnh sửa được (`.json`); kế hoạch được xác nhận ngày 2026-10-28. Timing có tính minh họa tại các mục được ghi chú. |

## Trạng thái

Đặc tả được viết lại ngày 2026-10-28 theo các quyết định DEC-022 đến DEC-033 của người thiết kế (một clock 400 MHz, timing CSR tính theo chu kỳ CK, preset lúc chạy, các chế độ latency, response ghi và thứ tự, chip select, cổng lệnh thiết bị). `vlsit_spec_tool.py check` đạt. Các giá trị timing của Winbond được đọc từ PDF datasheet (DEC-034; PDF nằm ở `reference/pdf_winbond/` và bị git-ignore). Còn mở: mục tiêu hiệu năng (TBD-001, TBD-002), đặc tính delay line (TBD-006), vẽ lại sơ đồ khối (OI-004), và người thiết kế duyệt bản đồ thanh ghi.

