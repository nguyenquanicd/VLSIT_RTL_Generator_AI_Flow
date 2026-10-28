# Verification of m_vlsit_axi2tlul_top

Simulation only (iverilog, `-g2012 -DVLSIT_SYNTHESIS`). There is no formal proof, no coverage measurement, no STA, and no CDC check (single clock).

## Files

| File | Purpose |
|---|---|
| `tb_axi2tlul.sv` | Self-checking testbench: AXI4 manager model, TL-UL device model with random delay and reordering, scoreboard, directed phases (latency, burst continuity, arbitration order, wrong opcode, orphan response, reset in traffic), random batches, and a scenario mode that drives the inputs of a specification figure |
| `axi2tlul_checks.sv` | Protocol and requirement assertions (clocked check tasks with hit and fail counters); every assertion must fire at least once (rule R-025) |
| `vlsit_run_sim.py` | Runner: `regress` (8 configurations x seeds), `scenarios` (19 figures of the specification compared cycle by cycle), `mutants` (16 RTL mutants) |
| `logs/` | Logs and diffs of the last run; `mutation_result.md` lists the mutants |
| `waveforms_sim/` | VCD-derived waveforms and comparison with the specification figures |

## Run

Put `C:\Tools\oss-cad-suite\bin` and `lib` on `PATH`, then:

```bash
python vlsit_run_sim.py regress --seeds 1,2,3
python vlsit_run_sim.py scenarios
python vlsit_run_sim.py mutants
```

A run passes when `assertion failures: 0, assertions never exercised: 0` and the line `PASS tb_axi2tlul` are printed.

## Configurations

`base` (default), `wide` (DW 256, AW 40, NRD 32), `macro` (storage macro option, DW 64, NRD 64), `min` (2 slots, 1 ID), `rdprio`, `wrprio` (arbitration modes), `dw1024` (NRD 4), `slots128` (128 slots per direction).

## Testbench notes

- Burst continuity (REL-12) depends on the slot count: a burst needs one free read slot per beat, so the burst length is 8 beats for NRD >= 8, 4 beats for NRD >= 4, and 2 beats below that; two bursts back to back are checked for NRD >= 16.
- Event counting is per output: `o_evt_axi_err_rd` for illegal AR, `o_evt_axi_err_wr` for illegal AW and WLAST mismatch (DEC-021).
- The tags (`a_source`) seen in the figures are the ones of the lowest-free-slot allocation (DEC-020).
