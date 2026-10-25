# RTL Change Review — CRC VLSIT Restyling — plan version 2

Status: Version 2 approved and implemented; static validation complete

## 1. Design and input summary

- RTL root: `C:\HQuan\102_MyGithub\crcCalculator`.
- Output root: `C:\HQuan\102_MyGithub\VLSIT_RTL_Generator_AI_Model\common_rtl\003_CRC`.
- Rule source: `C:\HQuan\102_MyGithub\VLSIT_RTL_Generator_AI_Model\spec_template\VLSIT_RTL_Design_Rule.md` (v2).
- Old specification: no separate approved design specification was supplied. The source README documents behavior, but this review treats it as descriptive context, not an independent normative specification.
- Selected modules: `crc`, `crcInitialValue`, `crcParallel`, `crcParallelCrcW`, and `crcParallelFull`. They are five independent alternatives; no RTL module instantiates another.
- Scope: restyle the five existing modules into one-module-per-`.sv` files under `003_CRC/rtl`, with a generated `filelist.f`. No algorithm or cycle behavior change is planned.
- Existing state: `crcCalculator` already has user-visible modifications from prior work. This plan preserves those files. The destination repository currently has an untracked `common_rtl` tree; `common_rtl/003_CRC` did not exist when this plan was prepared.
- Header values: Project `VLSIT Common RTL library`; Author `Nguyen Quan and Claude Sonnet 5.5 (user)`, matching existing RTL headers in `common_rtl`.
- Baseline snapshot: a temporary task-start copy of the five design modules and two serial-CRC include files, excluding testbenches; used for metrics and removed after comparison.
- Analysis limit: the five design modules are legacy `.v` files. The first whole-tree checker scan included testbench files; the design-only checker scan below is the valid baseline.

## 2. Requirement comparison

| ID | Requested outcome | Current source evidence | Planned result |
|---|---|---|---|
| UR-1 | Apply the VLSIT ASIC RTL rules | Five `.v` modules use plain `always`, legacy names, non-ANSI ports, and `reg`/`wire` declarations | Deliver five `.sv` modules with VLSIT naming, typed ports, `logic`, `always_comb`/`always_ff`, comments, and explicit sizing while preserving logic. Add internal state names where the checker requires `reg_*`. |
| UR-2 | Put the CRC RTL in `common_rtl` following its existing layout | Existing IP folders place RTL under `NNN_<IP>/rtl` and keep a `filelist.f` there | Add `common_rtl/003_CRC/rtl/` and generate its `filelist.f` using the skill script |
| UR-3 | Preserve the current CRC design behavior | Current source and `crcCalculator/README.md` describe five CRC implementations; no separate approved specification is available | Preserve the checked-in configurations, state transitions, reset behavior, latency, and CRC recurrence; do not fix or reinterpret behavior during restyling |

### Planned module, parameter, and port names

| Existing module | New module and file |
|---|---|
| `crc` | `m_crc_serial.sv` |
| `crcInitialValue` | `m_crc_initial_value.sv` |
| `crcParallel` | `m_crc_parallel.sv` |
| `crcParallelCrcW` | `m_crc_parallel_crcw.sv` |
| `crcParallelFull` | `m_crc_parallel_full.sv` |

Common port mapping: `clk` → `i_clk_core`; `rstN` or `rst_n` → `i_rst_n_core`; `ctrlEn` or `ctrl_en` → `i_ctrl_en`; `dataIn` → `i_data`; `GenPoly` or `genPoly` → `i_gen_poly`; `crcSeq` or `crc_seq` → `o_crc_seq`; `crcReady` → `o_crc_ready`.

Additional mapping: serial `data_in` → `i_data_bit`, `ctrl_poly_en` → `i_gen_poly`, `chk_en` → `i_chk_en`, and `crc_error` → `o_crc_err`; full CRC `initXorValue` → `i_init_xor_value`, `refInEn` → `i_ref_in_en`, `refOutEn` → `i_ref_out_en`, `finalXorValue` → `i_final_xor_value`, and `crcOut` → `o_crc_out`.

