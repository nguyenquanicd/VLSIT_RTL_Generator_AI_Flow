# Waveform Comparison / Đối chiếu waveform

`MATCH` means the simulated interface behavior agrees with the approved scenario. `DIFFERENT` records an observed mismatch; the regression is not passing. The WF-006 stimulus is an out-of-profile defensive check for AXI 4-KiB splitting.

`MATCH` nghĩa là hành vi giao diện mô phỏng phù hợp với kịch bản đã duyệt. `DIFFERENT` ghi nhận sai khác quan sát được; regression chưa đạt. Stimulus WF-006 nằm ngoài profile để kiểm tra phòng vệ việc chia burst tại biên 4 KiB của AXI.

The three `DIFFERENT` results are RTL behavior mismatches against the approved specification, not accepted changes to the expected behavior. Correcting RTL requires a separate approved change plan. / Ba kết quả `DIFFERENT` là sai khác của RTL so với đặc tả đã duyệt, không phải thay đổi được chấp nhận cho hành vi kỳ vọng. Việc sửa RTL cần một change plan được duyệt riêng.

| WF-ID | Specification figure | Simulated file | Result | Note |
|---|---|---|---|---|
| WF-001 | `figures/wf001_shared_reset.svg` | [VCD](wf001_shared_reset.vcd), [WaveJSON](wf001_shared_reset.json), [SVG](wf001_shared_reset.svg) | MATCH | Shared reset startup and serialized first read pass. Log: `../logs/wf001_shared_reset.log`. |
| WF-002 | `figures/wf002_read_error.svg` | [VCD](wf002_read_error.vcd), [WaveJSON](wf002_read_error.json), [SVG](wf002_read_error.svg) | MATCH | ARREADY stall and SLVERR-to-AHB ERROR scenario passes. Log: `../logs/wf002_read_error.log`. |
| WF-003 | `figures/wf003_bufferable_burst.svg` | [VCD](wf003_bufferable_burst.vcd), [WaveJSON](wf003_bufferable_burst.json), [SVG](wf003_bufferable_burst.svg) | DIFFERENT | AXI AW/W appears before all four AHB burst addresses are accepted; address `0x0000100C` then times out. Expected AW/W completion is absent. Log: `../logs/wf003_bufferable_burst.log`. |
| WF-004 | `figures/wf004_nonbufferable_write.svg` | [VCD](wf004_nonbufferable_write.vcd), [WaveJSON](wf004_nonbufferable_write.json), [SVG](wf004_nonbufferable_write.svg) | DIFFERENT | Actual AW is `addr=0, size=0, cache=0000, prot=100`; expected `addr=0x300, size=2, cache=0110, prot=101`. Bridge assertion 17 fails. Log: `../logs/wf004_nonbufferable_write.log`. |
| WF-005 | `figures/wf005_rejected_access.svg` | [VCD](wf005_rejected_access.vcd), [WaveJSON](wf005_rejected_access.json), [SVG](wf005_rejected_access.svg) | MATCH | HPROT[6] and HMASTLOCK rejection scenarios pass without AXI requests. Log: `../logs/wf005_rejected_access.log`. |
| WF-006 | `figures/wf006_4k_split.svg` | [VCD](wf006_4k_split.vcd), [WaveJSON](wf006_4k_split.json), [SVG](wf006_4k_split.svg) | DIFFERENT | AHB address `0x00001008` is not accepted, so the expected two AXI sub-bursts and aggregated response are not observed. Log: `../logs/wf006_4k_split.log`. |

The combined regression stops after the first failure. Its latest run logged 71 assertion checks, 896 hits, 1 assertion failure, 3 test-check failures, and 19 assertion checks not exercised after early termination. Per-scenario logs are the source for each row above.

Regression tổng hợp dừng sau lỗi đầu tiên. Lần chạy gần nhất ghi 71 assertion check, 896 hit, 1 assertion failure, 3 test-check failure và 19 assertion check chưa chạy do dừng sớm. Log từng kịch bản là căn cứ cho từng dòng ở trên.
