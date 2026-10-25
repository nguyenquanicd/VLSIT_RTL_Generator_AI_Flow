# Simulated waveforms of the delivered RTL against the specification figures

Produced by `vlsit_gen_sim_waves.py`; the SyncFIFO has no clock-domain crossing, so only the synthesis flow applies.

| Waveform ID | Specification figure | Simulated waveform | Result | Note |
|---|---|---|---|---|
| WF-001 | waveforms/sfifo_wf001_write_into_empty.svg | waveforms_sim/sfifo_wf001_write_into_empty.svg | MATCH | Same rows, wave strings and data labels as the figure; RTL, synthesis branch |
| WF-002 | waveforms/sfifo_wf002_read_show_ahead.svg | waveforms_sim/sfifo_wf002_read_show_ahead.svg | MATCH | Same rows, wave strings and data labels as the figure; RTL, synthesis branch |
| WF-003 | waveforms/sfifo_wf003_full_overflow.svg | waveforms_sim/sfifo_wf003_full_overflow.svg | MATCH | Same rows, wave strings and data labels as the figure; RTL, synthesis branch |
| WF-004 | waveforms/sfifo_wf004_empty_underflow.svg | waveforms_sim/sfifo_wf004_empty_underflow.svg | MATCH | Same rows, wave strings and data labels as the figure; RTL, synthesis branch |
| WF-005 | waveforms/sfifo_wf005_thresholds.svg | waveforms_sim/sfifo_wf005_thresholds.svg | MATCH | Same rows, wave strings and data labels as the figure; RTL, synthesis branch |
| WF-006 | waveforms/sfifo_wf006_flag_latency_retime0.svg | waveforms_sim/sfifo_wf006_flag_latency_retime0.svg | MATCH | Same rows, wave strings and data labels as the figure; RTL, synthesis branch |
| WF-007 | waveforms/sfifo_wf007_flag_latency_retime1.svg | waveforms_sim/sfifo_wf007_flag_latency_retime1.svg | MATCH | Same rows, wave strings and data labels as the figure; RTL, synthesis branch |
| WF-008 | waveforms/sfifo_wf008_back_to_back_equal_retime0.svg | waveforms_sim/sfifo_wf008_back_to_back_equal_retime0.svg | MATCH | Same rows, wave strings and data labels as the figure; RTL, synthesis branch |
| WF-009 | waveforms/sfifo_wf009_back_to_back_equal_retime1.svg | waveforms_sim/sfifo_wf009_back_to_back_equal_retime1.svg | MATCH | Same rows, wave strings and data labels as the figure; RTL, synthesis branch |
| WF-010 | waveforms/sfifo_wf010_back_to_back_write_faster.svg | waveforms_sim/sfifo_wf010_back_to_back_write_faster.svg | MATCH | Same rows, wave strings and data labels as the figure; RTL, synthesis branch |
| WF-011 | waveforms/sfifo_wf011_back_to_back_read_faster.svg | waveforms_sim/sfifo_wf011_back_to_back_read_faster.svg | MATCH | Same rows, wave strings and data labels as the figure; RTL, synthesis branch |
| WF-012 | waveforms/sfifo_wf012_pointer_wrap_depth5.svg | waveforms_sim/sfifo_wf012_pointer_wrap_depth5.svg | MATCH | Same rows, wave strings and data labels as the figure; RTL, synthesis branch |
| WF-013 | waveforms/sfifo_wf013_software_reset.svg | waveforms_sim/sfifo_wf013_software_reset.svg | MATCH | Same rows, wave strings and data labels as the figure; RTL, synthesis branch |
| WF-014 | waveforms/sfifo_wf014_software_reset_pulse_full.svg | waveforms_sim/sfifo_wf014_software_reset_pulse_full.svg | MATCH | Same rows, wave strings and data labels as the figure; RTL, synthesis branch |
| WF-015 | waveforms/sfifo_wf015_hardware_reset.svg | waveforms_sim/sfifo_wf015_hardware_reset.svg | MATCH | Same rows, wave strings and data labels as the figure; RTL, synthesis branch |
