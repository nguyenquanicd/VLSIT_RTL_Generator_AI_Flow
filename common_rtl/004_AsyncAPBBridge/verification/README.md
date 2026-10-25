# Verification of the asynchronous APB bridge

Testbench `tb_apbcdc.sv`, runner `vlsit_run_sim.py`, waveform evidence `vlsit_gen_sim_waves.py` (Python 3, iverilog 12 or later with `-g2012`; Windows and Linux).
This folder is not part of the design file set and not part of `rtl/filelist.f` (rule R-022).

```
python vlsit_run_sim.py quick        # 16 configurations x (synthesis branch + metastability seeds 1, 2, 3) = 64 runs
python vlsit_run_sim.py full         # 160 configurations (cell options 1 to 4, ten clock ratios), 640 runs, long
python vlsit_gen_sim_waves.py        # the 12 waveforms of the plan, simulated on the RTL, into waveforms_sim/
python <skill>/scripts/vlsit_sim_evidence.py check ../AsyncAPBBridge_Design_Specification.md waveforms_sim --logs logs
```

- **Both branches (R-034).** The synthesis branch is compiled with `-DVLSIT_SYNTHESIS` (cell models, deterministic latency); the simulation branch without it (the wrapper `m_vlsit_apbcdc_cell_sync` adds a random extra latency of 0 to 2 cycles; seed with `+APBCDC_MSYNC_SEED=n`). Every log in `logs/` prints `SIM-BRANCH:` and `assertion failures: 0, assertions never exercised: 0` (R-025).
- **Waveform evidence (R-033).** `waveforms_sim/` holds, for each waveform of the plan, the VCD, the WaveJSON and the SVG with the stem of the specification figure, and `waveform_compare.md` (all 12 MATCH, synthesis branch; the metastability branch is run for the assertions only).
- **Checks.** 28 assertions with their requirement ID or APB clause and hit counts (UP = requester-side interface, DN = completer-side interface), a two-sided scoreboard, the latency bound of REQ-PERF-001 and REQ-PERF-002 (widened by the extra latency of the model in the simulation branch). Variants: a requester that changes the fields in the Access phase (the Setup values must be used) and an APB5 requester that never drives `PWAKEUP`.

Not covered: formal proof, code coverage, the structural CDC check, STA of the crossings (SDC in a sign-off tool), a reset in the middle of random traffic (only WF-012), the `full` matrix (not run).
