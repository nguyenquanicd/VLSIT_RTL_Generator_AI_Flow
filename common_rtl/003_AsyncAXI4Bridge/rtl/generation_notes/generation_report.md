# RTL Generation and Check Report / Báo cáo sinh RTL và kiểm tra

## English

### Delivered

- 18 modules: six each in `axi4_base/`, `axi4_user/`, and `axi3/`.
- Each profile has `filelist.f`, with the reachable FIFO/common-cell dependencies in compile order and `+define+VLSIT_SYNTHESIS`.
- Each top contains only channel instances. Each channel module packs/unpacks one channel and instantiates one `m_vlsit_afifo_top`.
- The resolved specification records the approved fixed port lists, parameters, channel packing, reset/threshold wiring, module names, and instance naming.
- No testbench or simulation was requested or run.

### Validation

| Check | Result |
|---|---|
| Resolved-spec gap scan | 0 BLOCK, 0 INFO |
| Static profile/data-map audit | PASS; 18 modules, 0 findings |
| Verilator lint, AXI4 base | PASS; 0 errors, 25 warnings |
| Verilator lint, AXI4 USER | PASS; 0 errors, 25 warnings |
| Verilator lint, AXI3 | PASS; 0 errors, 25 warnings |
| Verilator lint, legal parameter variants | PASS; 0 errors, 25 warnings for each profile |

All Verilator warnings are `PINCONNECTEMPTY`: five unused FIFO status outputs are open on each of five channel instances, as required by the specification. Default lint used the default parameters and synthesis branch. Variant lint exercised wide AXI4 with the SRAM branch and cell type 4, customized five USER widths with cell type 3, and minimum AXI3 widths/depths with cell type 1; all used the synthesis branch.

The installed `vlsit_rtl_check.py` is not synchronized with the confirmed input-port rule. Its run reports 328 errors: 18 `FIL-05` and 310 `TYP-02`, because it requires `input wire` while the designer-confirmed rule requires `input` without an explicit data type. Verilator accepts and compiles these ports. The checker also reports 15 `HIE-02` warnings for channel wrappers that intentionally combine pack/unpack assignments with one FIFO instance; the three top modules contain instances only. The raw checker output is preserved in [rtl_rule_report.md](rtl_rule_report.md). No skill or checker files were changed.

The static audit checked module/file-name matching, prohibited constructs, untyped input ports, logic outputs, top-module structure, one FIFO per channel, and expected LSB-first pack/unpack mappings. It does not replace behavioral simulation.

## Tiếng Việt

### Nội dung bàn giao

- Có 18 module: mỗi thư mục `axi4_base/`, `axi4_user/` và `axi3/` chứa sáu module.
- Mỗi profile có `filelist.f`, liệt kê FIFO và common-cell dependencies theo thứ tự compile, cùng `+define+VLSIT_SYNTHESIS`.
- Mỗi top chỉ chứa instance của các channel. Mỗi channel đóng/gỡ gói dữ liệu và instance đúng một `m_vlsit_afifo_top`.
- Bản đặc tả đã giải quyết ghi lại port list, parameter, cách pack dữ liệu, reset/threshold, tên module và tên instance đã được duyệt.
- Không yêu cầu và không chạy testbench hay mô phỏng.

### Kết quả kiểm tra

Các profile đều lint Verilator thành công với tham số mặc định: 0 lỗi, 25 cảnh báo. Lint cấu hình mở rộng cũng thành công với AXI4 độ rộng lớn và SRAM/cell type 4; năm USER width tùy chỉnh/cell type 3; AXI3 độ rộng và FIFO tối thiểu/cell type 1. Toàn bộ cảnh báo là `PINCONNECTEMPTY`: năm ngõ trạng thái FIFO không dùng được để hở trên mỗi channel, đúng theo đặc tả. Lint dùng nhánh synthesis.

`vlsit_rtl_check.py` đang không khớp rule input đã xác nhận. Checker báo 328 lỗi gồm 18 `FIL-05` và 310 `TYP-02`, do checker bắt buộc `input wire`, còn rule được duyệt yêu cầu chỉ viết `input`, không ghi kiểu dữ liệu. Verilator chấp nhận và compile các cổng này. Checker còn 15 cảnh báo `HIE-02` cho module channel có logic pack/unpack và một FIFO; ba top chỉ chứa instance. Kết quả checker nguyên bản nằm trong [rtl_rule_report.md](rtl_rule_report.md). Không sửa skill hoặc checker.

Rà soát tĩnh đã kiểm tra tên module/file, cấu trúc top, các cấu trúc bị cấm, cổng input/output, số FIFO mỗi channel và thứ tự pack/unpack LSB-first. Rà soát này không thay thế mô phỏng hành vi.
