# Bridge Verification / Kiểm chứng Bridge

## English

This folder contains an interface-only SystemVerilog testbench, simulation logs and waveforms, and one Makefile for rule check, lint, simulation, waveform evidence, mutation check, and generic synthesis. The testbench derives expected behavior from the approved bridge specification and Arm IHI 0033C / IHI 0022H.c; it reads RTL only for port names and widths. It has 71 protocol and bridge assertion checks with hit/fail counts.

Run `make -f Makefile all` from this folder. The commands are defined in one Makefile. The latest run passed WF-001, WF-002, and WF-005. WF-003, WF-004, and WF-006 fail against the specified behavior; see [waveform comparison](evidence/waveform_compare.md) and the per-test logs in `logs/`. The regression exits nonzero while these differences remain. Run `make -f Makefile sim`, `make -f Makefile waves`, or `make -f Makefile synth` to run an individual stage. Rule check passed with 2 warnings; Verilator lint passed with 27 warnings. Generic Yosys synthesis passed `check -assert` and produced 7,932 generic cells. No foundry library or timing constraints were used, so this count is not an ASIC area or timing estimate. The deliberate ARLEN mutation was caught by the testbench.

Outputs: VCD files are in `waveforms_sim/`, converted WaveJSON in `waveforms_json/`, rendered SVG in `waveforms_svg/`, and a flat evidence set for checking/review in `evidence/`. The synthesized generic netlist is `build/m_ahb2axi_top_synth.v`. RTL was not changed during this verification task.

## Tiếng Việt

Thư mục này chứa testbench SystemVerilog chỉ dùng giao diện, log mô phỏng, waveform và một Makefile duy nhất cho rule check, lint, mô phỏng, bằng chứng waveform, mutation check và tổng hợp generic. Kỳ vọng lấy từ đặc tả bridge đã duyệt và Arm IHI 0033C / IHI 0022H.c; testbench chỉ đọc RTL để lấy tên và độ rộng cổng. Testbench có 71 assertion protocol và chức năng bridge, đồng thời ghi số lần hit/fail.

Chạy `make -f Makefile all` trong thư mục này. Toàn bộ lệnh nằm trong một Makefile. Lần chạy gần nhất đạt WF-001, WF-002 và WF-005. WF-003, WF-004 và WF-006 chưa đạt hành vi trong đặc tả; xem [bảng đối chiếu waveform](evidence/waveform_compare.md) và log từng bài test trong `logs/`. Regression trả mã lỗi khi các sai khác này còn tồn tại. Có thể chạy riêng từng bước bằng `make -f Makefile sim`, `make -f Makefile waves` hoặc `make -f Makefile synth`. Rule check đạt với 2 cảnh báo; Verilator lint đạt với 27 cảnh báo. Tổng hợp generic bằng Yosys đạt `check -assert` và tạo 7.932 cell generic. Không dùng thư viện foundry hoặc ràng buộc timing, nên số cell này không phải ước lượng diện tích ASIC hay timing. Mutation ARLEN có chủ đích đã bị testbench phát hiện.

Đầu ra: VCD ở `waveforms_sim/`, WaveJSON ở `waveforms_json/`, SVG ở `waveforms_svg/`, và bộ bằng chứng phẳng để kiểm tra/xem ở `evidence/`. Netlist generic ở `build/m_ahb2axi_top_synth.v`. Không sửa RTL trong bước kiểm chứng này.
