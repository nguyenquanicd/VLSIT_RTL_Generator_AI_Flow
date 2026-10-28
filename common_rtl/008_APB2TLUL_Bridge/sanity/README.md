# Sanity results of m_apb_tlul_bridge / Kết quả sanity của m_apb_tlul_bridge

**EN:** This folder holds the logs and the report of the last sanity run on `../rtl`. They are produced by the `Makefile` of the parent folder (`make all`) and released together with the RTL. Nothing here is edited by hand.

**VI:** Thư mục này chứa log và báo cáo của lần chạy sanity gần nhất trên `../rtl`. Chúng do `Makefile` ở thư mục cha sinh ra (`make all`) và được release cùng RTL. Không sửa tay file nào ở đây.

| File | Made by / Sinh bởi | Content / Nội dung |
|---|---|---|
| `rtl_check_report.md` | `make check` | VLSIT RTL rule check (rule file v2, skill `vlsit-rtl-generator`) / kiểm rule RTL VLSIT |
| `lint_verilator.log` | `make lint` | Verilator lint (5 warnings: the 5 inputs that are unused by design) / lint Verilator (5 cảnh báo: 5 input cố ý không dùng) |
| `lint_slang.log` | `make lint` | slang lint (0 errors, 0 warnings) / lint slang |
| `sim_default.log` | `make sim` | Testbench and the table of the 36 protocol assertions with their hit counts, default parameters (ADDR_W=32, SRC_W=8, SRC_ID=0) / testbench và bảng 36 assertion giao thức cùng số lần kích hoạt, tham số mặc định |
| `sim_narrow.log` | `make sim-narrow` | Same, ADDR_W=16, SRC_W=1, SRC_ID=1 / như trên, cấu hình hẹp |

## Commands / Lệnh

```sh
make all                       # check + lint + sim + sim-narrow
make check                     # rule check          -> sanity/rtl_check_report.md
make lint                      # Verilator and slang -> sanity/lint_*.log
make sim                       # testbench           -> sanity/sim_default.log
make sim-narrow                # narrow configuration -> sanity/sim_narrow.log
make sim SEED=7 N=2000         # another seed, more random transfers
```

**EN:** Run them from the parent folder (`common_rtl/008_APB2TLUL_Bridge`). The Makefile header lists the requirements (GNU make, Icarus Verilog, Verilator and/or slang, Python 3; the OSS CAD Suite has all of them) and the Windows and Linux options. The testbench is `../verification/tb_apb_tlul_bridge.sv` and the assertions are `../verification/apb_tlul_protocol_assertions.sv` (list in `../verification/README.md`); the run is self-checking and ends with `$fatal` on any failed check, a failed assertion, or an assertion that never fired.

**VI:** Chạy từ thư mục cha (`common_rtl/008_APB2TLUL_Bridge`). Phần đầu Makefile ghi yêu cầu (GNU make, Icarus Verilog, Verilator và/hoặc slang, Python 3; OSS CAD Suite có đủ) và cách dùng trên Windows và Linux. Testbench là `../verification/tb_apb_tlul_bridge.sv` và các assertion là `../verification/apb_tlul_protocol_assertions.sv` (danh sách trong `../verification/README.md`); lần chạy tự kiểm và kết thúc bằng `$fatal` khi có check thất bại, assertion lỗi, hoặc assertion không bao giờ kích hoạt.

## What the testbench covers / Testbench kiểm những gì

**EN:** Latency for every combination of back pressure and response delay (0 to 3 cycles); all 16 strobe values on reads and the 15 illegal strobes on writes; misaligned addresses; device errors, wrong `d_opcode` and wrong `d_source`; orphan responses; back-to-back transfers with `PSEL` held high and with gaps, for every ordered pair of transfer kinds; reset in the middle of a transfer; 400 constrained-random transfers (seed 1). Monitors check the APB completion protocol, the stability of TL-UL channel A, the constant fields, one outstanding request and the reset values.

**VI:** Độ trễ cho mọi tổ hợp back pressure và độ trễ response (0 đến 3 chu kỳ); cả 16 giá trị strobe khi đọc và 15 strobe không hợp lệ khi ghi; địa chỉ lệch; lỗi từ thiết bị, `d_opcode` sai và `d_source` sai; response mồ côi; transfer liên tiếp khi `PSEL` giữ cao và khi có khoảng trống, cho mọi cặp loại transfer; reset giữa chừng; 400 transfer ngẫu nhiên có ràng buộc (seed 1). Các monitor kiểm giao thức hoàn tất APB, độ ổn định kênh A của TL-UL, các trường hằng, một request đang chạy và giá trị reset.

**EN – Limits:** the testbench and the assertions were shown to catch 15 deliberately injected RTL bugs (illegal strobe or misalignment accepted, read data not cleared on error, `d_source` or `d_error` ignored, `d_ready` stuck low, back-to-back broken, wrong opcode, mask or size, `PSLVERR` without `PREADY`, `PREADY` for two cycles, `a_valid` dropped before `a_ready`, wrong `a_source`, orphan taken as a response); formal proof, coverage collection and a UVM environment are not part of it.

**VI – Giới hạn:** testbench và các assertion đã được thử bắt được 15 lỗi RTL cố ý chèn (nhận strobe sai hoặc địa chỉ lệch, không xoá dữ liệu đọc khi lỗi, bỏ qua `d_source` hoặc `d_error`, `d_ready` kẹt thấp, hỏng back-to-back, opcode, mask hoặc size sai, `PSLVERR` không có `PREADY`, `PREADY` hai chu kỳ, `a_valid` hạ trước `a_ready`, `a_source` sai, nhận response mồ côi); không có formal, đo coverage hay môi trường UVM.

