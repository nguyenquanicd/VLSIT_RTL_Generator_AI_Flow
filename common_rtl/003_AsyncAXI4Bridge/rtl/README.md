# Asynchronous AXI Bridge RTL

## English

This folder contains 18 SystemVerilog modules generated from the resolved specification. Each profile has one structural top, five channel wrappers, and its own synthesis filelist.

| Profile | Top module | Interface | Files and lint log |
|---|---|---|---|
| AXI4 base | `m_vlsit_axi_async_top` | QOS and REGION; no USER or WID | [filelist](axi4_base/filelist.f), [default lint](axi4_base/lint_verilator.log), [variant lint](axi4_base/lint_variants.log) |
| AXI4 USER | `m_vlsit_axi_user_async_top` | QOS, REGION, and five USER ports; each USER width defaults to 1 | [filelist](axi4_user/filelist.f), [default lint](axi4_user/lint_verilator.log), [variant lint](axi4_user/lint_variants.log) |
| AXI3 | `m_vlsit_axi3_async_top` | WID; no QOS, REGION, or USER | [filelist](axi3/filelist.f), [default lint](axi3/lint_verilator.log), [variant lint](axi3/lint_variants.log) |

Use the filelist in the selected profile folder. The lists include the FIFO and common-cell dependencies and define `VLSIT_SYNTHESIS`. Example, from `axi4_base`:

```powershell
python "C:\Users\PC\.codex\skills\vlsit-rtl-generator\scripts\vlsit_lint_rtl.py" lint filelist.f --top m_vlsit_axi_async_top --tool verilator
```

Verilator lint completed on all three default tops with 0 errors. Representative legal parameter variants also linted with 0 errors: maximum AXI4 widths plus SRAM/cell options, custom widths for all five USER fields, and minimum AXI3 widths/depth. Each run reports 25 `PINCONNECTEMPTY` warnings because the specification leaves unused FIFO status outputs unconnected. The RTL rule checker currently flags untyped inputs as `FIL-05/TYP-02`; these declarations follow the designer-confirmed rule. Details and manual audit results are in [generation_report.md](generation_notes/generation_report.md). The raw checker output is in [rtl_rule_report.md](generation_notes/rtl_rule_report.md).

The resolved input is [AsyncAXI4Bridge_Resolved_Design_Specification.md](generation_notes/AsyncAXI4Bridge_Resolved_Design_Specification.md). Shared dependencies are the [asynchronous FIFO](../../001_AsyncGrayFIFO/rtl) and [common cells](../../000_Common/rtl_cells). No simulation or testbench is included.

## Tiếng Việt

Thư mục này có 18 module SystemVerilog sinh từ bản đặc tả đã giải quyết. Mỗi profile gồm một top cấu trúc, năm module channel và một filelist tổng hợp riêng.

| Profile | Top module | Giao tiếp | Filelist và log lint |
|---|---|---|---|
| AXI4 base | `m_vlsit_axi_async_top` | Có QOS, REGION; không có USER hoặc WID | [filelist](axi4_base/filelist.f), [lint mặc định](axi4_base/lint_verilator.log), [lint cấu hình](axi4_base/lint_variants.log) |
| AXI4 USER | `m_vlsit_axi_user_async_top` | Có QOS, REGION và đủ năm USER; độ rộng mặc định mỗi USER là 1 | [filelist](axi4_user/filelist.f), [lint mặc định](axi4_user/lint_verilator.log), [lint cấu hình](axi4_user/lint_variants.log) |
| AXI3 | `m_vlsit_axi3_async_top` | Có WID; không có QOS, REGION hoặc USER | [filelist](axi3/filelist.f), [lint mặc định](axi3/lint_verilator.log), [lint cấu hình](axi3/lint_variants.log) |

Chọn filelist trong thư mục profile tương ứng. Filelist bao gồm FIFO, common-cell dependencies và define `VLSIT_SYNTHESIS`. Có thể chạy Verilator từ thư mục profile theo lệnh ví dụ phía trên.

Lint Verilator đã chạy trên ba top với tham số mặc định: 0 lỗi. Các cấu hình hợp lệ đại diện cũng lint không lỗi: AXI4 với độ rộng lớn nhất và tùy chọn SRAM/cell; AXI4 USER với năm độ rộng USER tùy chỉnh; AXI3 với độ rộng và độ sâu FIFO nhỏ nhất. Mỗi profile có 25 cảnh báo `PINCONNECTEMPTY` vì đặc tả yêu cầu để hở các ngõ trạng thái FIFO không dùng. RTL rule checker hiện báo `FIL-05/TYP-02` với input không ghi kiểu; RTL tuân theo rule đã được xác nhận. Xem [generation_report.md](generation_notes/generation_report.md) để biết chi tiết và kết quả rà soát thủ công. [rtl_rule_report.md](generation_notes/rtl_rule_report.md) lưu kết quả checker nguyên bản.

Bản đầu vào đã giải quyết là [AsyncAXI4Bridge_Resolved_Design_Specification.md](generation_notes/AsyncAXI4Bridge_Resolved_Design_Specification.md). Dependencies dùng chung là [asynchronous FIFO](../../001_AsyncGrayFIFO/rtl) và [common cells](../../000_Common/rtl_cells). Không tạo mô phỏng hoặc testbench.