Parameter mapping: `CRC_WIDTH` → `PARA_CRC_W`, `DWIDTH` → `PARA_DATA_W`, and `CALWIDTH` → `PARA_CAL_W`. Existing derived parameters `DWIDTH_LSB`, `CALNUM`, `COUNTERW`, and `TMP_WIDTH` become appropriately named `LPARA_*` constants. Their existing checks require them to equal derived values, so valid configurations retain the same widths; direct instance overrides of those derived values will no longer be available.

The source currently defines both `CRC_CTRL_POLY` and `CRC_CHECKER`, so the serial output will use the corresponding enabled ports as a fixed interface and remove the RTL `define`/`include` configuration. Builds that intentionally disabled either macro are outside this conversion and would need a separate compatibility decision. No source hierarchy instance connects these five alternative modules. Existing testbench instance sites are not part of the output folder and will need the listed module/port renames if reused against the converted files.

## 3. Affected modules and files

| Existing source | Proposed output | Planned edits and reason |
|---|---|---|
| `serialCrcCal/crc.v`, `serialCrcCal/crc_define.h`, `serialCrcCal/crc_parameter.h` | `003_CRC/rtl/m_crc_serial.sv` | Convert configured serial CRC to ANSI ports and VLSIT names/types/processes; replace active macro-selected interface with its checked-in enabled configuration; remove include/macro dependencies. |
| `crcInitialValue/crcInitialValue.v` | `003_CRC/rtl/m_crc_initial_value.sv` | Convert header, parameters, ports, state and logic declarations, processes, and generate/function syntax to the rule. |
| `crcParallel/crcParallel.v` | `003_CRC/rtl/m_crc_parallel.sv` | Convert header, parameters, ports, declarations, processes, and generated CRC recurrence to the rule. |
| `crcParallelCrcW/crcParallelCrcW.v` | `003_CRC/rtl/m_crc_parallel_crcw.sv` | Convert header, parameters, ports, declarations, processes, counter, and generated recurrence to the rule. |
| `crcParallelFull/crcParallelFull.v` | `003_CRC/rtl/m_crc_parallel_full.sv` | Convert header, parameters, ports, declarations, processes, and generated reflection/CRC logic to the rule. |
| None | `003_CRC/rtl/filelist.f` | Generate a compile-order file listing the five `.sv` files. |

No source files were edited. No module, parameter, or macro was added. The first rule-check run on version 1 found that NAM-TBL requires sequential state names to use `reg_*`, while output ports must use `o_*`. The approved version 2 adds the eight listed internal state aliases and continuous assignments to the existing output ports. These aliases name existing state and do not add state elements, hierarchy, or functional hardware.

| Module | Proposed internal state signal(s) | Existing output port mapping |
|---|---|---|
| `m_crc_serial` | `reg_crc_seq`, `reg_crc_err` | `o_crc_seq = reg_crc_seq`; `o_crc_err = reg_crc_err` |
| `m_crc_initial_value` | `reg_crc_seq` | `o_crc_seq = reg_crc_seq` |
| `m_crc_parallel` | `reg_crc_seq`, `reg_crc_ready` | `o_crc_seq = reg_crc_seq`; `o_crc_ready = reg_crc_ready` |
| `m_crc_parallel_crcw` | `reg_crc_seq`, `reg_crc_ready` | `o_crc_seq = reg_crc_seq`; `o_crc_ready = reg_crc_ready` |
| `m_crc_parallel_full` | `reg_crc_ready` | `o_crc_ready = reg_crc_ready` |

## 4. Design choice

| Strategy | Functional coverage | Change size | Compatibility | Complexity | Risk |
|---|---|---|---|---|---|
| Convert the checked-in five-module configuration and add state aliases in `common_rtl/003_CRC/rtl` (recommended) | Preserves all five current implementations and the currently enabled serial polynomial-control and checker features; aliases retain the same state values | Five RTL files rewritten; eight internal state aliases; one generated filelist | Module and port names change; overrides of derived-width parameters are removed; macro-disabled serial variants are not retained | Moderate | Medium, because integrators and old testbenches must use the new names; user must accept the added RTL signal names |

## 5. Minimal-change rationale

This is a new output set so the original source remains available as the baseline. All five modules are retained; the conversion does not change hierarchy, add functionality, alter CRC equations, change accepted transactions, or modify reset/latency behavior. The proposed eight signals name state already present at the outputs and do not add sequential elements. Existing testbench files, the source README, and the prior `Makefile` are excluded because this request asks for rule-compliant design RTL in the shared RTL tree; the testbench source set is not part of `rtl/filelist.f`.

