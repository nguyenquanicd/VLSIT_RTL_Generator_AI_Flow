# CRC Simulation Report / Báo cáo mô phỏng CRC

## English

### Run result

All five converted CRC modules passed self-checking timed simulation against the behavioral model derived from `crcCalculator/README.md` (Common CRC convention and each module description). The run used Verilator 5.053 devel, g++ 16.2.0, `SEED=20261025`, and `N=32`. Every assertion group had at least one hit and zero failures; each test exceeded 20 checks.

| Testbench | Directed cases | Random cases | Assertion checks | Failures |
|---|---:|---:|---:|---:|
| `tb_crc_serial` | 3 frames | 32 frames | 1,224 | 0 |
| `tb_crc_initial_value` | 4 transactions | 32 transactions | 723 | 0 |
| `tb_crc_parallel` | 5 transactions | 32 transactions | 188 | 0 |
| `tb_crc_parallel_crcw` | 4 transactions | 32 transactions | 291 | 0 |
| `tb_crc_parallel_full` | 4 transactions | 32 transactions | 183 | 0 |

The suite also tested reset during an active transaction for the four asynchronous-reset modules and synchronous reset behavior for the serial module. Assertion hit/failure tables and full tool output are in `sanity/logs/tb_crc_*.log`.

### Mutation check

The test flow copied `m_crc_parallel.sv`, forced `o_crc_seq` to zero in the copy, and ran `tb_crc_parallel`. The CRC result, busy-request, and result-hold checks detected the defect. The expected-failure mutation check passed. The original RTL was not modified. See `sanity/logs/mutation_check.log`.

### Execution note and limits

The installed Icarus `vvp.exe` could not start in this environment (process status `0xC0000135`), and GNU Make was blocked at startup by the sandbox (`NtCreateDirectoryObject`, access denied). The same timed tests were therefore executed directly through `tests/run_verilator_sim.py`; the Makefile provides the repeatable `make verify` entry point for an environment where GNU Make can start.

These tests do not prove compliance with a named CRC standard, formal equivalence, exhaustive parameter coverage, or code coverage. The CRC README does not assign formal REQ-IDs or name a standard bus protocol; checks cite its behavior sections directly.

## Tiếng Việt

### Kết quả

Cả năm module CRC đã chuyển đổi đều qua mô phỏng timing tự kiểm tra với mô hình hành vi lấy từ `crcCalculator/README.md` (Common CRC convention và phần mô tả từng module). Lượt chạy dùng Verilator 5.053 devel, g++ 16.2.0, `SEED=20261025`, `N=32`. Mỗi nhóm assertion có hit và không có lỗi; mỗi test có trên 20 check.

| Testbench | Vector có hướng | Vector ngẫu nhiên | Số check assertion | Lỗi |
|---|---:|---:|---:|---:|
| `tb_crc_serial` | 3 frame | 32 frame | 1.224 | 0 |
| `tb_crc_initial_value` | 4 giao dịch | 32 giao dịch | 723 | 0 |
| `tb_crc_parallel` | 5 giao dịch | 32 giao dịch | 188 | 0 |
| `tb_crc_parallel_crcw` | 4 giao dịch | 32 giao dịch | 291 | 0 |
| `tb_crc_parallel_full` | 4 giao dịch | 32 giao dịch | 183 | 0 |

Suite còn kiểm tra reset khi đang xử lý đối với bốn module reset bất đồng bộ và reset đồng bộ của module serial. Bảng hit/lỗi assertion cùng log công cụ nằm trong `sanity/logs/tb_crc_*.log`.

### Mutation check

Flow sao chép `m_crc_parallel.sv`, ép `o_crc_seq` về 0 trong bản sao rồi chạy `tb_crc_parallel`. Các check kết quả CRC, request lúc bận và giữ kết quả đã bắt lỗi. Mutation check đạt vì lỗi dự kiến bị phát hiện. RTL gốc không bị sửa. Xem `sanity/logs/mutation_check.log`.

### Ghi chú môi trường và giới hạn

`vvp.exe` của Icarus trong môi trường này không khởi chạy được (mã `0xC0000135`); GNU Make cũng bị sandbox chặn lúc khởi động (`NtCreateDirectoryObject`, access denied). Vì vậy, các test timed được chạy trực tiếp qua `tests/run_verilator_sim.py`; Makefile cung cấp lệnh tái lập `make verify` cho môi trường GNU Make khởi chạy bình thường.

Các test này không chứng minh phù hợp với một chuẩn CRC cụ thể, formal equivalence, bao phủ mọi parameter hoặc code coverage. README CRC không đặt REQ-ID hình thức và không nêu bus protocol chuẩn; check trỏ trực tiếp tới các mục hành vi trong README.
