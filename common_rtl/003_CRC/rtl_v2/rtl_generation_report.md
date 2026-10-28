# Configurable CRC RTL Generation Report

## Deliverables

Generated under `common_rtl/003_CRC/rtl_v2` from
`CRC_Design_Specification.md`, using VLSIT RTL Design Rules v2.
The original `rtl/` directory was not modified.

| Module | Role |
|---|---|
| `m_crc_engine` | Structural top; connects the independent generator and checker. |
| `m_crc_gen` | Selects the elaborated CRC method for the generator stream. |
| `m_crc_check` | Selects the method, captures the final-beat reference CRC, and reports match. |
| `m_crc_serial` | Method 0: one input bit per accepted beat. |
| `m_crc_initial_value` | Method 1: serially processes accepted word bits. |
| `m_crc_parallel` | Method 2: full-word recurrence per processing cycle. |
| `m_crc_parallel_crcw` | Method 3: processes `PARA_CAL_W` bits per cycle. |
| `m_crc_parallel_full` | Method 4: reflected-input mapping and full-word recurrence. |

`m_crc_engine` retains the 19-port interface and nine elaboration parameters from
the approved specification. Method 0 requires `PARA_DATA_W=1`; methods 1–4 use
byte-multiple widths. Method 3 requires `PARA_CAL_W=PARA_CRC_W` and a compatible
data width. The common implementation uses `PARA_CRC_INIT`, the defined bit
recurrence, `PARA_CRC_W` augmentation bits, then reflect-out and XOR-out.

## Validation results

- RTL rule check: **PASS**, 0 errors, 1 explained warning.
- Verilator 5.053 lint, default configuration: **PASS**, 0 errors, 0 warnings.
- Verilator elaboration and lint, methods 0–4: **PASS** for all five selections.
  Method 0 used `PARA_DATA_W=1`; methods 1–4 used `PARA_DATA_W=32`.
- Negative elaboration checks for method 5 and an even polynomial: both failed
  on the invalid-configuration sentinel as intended.
- Simulation, synthesis, PPA, and testbench generation were not run.

Logs are `lint_verilator_final.log`, `config_method_0.log` through
`config_method_4.log`, `config_invalid_method.log`, and `config_invalid_poly.log`.

## Rule-ID report

**No failed rules.** The rule checker reports clean: SCP-01, NAM-TBL, NAM-07,
NAM-08, TYP-02, PAR-01–03, ENM-01/03–05, COM-02–04/06/07, R-019, ARI-04,
SEQ-01, HIE-01/03/05, FIL-01–06, SEC-8.1, CMT-01/05, P1–P4, P6/P7,
P11–P14, P17–P22, P24–P27, P29/P30, NAM-09, R-027, R-032, R-035/R-036,
R-038, and TYP-06.

Verilator covers and passes TYP-03, COM-05, ARI-01, P5, P8, and P23. Manual
review passed NAM-01, NAM-05, COM-01, SEQ-02/04, RST-01/02, CLK-01, TYP-01,
P9, P15/P16/P28, PRT-01, and SCP-02. CHK-11 was reviewed; synthesis and timing
signoff checks remain outside this RTL-generation run. The design uses one
clock, one synchronous reset style, no CDC, no FSM, and no technology cells.

**Explained findings (R-013):**

- `HIE-02` is a checker heuristic on `m_crc_check`. This channel wrapper captures
  the final reference CRC and compares it with the selected method result; it is
  not the structural top. `m_crc_engine` contains only structural instances.
- Filelist generation reports the unresolved `m_crc_invalid_config` instance.
  It exists only in the invalid-parameter generate branch so unsupported
  configurations fail elaboration. Valid configurations exclude that branch;
  the default and all five method configurations lint cleanly.

R-022 was followed: no testbench was added because this RTL-generation request
did not ask for one. No user changes to the existing RTL were made.

**Skill workflow rules:** R-001, R-003, R-007, R-009–R-014, R-016–R-021,
R-028–R-032, R-035, R-036, and R-038 were followed. R-015 was not applicable
because Verilator and slang are installed. R-023–R-026, R-033, and R-034 are
not applicable because this request did not include testbench generation or a
clock-domain crossing. No deviations from a SHOULD rule were needed (R-011).

## Reproduction commands

```powershell
python "C:\Users\PC\.codex\skills\vlsit-rtl-generator\scripts\vlsit_rtl_check.py" check `
  "C:\HQuan\102_MyGithub\VLSIT_RTL_Generator_AI_Model\common_rtl\003_CRC\rtl_v2"

python "C:\Users\PC\.codex\skills\vlsit-rtl-generator\scripts\vlsit_lint_rtl.py" lint `
  "C:\HQuan\102_MyGithub\VLSIT_RTL_Generator_AI_Model\common_rtl\003_CRC\rtl_v2\filelist.f" `
  --top m_crc_engine --tool verilator

verilator_bin --lint-only -Wall --top-module m_crc_engine `
  -GPARA_CRC_METHOD=0 -GPARA_DATA_W=1 -f filelist.f
```

For methods 1–4, change `PARA_CRC_METHOD` to 1, 2, 3, or 4 and use
`PARA_DATA_W=32`. Invalid selections are expected to fail elaboration.
