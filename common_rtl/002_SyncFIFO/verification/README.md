# Verification of the synchronous-clock FIFO

Testbench `tb_sfifo.sv` and runner `vlsit_run_sim.py` (Python 3, iverilog 12 or later with `-g2012`; works on Windows and Linux).
This folder is not part of the design file set and not part of `rtl/filelist.f` (rule R-022).

```
python vlsit_run_sim.py quick      # 8 configurations, about 30 s
python vlsit_run_sim.py full       # depth x PTR_RETIME x macro x clock ratio, add --seeds N for more seeds
```

Every run prints an assertion table and `RESULT PASS`, or fails with a non-zero exit status when an assertion
fails or never fired (rule R-025). Checks come from `SyncFIFO_Design_Specification.md` (requirement IDs are in the
assertion names); the RTL was read only for port names, widths and parameters.

Stimulus: reset values, underflow, write into empty with the flag-fall latency, fill and overflow with the
full-fall latency, threshold sweep, gap-free streaming (depth at least 4 + 2 x PTR_RETIME), software reset
(1, 3 and 10 cycle low levels, one-cycle pulse on a full FIFO, requests while blocked), random traffic at four
request densities with a scoreboard, hardware reset in traffic and in the middle of a software reset.

Not covered: formal proof, code coverage, clock ratios other than those of the runner, STA of the crossing paths.

## Waveform evidence (R-033)

`vlsit_gen_sim_waves.py` simulates the 15 waveforms of the plan of section 10.3 of the specification on the delivered RTL (synthesis flow, `-DVLSIT_SYNTHESIS`; the SyncFIFO has no clock-domain crossing, so R-034 does not apply) and writes `waveforms_sim/`: for each waveform a VCD dump, a WaveJSON and an SVG with the stem of the specification figure, and `waveform_compare.md`. All 15 waveforms are MATCH (the WaveJSON of the RTL, including the internal rows, equals the WaveJSON of the specification figure). Check with `python <skill>/scripts/vlsit_sim_evidence.py check ../SyncFIFO_Design_Specification.md waveforms_sim`.
