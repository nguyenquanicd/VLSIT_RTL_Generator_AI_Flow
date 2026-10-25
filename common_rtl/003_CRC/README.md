# CRC Implementations / Các cách triển khai CRC

## English

This directory contains five synthesizable CRC implementations. They share an MSB-first CRC recurrence but differ in input width, work per cycle, latency, and optional CRC features. The RTL is under `rtl/`; self-checking testbenches and their plan are under `tests/`; sanity logs and reports are under `sanity/`.

### Implementation comparison

The values below use each module's default parameters. “Recurrence stages” describes how many input bits the CRC recurrence is expanded across in one cycle. State-bit counts include the sequential registers declared by the RTL; they are not cell-area measurements.

| Implementation | Default configuration | Result latency | Recurrence stages per cycle | State bits | Relative Fmax potential | Relative combinational logic trend |
|---|---|---:|---:|---:|---|---|
| `m_crc_serial` | CRC width 4; one input bit per cycle | Streaming, one bit/cycle | 1 | 5 | Highest | Lowest |
| `m_crc_initial_value` | CRC width 8; data width 16 | 16 processing cycles | 1 | 29 | High | Low |
| `m_crc_parallel_crcw` | CRC width 8; data width 32; chunk width 8 | 4 processing cycles | 8 | 51 | Medium | Medium |
| `m_crc_parallel` | CRC width 8; data width 16 | 1 processing cycle | 16 | 33 | Low | High |
| `m_crc_parallel_full` | CRC width 16; data width 32 | 1 processing cycle | 32 | 82 | Lowest | Highest |

These are structural estimates, not synthesized results. A deeper unrolled recurrence usually increases the register-to-register logic depth and combinational area. The full implementation also has input/output option logic; bit reflection itself is wiring, while option selection and XOR operations add logic. Synthesis optimization and the target cell library can change the ranking. The default widths differ, so the table is useful for a first architectural choice, not a width-normalized benchmark.

No MHz or ASIC gate-area numbers are reported: a target standard-cell library, PVT corner, clock constraints, and synthesis/STA results are not available here. State-bit counts are provided as a reproducible storage proxy only. For a fair implementation comparison, use the same CRC and data widths, library, PVT corner, constraints, and synthesis settings; compare mapped cell area and STA critical-path frequency.

### Selection guide

- Choose `m_crc_serial` for minimum datapath logic and low input throughput.
- Choose `m_crc_initial_value` when the initial state is carried in the input word and a multi-cycle result is acceptable.
- Choose `m_crc_parallel_crcw` to trade latency for a shorter recurrence path than full-word parallel processing.
- Choose `m_crc_parallel` for one-cycle word processing without reflection or initial/final XOR options.
- Choose `m_crc_parallel_full` when those CRC options and one-cycle word processing are required, with the largest default logic and state footprint.

### Verification

Run `make verify` from this directory. It runs the five timed self-checking simulations and a mutation check. Results are saved in `sanity/logs/`; see [`tests/README.md`](tests/README.md) for test scope and [`sanity/reports/simulation_report.md`](sanity/reports/simulation_report.md) for the recorded run.

The CRC bit order, polynomial convention, request/ready behavior, and reset behavior are described in the source project's [`crcCalculator README`](../../../crcCalculator/README.md).

---

## Tiếng Việt

Thư mục này có năm cách triển khai CRC có thể tổng hợp. Các module dùng chung phép cập nhật CRC MSB-first nhưng khác độ rộng đầu vào, số bit xử lý mỗi chu kỳ, độ trễ và các tùy chọn CRC. RTL nằm trong `rtl/`; testbench tự kiểm tra và kế hoạch test nằm trong `tests/`; log và báo cáo sanity nằm trong `sanity/`.

### So sánh các cách triển khai

Các số dưới đây dùng parameter mặc định của từng module. “Số tầng recurrence” là số bit đầu vào được mở rộng qua phép cập nhật CRC trong một chu kỳ. Số bit trạng thái đếm các thanh ghi tuần tự trong RTL; đây không phải số đo diện tích cell.

