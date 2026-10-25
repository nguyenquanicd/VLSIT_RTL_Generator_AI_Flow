# Async AXI Bridge Simulation Report

**Date:** 2026-10-25  
**Simulator:** Verilator 5.053  
**Overall status:** **FAIL — two metastability-model seeds violate destination VALID hold.**

## English

### Results

| Run | Seed 1 | Seed 2 | Seed 3 |
|---|---|---|---|
| AXI4 base, CDC model | PASS | PASS | PASS |
| AXI4 USER, CDC model | FAIL: `AXI-SVA-09` at 176 ns | PASS | PASS |
| AXI3, CDC model | FAIL: `AXI-SVA-02` at 176 ns | PASS | PASS |

The synthesis branch passes for AXI4 base, AXI4 USER, AXI3, and the depth-2 configuration. Each run exercises all 36 checks. The full traffic counts are AW=6, W=24, B=6, AR=6, and R=24.

All 11 planned waveform runs produced VCD, WaveJSON, and SVG. The skill checker passes R-033 and fails R-034 because the two CDC runs above do not end with the required pass line. Code coverage was not measured.

The complete `make test` run also finished the waveform generation and evidence check, then returned exit code 2 for the two R-034 failures. As an isolation check, AXI4 USER seed 1 passes all 36 checks when `AFIFO_MSYNC_EN=0`; see `logs/diag_user_nometa_seed1.raw`.

### Failure evidence

- `AXI-SVA-09` checks that AXI4 USER destination `WVALID` stays asserted while `WREADY=0`.
- `AXI-SVA-02` checks the same hold behavior for the AXI3 destination AW channel.
- In both traces, the read-side synchronized write Gray pointer briefly returns to the read pointer while the write pointer is ahead. The FIFO empty flag then asserts and the destination VALID drops, although READY remains low. The outputs recover a few nanoseconds later.
- The transition is consistent with the simulation synchronizer applying independent random extra latency to each Gray-pointer bit. That model can reorder bit updates and create a transient empty indication.

Trace files: [AXI4 USER seed 1 VCD](waveforms_sim/failed_meta_user_seed1.vcd), [AXI4 USER failure window](waveforms_sim/failed_meta_user_seed1_window.svg), [AXI3 seed 1 VCD](waveforms_sim/failed_meta_axi3_seed1.vcd), and [AXI3 failure window](waveforms_sim/failed_meta_axi3_seed1_window.svg). Raw logs are `logs/failed_meta_axi4_user_seed1.log.raw` and `logs/failed_meta_axi3_seed1.log.raw`.

This is a failure in the exercised digital CDC simulation branch. It does not by itself establish silicon behavior because analog metastability and physical Gray-bus skew are not modeled. The CDC model and FIFO empty/VALID behavior need review before the verification result can be called passing. No RTL was changed for this simulation task.

## Tiếng Việt

### Kết quả

| Lượt chạy | Seed 1 | Seed 2 | Seed 3 |
|---|---|---|---|
| AXI4 base, mô hình CDC | PASS | PASS | PASS |
| AXI4 USER, mô hình CDC | FAIL: `AXI-SVA-09` tại 176 ns | PASS | PASS |
| AXI3, mô hình CDC | FAIL: `AXI-SVA-02` tại 176 ns | PASS | PASS |

Nhánh synthesis pass với AXI4 base, AXI4 USER, AXI3 và cấu hình depth 2. Mỗi lượt chạy đã hit đủ 36 kiểm tra. Tổng số giao dịch: AW=6, W=24, B=6, AR=6 và R=24.

Cả 11 waveform theo kế hoạch đều có VCD, WaveJSON và SVG. Skill checker pass R-033 và fail R-034 vì hai lượt CDC nêu trên không có dòng kết thúc pass bắt buộc. Chưa đo code coverage.

Lệnh `make test` chạy hết bước tạo waveform và evidence check, sau đó trả mã 2 do hai lỗi R-034. Trong phép cô lập, AXI4 USER seed 1 pass đủ 36 kiểm tra khi đặt `AFIFO_MSYNC_EN=0`; xem `logs/diag_user_nometa_seed1.raw`.

### Bằng chứng lỗi

- `AXI-SVA-09` kiểm tra `WVALID` phía đích của AXI4 USER phải giữ mức 1 khi `WREADY=0`.
- `AXI-SVA-02` kiểm tra tương tự cho channel AW phía đích của AXI3.
- Trong cả hai trace, write Gray pointer đã tiến nhưng write pointer sau đồng bộ phía đọc thoáng thời gian quay về bằng read pointer. Cờ FIFO empty được bật, làm VALID phía đích tụt dù READY vẫn bằng 0. Vài ns sau tín hiệu hồi phục.
- Chuyển trạng thái này phù hợp với khả năng mô hình synchronizer trong simulation thêm độ trễ ngẫu nhiên độc lập cho từng bit Gray pointer. Mô hình có thể đổi thứ tự cập nhật bit và tạo cờ empty thoáng qua.

Trace: [VCD AXI4 USER seed 1](waveforms_sim/failed_meta_user_seed1.vcd), [cửa sổ lỗi AXI4 USER](waveforms_sim/failed_meta_user_seed1_window.svg), [VCD AXI3 seed 1](waveforms_sim/failed_meta_axi3_seed1.vcd) và [cửa sổ lỗi AXI3](waveforms_sim/failed_meta_axi3_seed1_window.svg). Log raw nằm tại `logs/failed_meta_axi4_user_seed1.log.raw` và `logs/failed_meta_axi3_seed1.log.raw`.

Đây là lỗi trong nhánh mô phỏng CDC số đã chạy. Kết quả này chưa tự chứng minh hành vi silicon vì mô phỏng không biểu diễn metastability tương tự hoặc độ lệch Gray bus trên layout. Cần rà soát mô hình CDC và logic empty/VALID của FIFO trước khi kết luận verification pass. Không sửa RTL trong lần mô phỏng này.
