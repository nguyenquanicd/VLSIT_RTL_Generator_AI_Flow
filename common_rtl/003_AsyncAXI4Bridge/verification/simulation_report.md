# Async AXI Bridge Simulation Report

**Date:** 2026-10-27 (previous run: 2026-10-25)  
**Simulator:** Verilator 5.053  
**Overall status:** **PASS — `make test` returns 0.** The two failures of 2026-10-25 were caused by the metastability model of the Gray FIFO cell and are closed by the change of that model (spec `001_AsyncGrayFIFO` DEC-048).

## English

### Results

Official flow, `make test` in this folder, metastability seeds 1, 2, 3 (`+AFIFO_MSYNC_WIN_PCT` at its default of 10):

| Run | Seed 1 | Seed 2 | Seed 3 |
|---|---|---|---|
| AXI4 base, CDC model | PASS | PASS | PASS |
| AXI4 USER, CDC model | PASS | PASS | PASS |
| AXI3, CDC model | PASS | PASS | PASS |

The synthesis branch passes for AXI4 base, AXI4 USER and AXI3, and the depth-2 configuration passes. Each run exercises all 36 checks (`assertion failures: 0, assertions never exercised: 0`). The traffic counts are AW=6, W=24, B=6, AR=6 and R=24. The CDC evidence check reports synthesis runs 14 and metastability seeds 1, 2, 3, `RESULT: PASS`. All 11 planned waveform runs produced VCD, WaveJSON and SVG and pass the waveform evidence check; the regenerated VCD files are identical to the ones already in the repository. Code coverage was not measured.

Wider check (not part of `make`, run once on scratch builds of the same RTL and testbench): 60 seeds per profile, `+AFIFO_MSYNC_SEED=n` for n = 1 to 60, window 10% and 50%, 0 failures out of 60 for AXI4 base, AXI4 USER and AXI3 in both cases. The model captured the old value in about half of the captures inside the window (780 captures inside the window and 370 to 410 old-value captures over 60 seeds at 10%; 3451 to 3470 and 1691 to 1727 at 50%).

### What failed on 2026-10-25 and why

With the earlier model (random extra latency of 0, 1 or 2 destination cycles on every input change, chosen independently for each bit), AXI4 USER seed 1 (`AXI-SVA-09`) and AXI3 seed 1 (`AXI-SVA-02`) failed at 176 ns: two bits of a Gray pointer that changed one write-clock cycle apart were delayed differently and arrived in reverse order, so the read side saw a pointer code that the write side never produced, the FIFO showed empty and the destination VALID dropped while READY was low. Over 60 seeds that model failed 13, 25 and 15 seeds for AXI4 base, AXI4 USER and AXI3, so the failure was not specific to seed 1 or to two profiles. The full analysis with the waveform is in [cdc_skew_analysis/CDC_Seed1_Failure_Analysis.md](cdc_skew_analysis/CDC_Seed1_Failure_Analysis.md). The traces of the failing runs are kept as history: [AXI4 USER seed 1 VCD](waveforms_sim/failed_meta_user_seed1.vcd), [AXI3 seed 1 VCD](waveforms_sim/failed_meta_axi3_seed1.vcd) and the matching `*_window.svg` files; the raw logs are `logs/failed_meta_*.log.raw` and `logs/diag_user_nometa_seed1.raw`. They were made with the earlier model and do not reproduce with the current one.

### What changed

The model of `000_Common/rtl_lib/m_vlsit_afifo_cell_sync.sv`: the first flop captures the new or the old value with a probability of 50% each, only when the input changed less than a window W before the capturing edge (W is `+AFIFO_MSYNC_WIN_PCT` percent of the measured period of the destination clock, default 10); outside the window it captures as a plain flop. The latency after the first capturing edge is S-1 or S. A bit that is not close to the capturing edge cannot be late, so two bits of a pointer are not reordered while W is shorter than the source clock period. No RTL file of this IP was changed for this fix. The model is tested alone by `000_Common/lib_tests/tb_afifo_cell_sync.sv`.

### Limits