| Cách triển khai | Cấu hình mặc định | Độ trễ kết quả | Tầng recurrence mỗi chu kỳ | Số bit trạng thái | Tiềm năng Fmax tương đối | Xu hướng logic tổ hợp tương đối |
|---|---|---:|---:|---:|---|---|
| `m_crc_serial` | CRC rộng 4 bit; 1 bit dữ liệu/chu kỳ | Liên tục, 1 bit/chu kỳ | 1 | 5 | Cao nhất | Thấp nhất |
| `m_crc_initial_value` | CRC rộng 8 bit; dữ liệu rộng 16 bit | 16 chu kỳ xử lý | 1 | 29 | Cao | Thấp |
| `m_crc_parallel_crcw` | CRC rộng 8 bit; dữ liệu rộng 32 bit; khối rộng 8 bit | 4 chu kỳ xử lý | 8 | 51 | Trung bình | Trung bình |
| `m_crc_parallel` | CRC rộng 8 bit; dữ liệu rộng 16 bit | 1 chu kỳ xử lý | 16 | 33 | Thấp | Cao |
| `m_crc_parallel_full` | CRC rộng 16 bit; dữ liệu rộng 32 bit | 1 chu kỳ xử lý | 32 | 82 | Thấp nhất | Cao nhất |

Đây là ước lượng theo cấu trúc, không phải kết quả tổng hợp. Recurrence được mở rộng nhiều tầng thường làm tăng độ sâu logic giữa các thanh ghi và diện tích logic tổ hợp. Module full còn có logic tùy chọn đầu vào/đầu ra; đảo bit chỉ là nối dây, còn chọn chế độ và XOR cần thêm logic. Tối ưu của synthesis và thư viện cell có thể làm thay đổi thứ hạng. Độ rộng mặc định của các module khác nhau, vì vậy bảng phù hợp để chọn kiến trúc ban đầu, không phải benchmark đã chuẩn hóa theo độ rộng.

Không đưa số MHz hoặc diện tích cổng ASIC vì chưa có thư viện standard cell, corner PVT, ràng buộc clock và kết quả synthesis/STA. Số bit trạng thái chỉ là chỉ báo lưu trữ có thể tái lập. Để so sánh công bằng, cần dùng cùng độ rộng CRC và dữ liệu, thư viện, corner PVT, ràng buộc và thiết lập synthesis; sau đó so sánh diện tích cell đã ánh xạ và tần số critical path từ STA.

### Gợi ý chọn module

- Chọn `m_crc_serial` khi cần datapath nhỏ và thông lượng đầu vào thấp.
- Chọn `m_crc_initial_value` khi trạng thái khởi tạo được chứa trong từ đầu vào và có thể chấp nhận độ trễ nhiều chu kỳ.
- Chọn `m_crc_parallel_crcw` để đổi độ trễ lấy đường recurrence ngắn hơn xử lý song song toàn từ.
- Chọn `m_crc_parallel` để xử lý từ trong một chu kỳ, không cần đảo bit hoặc XOR khởi tạo/kết thúc.
- Chọn `m_crc_parallel_full` khi cần các tùy chọn CRC đó và kết quả trong một chu kỳ; mặc định dùng nhiều logic và trạng thái nhất.

### Verification

Chạy `make verify` tại thư mục này. Lệnh chạy năm mô phỏng timing tự kiểm tra và mutation check. Kết quả được lưu trong `sanity/logs/`; xem [`tests/README.md`](tests/README.md) để biết phạm vi test và [`sanity/reports/simulation_report.md`](sanity/reports/simulation_report.md) để xem kết quả đã ghi nhận.

Thứ tự bit CRC, quy ước polynomial, request/ready và reset được mô tả trong [`README của dự án crcCalculator`](../../../crcCalculator/README.md).
