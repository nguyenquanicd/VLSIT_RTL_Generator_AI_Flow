# Sanity Results / Kết quả sanity check

## English

- `logs/` stores lint and simulation command output.
- `reports/` stores human-readable check and review summaries.
- `build/` stores temporary Verilator outputs created by the Makefile flow. `make clean` removes this directory; saved logs and reports remain.

The simulation results are historical records. Run `make verify` from the project root to generate fresh logs.

## Tiếng Việt

- `logs/` lưu đầu ra lệnh lint và mô phỏng.
- `reports/` lưu báo cáo tổng hợp để đọc và rà soát.
- `build/` lưu file tạm do flow Makefile và Verilator tạo. `make clean` xóa thư mục này; log và báo cáo đã lưu vẫn được giữ lại.

Kết quả mô phỏng trong thư mục này là bản ghi của lần chạy trước. Chạy `make verify` tại thư mục gốc dự án để tạo log mới.