- The model is a digital model, not an analog metastability simulation. It does not model the hold side or metastability that survives the second flop.
- The condition for the model is that the source clock is at most 100 / WIN_PCT times faster than the destination clock (10 times at the default window). Real hardware limits the skew of the Gray bus with timing constraints; this simulation does not replace the static timing and CDC review.
- The testbench clocks (10 ns and 14 ns) have a fixed phase relation, so a very small window may never be hit; the default window of 10% is hit.
- This simulation does not replace formal proof, static CDC/RDC analysis, synthesis, STA, AXI compliance testing, or code-coverage measurement.

## Tiếng Việt

### Kết quả

Quy trình chính thức `make test` tại thư mục này, seed metastability 1, 2, 3 (`+AFIFO_MSYNC_WIN_PCT` mặc định 10):

| Lượt chạy | Seed 1 | Seed 2 | Seed 3 |
|---|---|---|---|
| AXI4 base, mô hình CDC | PASS | PASS | PASS |
| AXI4 USER, mô hình CDC | PASS | PASS | PASS |
| AXI3, mô hình CDC | PASS | PASS | PASS |

Nhánh synthesis pass với AXI4 base, AXI4 USER, AXI3 và cấu hình depth 2. Mỗi lượt chạy hit đủ 36 kiểm tra. Evidence check CDC báo 14 lượt synthesis và các seed 1, 2, 3, `RESULT: PASS`. Cả 11 waveform theo kế hoạch đều có VCD, WaveJSON và SVG và pass; các VCD sinh lại giống hệt các file đã có trong repo. Chưa đo code coverage.

Kiểm tra rộng hơn (ngoài `make`, chạy một lần trên bản build trong thư mục tạm của cùng RTL và testbench): 60 seed mỗi profile, cửa sổ 10% và 50%, 0 lỗi trên 60 seed cho cả AXI4 base, AXI4 USER và AXI3.

### Lỗi ngày 2026-10-25 và nguyên nhân

Với mô hình cũ (trễ thêm 0, 1 hoặc 2 chu kỳ ngẫu nhiên, độc lập từng bit, ở mọi lần đổi), AXI4 USER seed 1 (`AXI-SVA-09`) và AXI3 seed 1 (`AXI-SVA-02`) lỗi lúc 176 ns: hai bit của Gray pointer đổi cách nhau một chu kỳ ghi bị trễ khác nhau nên đến ngược thứ tự, phía đọc thấy mã pointer mà phía ghi chưa từng tạo ra, FIFO báo empty và VALID phía đích tụt khi READY vẫn 0. Trên 60 seed mô hình cũ lỗi 13, 25 và 15 seed (AXI4 base, AXI4 USER, AXI3), nên lỗi không riêng seed 1. Phân tích đầy đủ kèm waveform ở [cdc_skew_analysis/CDC_Seed1_Failure_Analysis.md](cdc_skew_analysis/CDC_Seed1_Failure_Analysis.md). Trace các lượt lỗi được giữ làm lịch sử (tạo bằng mô hình cũ, không tái hiện với mô hình hiện tại).

### Thay đổi

Mô hình `000_Common/rtl_lib/m_vlsit_afifo_cell_sync.sv`: flop đầu chốt giá trị mới hoặc cũ với xác suất 50%, chỉ khi đầu vào đổi trong cửa sổ W trước cạnh chốt (W là `+AFIFO_MSYNC_WIN_PCT` % chu kỳ clock đích đo được, mặc định 10); ngoài cửa sổ chốt như flop thường. Độ trễ sau cạnh chốt đầu tiên là S-1 hoặc S. Không sửa file RTL nào của IP này.

### Giới hạn

- Là mô hình số, không phải mô phỏng metastability tương tự; chưa mô hình phía hold và metastability qua flop thứ hai.
- Điều kiện của mô hình: clock phát nhanh hơn clock nhận không quá 100 / WIN_PCT lần (10 lần ở mặc định). Phần cứng thật chặn skew của Gray bus bằng ràng buộc timing; mô phỏng này không thay thế review STA và CDC tĩnh.
- Clock của testbench (10 ns và 14 ns) có quan hệ pha cố định nên cửa sổ rất nhỏ có thể không bao giờ trúng; cửa sổ mặc định 10% có trúng.
- Mô phỏng này không thay thế chứng minh formal, phân tích CDC/RDC tĩnh, synthesis, STA, kiểm tra tuân thủ AXI hay đo code coverage.
