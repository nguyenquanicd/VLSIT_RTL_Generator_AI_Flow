# Async AXI Bridge Verification

## English

This folder contains a self-checking SystemVerilog testbench for the AXI4 base, AXI4 USER and AXI3 bridge profiles. Stimulus and expected transfers follow the resolved design specification and Arm AMBA AXI Protocol Specification IHI 0022H.c, clauses A3.1.2, A3.2.1, A3.2.2 and A3.3. RTL is used only to connect port names and widths.

Run the complete regression from this directory with `make test`. The Makefile is the single entry point for compilation, simulation, log normalization, waveform conversion and evidence checks.

| Target | What it runs |
|---|---|
| `make synth` | `VLSIT_SYNTHESIS` branch for all three profiles |
| `make cdc` | Synthesis branch plus the simulation/metastability branch with seeds 1, 2 and 3 for every profile |
| `make waveforms` | Eleven specification scenarios, simulation-produced VCD, WaveJSON and SVG artifacts |
| `make test` | Full run and `vlsit_sim_evidence.py` checks |

The testbench checks each of the five AXI channels independently. It checks source VALID/payload hold, destination VALID/payload hold, oldest-word forwarding, known payload while VALID is high, and reset VALID behavior. It also drives W before AW, four-beat and sixteen-beat writes, four-beat reads, response codes OKAY/EXOKAY/SLVERR/DECERR, AXI3 WID, USER sidebands, FIFO-full back-pressure and FIFO depth 2. The reference queues compare every carried payload bit.

There are 36 named assertion counters: seven per channel and one reset check. The run fails if any check fails or receives no hit. Each passing log ends with `assertion failures: 0, assertions never exercised: 0`.

**Current result (2026-10-25):** all three synthesis profiles and the depth-2 synthesis run pass. Seven of nine CDC runs pass; seed 1 fails the destination VALID-hold check for AXI4 USER (`AXI-SVA-09`) and AXI3 (`AXI-SVA-02`). All 11 waveform artifacts pass the waveform evidence check. The CDC evidence check correctly fails, so `make test` returns nonzero. See [simulation_report.md](simulation_report.md) for the trace and details.

Logs are in `logs/`. Simulation VCD, WaveJSON and SVG files are in `waveforms_sim/`. The waveform index marks cycle-aligned comparison as `NOT-SIMULATED`; the scenarios run in the regression, but no waveform is claimed as a cycle-for-cycle match to the specification drawing.

This simulation does not replace formal proof, static CDC/RDC analysis, synthesis, STA, AXI compliance testing, or code-coverage measurement. The metastability branch is the specified randomized digital latency model; it is not an analog metastability simulation. The Arm specification is available from the [official Arm Community download](https://community.arm.com/cfs-file/__key/communityserver-discussions-components-files/476/IHI0022H_5F00_amba_5F00_axi_5F00_protocol_5F00_spec.pdf).

## Tiếng Việt

Thư mục này chứa testbench SystemVerilog tự kiểm tra cho ba profile bridge AXI4 base, AXI4 USER và AXI3. Stimulus và giá trị kỳ vọng dựa trên design specification đã chốt và chuẩn Arm AMBA AXI IHI 0022H.c, các mục A3.1.2, A3.2.1, A3.2.2 và A3.3. RTL chỉ được dùng để nối tên và độ rộng cổng.

Chạy toàn bộ regression tại thư mục này bằng `make test`. Makefile là điểm chạy duy nhất cho compile, mô phỏng, chuẩn hóa log, chuyển đổi waveform và kiểm tra evidence.

| Lệnh | Nội dung |
|---|---|
| `make synth` | Chạy nhánh `VLSIT_SYNTHESIS` cho cả ba profile |
| `make cdc` | Chạy nhánh synthesis và nhánh simulation/metastability với seed 1, 2, 3 cho từng profile |
| `make waveforms` | Chạy 11 kịch bản waveform và tạo VCD, WaveJSON, SVG từ mô phỏng |
| `make test` | Chạy đầy đủ và kiểm tra bằng `vlsit_sim_evidence.py` |

Testbench kiểm tra riêng từng AXI channel: giữ VALID/payload phía nguồn, giữ VALID/payload phía đích, chuyển tiếp đúng word cũ nhất, payload xác định khi VALID cao và VALID trong reset. Các tình huống gồm W đến trước AW, write burst 4 và 16 beat, read burst 4 beat, response OKAY/EXOKAY/SLVERR/DECERR, WID của AXI3, USER sideband, back-pressure khi FIFO đầy và FIFO depth 2. Reference queue so sánh toàn bộ bit payload được chuyển tiếp.

Có 36 bộ đếm assertion: 7 cho mỗi channel và 1 kiểm tra reset. Mô phỏng lỗi nếu assertion thất bại hoặc không được hit. Log thành công kết thúc bằng `assertion failures: 0, assertions never exercised: 0`.

**Kết quả hiện tại (2026-10-25):** cả ba profile synthesis và cấu hình synthesis depth 2 đều pass. Có 7/9 lượt CDC pass; seed 1 lỗi kiểm tra giữ VALID phía đích ở AXI4 USER (`AXI-SVA-09`) và AXI3 (`AXI-SVA-02`). Cả 11 waveform đều pass kiểm tra evidence. Kiểm tra CDC báo lỗi đúng với kết quả mô phỏng, vì vậy `make test` trả về mã khác 0. Xem [simulation_report.md](simulation_report.md) để biết trace và chi tiết.

Log nằm trong `logs/`. VCD, WaveJSON và SVG mô phỏng nằm trong `waveforms_sim/`. Bảng waveform ghi `NOT-SIMULATED` cho việc so khớp từng chu kỳ: các hành vi có chạy trong regression, nhưng chưa khẳng định waveform khớp từng chu kỳ với hình trong specification.

Mô phỏng này không thay thế formal proof, phân tích CDC/RDC tĩnh, synthesis, STA, kiểm thử AXI compliance hoặc đo code coverage. Nhánh metastability là mô hình số có độ trễ ngẫu nhiên theo specification, không mô phỏng metastability tương tự. Tài liệu Arm có tại [trang tải chính thức của Arm Community](https://community.arm.com/cfs-file/__key/communityserver-discussions-components-files/476/IHI0022H_5F00_amba_5F00_axi_5F00_protocol_5F00_spec.pdf).
