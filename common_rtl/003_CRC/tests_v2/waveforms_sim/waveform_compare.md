# Specification waveform comparison / Đối chiếu waveform đặc tả

These are measured VCD windows from the delivered RTL. The specification figures
use illustrative data and shorter stalls; literal drawings therefore differ.
The scoreboard separately checks the normative CRC, latency and handshake requirements.
No RTL or golden-model expectation was changed to match an illustration.

Đây là waveform đo từ simulation. Dữ liệu và thời gian stall khác hình minh họa;
scoreboard kiểm tra riêng CRC, latency và handshake theo yêu cầu đặc tả.

| Waveform ID | Specification figure | Simulated waveform | Result | Note |
|---|---|---|---|---|
| WF-001 | figures/waveforms/WF_001_reset_abort.svg | WF_001_reset_abort.svg | DIFFERENT | Measured base2 cycles 2–9; illustrative stimulus differs; requirement assertions pass. Retain measured evidence; no RTL/specification change. |
| WF-002 | figures/waveforms/WF_002_serial_bit_and_augment.svg | WF_002_serial_bit_and_augment.svg | DIFFERENT | Measured base0 cycles 175–207; illustrative stimulus differs; requirement assertions pass. Retain measured evidence; no RTL/specification change. |
| WF-003 | figures/waveforms/WF_003_initial_state_serial_word.svg | WF_003_initial_state_serial_word.svg | DIFFERENT | Measured base1 cycles 207–235; illustrative stimulus differs; requirement assertions pass. Retain measured evidence; no RTL/specification change. |
| WF-004 | figures/waveforms/WF_004_full_parallel_partial_keep.svg | WF_004_full_parallel_partial_keep.svg | DIFFERENT | Measured base2 cycles 168–173; illustrative stimulus differs; requirement assertions pass. Retain measured evidence; no RTL/specification change. |
| WF-005 | figures/waveforms/WF_005_chunked_processing.svg | WF_005_chunked_processing.svg | DIFFERENT | Measured base3 cycles 172–179; illustrative stimulus differs; requirement assertions pass. Retain measured evidence; no RTL/specification change. |
| WF-006 | figures/waveforms/WF_006_reflection_xor.svg | WF_006_reflection_xor.svg | DIFFERENT | Measured ref4 cycles 168–173; illustrative stimulus differs; requirement assertions pass. Retain measured evidence; no RTL/specification change. |
| WF-007 | figures/waveforms/WF_007_generator_result_stall.svg | WF_007_generator_result_stall.svg | DIFFERENT | Measured base2 cycles 169–182; illustrative stimulus differs; requirement assertions pass. Retain measured evidence; no RTL/specification change. |
| WF-008 | figures/waveforms/WF_008_checker_match.svg | WF_008_checker_match.svg | DIFFERENT | Measured base2 cycles 168–177; illustrative stimulus differs; requirement assertions pass. Retain measured evidence; no RTL/specification change. |
| WF-009 | figures/waveforms/WF_009_checker_mismatch_stall.svg | WF_009_checker_mismatch_stall.svg | DIFFERENT | Measured base2 cycles 175–185; illustrative stimulus differs; requirement assertions pass. Retain measured evidence; no RTL/specification change. |
| WF-010 | figures/waveforms/WF_010_independent_channels.svg | WF_010_independent_channels.svg | DIFFERENT | Measured base2 cycles 171–200; illustrative stimulus differs; requirement assertions pass. Retain measured evidence; no RTL/specification change. |
