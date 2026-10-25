# CRC Simulation Tests / Kiểm thử mô phỏng CRC

## English

The testbenches verify the five converted modules in `../rtl`. Golden CRC values come from `crcCalculator/README.md`: **Common CRC convention** and the matching module section. The reference model uses the documented MSB-first recurrence; it does not inspect internal RTL state. The RTL is used only for public port names, widths, and parameters.

Each test reports named assertion groups with hit and failure counts. No standard bus protocol is defined for these modules; checks cover the documented custom request, ready, reset, latency, and CRC behavior. Every group must be exercised, and failures or unexercised groups return a nonzero simulation status.

From `common_rtl/003_CRC`, run `make verify`. The Makefile contains all compile and simulation commands. Use `make test` for normal simulations, `make mutation-test` to confirm the checker catches an injected fault, and `make clean` to remove generated build files. Simulation logs are saved in `sanity/logs/`; temporary build files are saved in `sanity/build/`. Override random stimulus with `make verify SEED=17 N=100`. Required tools are GNU Make, Verilator with timing support, and a C++17 compiler.

## Tiếng Việt

Các testbench kiểm tra năm module đã chuyển đổi trong `../rtl`. Giá trị golden lấy từ `crcCalculator/README.md`, mục **Common CRC convention** và mục tương ứng của từng module. Mô hình tham chiếu dùng phép cập nhật MSB-first đã mô tả, không đọc trạng thái nội bộ RTL. RTL chỉ được dùng để lấy tên, độ rộng port và parameter.

Mỗi testbench in các nhóm assertion có số hit và số lỗi. Các module không dùng giao thức bus chuẩn; các check bao phủ request, ready, reset, độ trễ và phép tính CRC theo README. Mỗi nhóm phải được kích hoạt; lỗi hoặc nhóm không được kích hoạt sẽ làm mô phỏng trả mã lỗi khác 0.

Chạy `make verify` từ `common_rtl/003_CRC`. Makefile chứa toàn bộ lệnh biên dịch và mô phỏng. Dùng `make test` để chạy mô phỏng thường, `make mutation-test` để xác nhận test bắt được lỗi được chèn, và `make clean` để xóa file build được tạo. Log mô phỏng nằm trong `sanity/logs/`; file build tạm nằm trong `sanity/build/`. Đổi dữ liệu ngẫu nhiên bằng `make verify SEED=17 N=100`. Cần GNU Make, Verilator hỗ trợ timing và trình biên dịch C++17.
