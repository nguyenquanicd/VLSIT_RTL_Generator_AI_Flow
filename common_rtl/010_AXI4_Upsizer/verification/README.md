# Verification of the AXI4 / AXI3 upsizer

Testbench written from `../AXI4_Upsizer_Design_Specification.md` (REQ-FUNC, REQ-IF, REQ-PARAM, REQ-ERR, TEST-001..021,
SVA-001..009, COV-001..006) and from AMBA AXI (IHI 0022). The RTL was read only for port names, widths and parameters.
Simulator: Verilator 5 (`--binary --timing`), the OSS CAD Suite of the machine.

| File | Content |
|---|---|
| `tb_ups.sv` | Testbench: AXI manager on the S side, AXI subordinate with a byte memory on the M side, reference functions of the specification, golden memory, scoreboard, directed and random tests |
| `ups_axi_chk.sv` | 33 protocol assertions, instantiated on the S interface and on the M interface (hit and failure counters) |
| `vlsit_run_sim.py` | `regress` (all configurations and seeds) and `one <config>`; logs in `logs/` |
| `vlsit_mutants.py` | 17 bugs injected on a copy of the RTL; result in `logs/mutation_result.md` |

## Run

```
python vlsit_run_sim.py regress --seeds 1,2,3
python vlsit_run_sim.py one axi3_il4 --seed 5 --vcd waves.vcd
python vlsit_mutants.py
```

On Windows run from PowerShell (the runner puts `msys64\ucrt64\bin` in front of PATH for the C++ build).
A run passes when the last lines are `assertion failures: 0, assertions never exercised: 0` and `PASS tb_ups`.

## Configurations (specification section 4)

`axi4_def` (CFG-AXI4-DEF), `axi3_def` (CFG-AXI3-DEF), `axi3_il4` (CFG-AXI3-IL4), `min_ratio` (S 512, M 1024), `max_ratio` (S 8, M 1024),
`depth2` (CFG-DEPTH-2), `id1_a12` and `id1_a64` (CFG-ID-1, address width 12 and 64).

## What is checked

- Final memory: every byte written on the S side (golden memory, direct S-side access) is in the memory of the M-side
  subordinate with the same value, and nothing else was written (REQ-FUNC-001, SVA-007).
- Manager-side AW and AR attributes against the reference functions of REQ-FUNC-002..006, 015, 017 (SVA-004).
- Read data, RID, RLAST and RRESP of every S beat, with the mapping S beat to M beat of REQ-FUNC-013.
- B response equal to the M-side response in the order received (REQ-FUNC-011).
- Order (REQ-FUNC-014), W after AW (REQ-FUNC-010 for the AXI4 top; REQ-FUNC-018 one-beat stage for the AXI3 top),
  outstanding limit (REQ-PARAM-003), READY and VALID low in reset and READY low in the first cycle after the release (REQ-IF-004).
- 33 AXI assertions per interface (handshake stability, VALID hold, no X, encodings, 4KB, WRAP, WLAST and RLAST position, B after
  AW and the last W beat, reset). The run fails when an assertion fails or never fires.

Directed tests: TEST-002, 003, 004, 005 (and 005b), 006, 007, 009, 010, 011, 021 (AXI3). Random: TEST-001, 012, 013, 019, 020
(four batches with different delay and error settings, with `+SEED`).

## Not done

- WF-001..WF-013 waveform evidence (`waveforms_sim`, R-033) is not produced; the directed tests reproduce the scenarios but not the
  exact cycle pattern of the figures.
- No formal proof of the combinational path analysis (TEST-016) and no synthesis run.
- Coverage is counted only for COV-001, COV-005, COV-006 (printed at the end of the log); COV-002, COV-003 and COV-004 are not
  measured.