## 6. Open questions, assumptions, and risks

1. Header values confirmed by the designer as matching existing `common_rtl` RTL: Project `VLSIT Common RTL library`; Author `Nguyen Quan and Claude Sonnet 5.5 (user)`.
2. The serial module currently compiles with both optional features enabled by `crc_define.h`. This plan fixes the output interface to that checked-in configuration. Macro-disabled builds are not preserved.
3. Module and port renames break source compatibility with existing integrations and testbenches until their instantiations are updated.
4. Direct overrides of derived width parameters become unavailable because the VLSIT rule requires dependent widths to be localparams.
5. No independent CRC design specification was supplied; this conversion can preserve source-observable behavior but cannot establish conformance to an external CRC standard or prove correctness.
6. The first VLSIT checker run on the new files found 29 errors and 46 warnings. All errors were FIL-05 port alignment or NAM-TBL sequential-state naming. Version 2 fixes alignment and proposes the state aliases above. The checker also reported abbreviation, comment, structural-literal, and permitted R-027 simulation-branch warnings; the final report will classify each.
7. The user approved version 2, including the eight aliases. The output interfaces, module count, hierarchy, and number of sequential state elements remain unchanged from version 1.

## 7. Validation results

The approved checks were run after implementation. No simulation or testbench run was part of the approved plan.

| Check | Result | Evidence |
|---|---|---|
| Original RTL rule baseline | Expected legacy failures | Five original design files: 222 errors and 29 warnings before conversion. |
| Original RTL lint baseline | Pass | Five original tops: 0 errors and 7 warnings total. Findings are listed in the baseline summary above. |
| VLSIT RTL rules | Pass | `vlsit_rtl_check.py check`: 5 files, 0 errors, 12 warnings. Clean IDs include NAM-TBL, FIL-05, FIL-06, SEQ-01, TYP-02, PAR-01, and PAR-02. |
| Rule warnings | Classified | Eight PAR-03 warnings identify the architectural 8-bit byte mapping in input reflection. Four R-027 warnings identify parameter-checking simulation branches excluded from synthesis. No CMT-01 warnings remain. |
| Filelist | Pass | Generated compile-order filelists per independent top, then combined into `rtl/filelist.f`, which lists all five alternatives. |
| Verilator lint | Pass | Each of the five tops linted using the shared filelist: 0 errors and 0 warnings per top. Logs are in `sanity/logs/lint_verilator*.log`. |
| RTL code-change metric | 182.66% | Metrics script: 467 baseline code lines, 386 added, 467 deleted. The script treats all renamed output files as new and original paths as removed, so this measures path-level churn, not behavioral difference. |

The serial module uses the checked-in configuration with polynomial control and residue checking enabled. The simulation-only parameter guards were not evaluated by Verilator because the lint flow defines `VLSIT_SYNTHESIS`. The later simulations are recorded in `sanity/reports/simulation_report.md`; they check the documented behavior but do not claim conformance to a named CRC standard or equivalence to an independent approved specification.

## 8. Approval record

Version 1 was approved. Version 2 was approved by the user with the response `APPROVE version 2 — thêm alias`. The approval covers the eight internal state aliases documented in Section 3. Project and Author header values match the existing `common_rtl` RTL headers.

## 9. Final implementation report

- **Status:** Complete; version 2 was implemented as approved.
- **RTL output:** Five converted SystemVerilog modules under `003_CRC/rtl`, one module per file.
- **Additional deliverables:** `rtl/filelist.f`, `sanity/reports/rtl_rule_check.md`, five Verilator lint logs in `sanity/logs/`, and this change review.
- **Rule-check result:** Pass, 0 errors, 12 classified warnings (8 byte-width heuristic warnings and 4 simulation-only R-027 warnings).
- **Lint result:** All five module tops pass Verilator with 0 errors and 0 warnings.
- **Code-change metric:** 182.66% by the supplied metrics script; filename changes cause all baseline modules to be counted as removed and all output modules as added.
- **Functional scope:** No behavior change was intended. The eight approved aliases name existing state and add no flip-flops. Simulation and functional equivalence were not run.
- **Source preservation:** Original CRC source files were not modified.
