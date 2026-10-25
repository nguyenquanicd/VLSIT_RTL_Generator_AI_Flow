# RTL Change Review — Separate FSM State Registers — Plan Version 1

Status: Implemented (approved plan version 1)

## 1. Design and input summary

- RTL source: `common_rtl/006_AXI2APB_Bridge/rtl/`.
- Prior specification: `common_rtl/006_AXI2APB_Bridge/AXI2APB_Bridge_Design_Specification.md`.
- Requested rule source: `spec_template/VLSIT_RTL_Design_Rule.md` (v2).
- Top: `m_axi2apb_bridge`; child modules: `m_axi2apb_rd_seq`, `m_axi2apb_wr_seq`, and `m_axi2apb_apb_ctrl`.
- Scope: coding-structure compliance only. No port, hierarchy, reset, handshake, or transaction behavior change is intended.
- The source RTL directory is currently untracked by Git. A task-start snapshot is stored at
  `C:\HQuan\rtl_snapshots\axi2apb_rule_v2_baseline_20261025`; this snapshot is the comparison
  baseline for this update.
- Analysis limit: no simulation, synthesis, or formal-equivalence result is included in this plan.

## 2. Requirement comparison

| ID | New requirement | Specification basis | Current RTL behavior and source evidence | Intended behavior |
|---|---|---|---|---|
| ENM-06 / R-036 | Each FSM current-state register has its own `always_ff` that updates only that state register. | `spec_template/VLSIT_RTL_Design_Rule.md`, ENM-06; `vlsit-rtl-generator/rule.md`, R-036. | `m_axi2apb_apb_ctrl.sv` updates `reg_fsm_ctrl_current_state` with `reg_turn_rd` and updates `reg_fsm_apb_current_state` with APB payload/response registers. `m_axi2apb_rd_seq.sv` updates `reg_fsm_rd_current_state` with read transaction registers. `m_axi2apb_wr_seq.sv` updates `reg_fsm_wr_current_state` with write transaction registers. | Move each current-state reset and next-state assignment into a dedicated state-only `always_ff`; retain every other register update in its existing sequential process. |
| Behavior preservation | Preserve the specification's interface and transaction behavior. | Sections 6.2, 10, and 14.2 of the bridge specification. | Top module instantiates the three approved child modules. Clock/reset are shared and synchronous. | Keep all 45 top-level ports, module names, instances, reset style, and transaction state transitions unchanged. |

## 3. Affected modules and files

| Module / item | Source or output path | Proposed change | Reason |
|---|---|---|---|
| `m_axi2apb_apb_ctrl` | `common_rtl/006_AXI2APB_Bridge/rtl/m_axi2apb_apb_ctrl.sv` → `common_rtl/006_AXI2APB_Bridge/rtl_v2/m_axi2apb_apb_ctrl.sv` | Split owner FSM and APB FSM state registers into two state-only `always_ff` blocks. | Satisfy ENM-06 / R-036 for both FSMs. |
| `m_axi2apb_rd_seq` | `common_rtl/006_AXI2APB_Bridge/rtl/m_axi2apb_rd_seq.sv` → `common_rtl/006_AXI2APB_Bridge/rtl_v2/m_axi2apb_rd_seq.sv` | Split `reg_fsm_rd_current_state` into its own state-only `always_ff`. | Satisfy ENM-06 / R-036. |
| `m_axi2apb_wr_seq` | `common_rtl/006_AXI2APB_Bridge/rtl/m_axi2apb_wr_seq.sv` → `common_rtl/006_AXI2APB_Bridge/rtl_v2/m_axi2apb_wr_seq.sv` | Split `reg_fsm_wr_current_state` into its own state-only `always_ff`. | Satisfy ENM-06 / R-036. |
| `m_axi2apb_bridge` | `common_rtl/006_AXI2APB_Bridge/rtl/m_axi2apb_bridge.sv` → `common_rtl/006_AXI2APB_Bridge/rtl_v2/m_axi2apb_bridge.sv` | Copy unchanged; include in the new output filelist. | Preserve the original source set and provide a complete independently lintable output set. |
| FSM update helper | `scripts/split_fsm_current_state.py` | Add a guarded, output-directory-only transformer for separating FSM state registers from mixed sequential blocks. | The same deterministic source transformation applies to four FSMs in three modules. |
| Script registry | `scripts/README.md` | Register the helper in English and Vietnamese. | Keep the project script index accurate. |
| Output filelist | `common_rtl/006_AXI2APB_Bridge/rtl_v2/filelist.f` | Generate from the copied RTL with the VLSIT filelist command. | Provide compile order for the complete updated set. |

## 4. Design choice

Only one sound strategy is proposed: copy the existing source set to `rtl_v2`, then separate each FSM state register into its own sequential process. The controller has two FSMs, so four state-only processes will exist across the three child modules.

This strategy has the smallest safe scope, retains the existing module and port interfaces, and leaves the original `rtl/` source set unchanged. A direct in-place edit would overwrite the task-start baseline and is excluded by the existing-RTL workflow.

## 5. Minimal-change rationale

Each moved assignment retains its current clock, synchronous active-low reset, reset encoding, and next-state expression. Non-state registers remain in their existing processes. The top module, APB controller arbitration policy, request/response sequencing, error handling, and `i_axi_wlast` integration assumption are excluded from functional changes.

## 6. Open questions, assumptions, conflicts, and risks

- Approval is required before implementation under R-008 and RSC-034.
- The proposed updated source output is `common_rtl/006_AXI2APB_Bridge/rtl_v2/`; the existing `rtl/` directory remains untouched.
- No behavioral ambiguity is introduced by this state-process split. The existing requirement that AXI traffic be protocol-compliant remains unchanged.
- Verilator's existing unused `i_axi_wlast` warning is outside the change scope and will be compared against the task-start baseline.

## 7. Proposed validation

| Check | Command | Expected evidence | Status |
|---|---|---|---|
| Rule checker | `python "C:\Users\PC\.codex\skills\vlsit-rtl-generator\scripts\vlsit_rtl_check.py" check "common_rtl\006_AXI2APB_Bridge\rtl_v2"` | `RESULT: PASS`; no R-036 finding. | PASS; 0 errors, 0 warnings |
| Filelist | `python "C:\Users\PC\.codex\skills\vlsit-rtl-generator\scripts\vlsit_lint_rtl.py" filelist "common_rtl\006_AXI2APB_Bridge\rtl_v2" --out "common_rtl\006_AXI2APB_Bridge\rtl_v2\filelist.f" --top m_axi2apb_bridge` | Lists all four modules, leaves before structural top. | Generated; 4 files, top last |
| Lint | `python "C:\Users\PC\.codex\skills\vlsit-rtl-generator\scripts\vlsit_lint_rtl.py" lint "common_rtl\006_AXI2APB_Bridge\rtl_v2\filelist.f" --top m_axi2apb_bridge` | Zero lint errors; compare warning count and text with baseline. | PASS; 0 errors, 1 unchanged warning |
| Parameter elaboration | Verilator `--lint-only -Wall -Wno-fatal` with `PARA_AXI_ID_W=1` and `16`, using `rtl_v2/filelist.f`. | Both supported boundary widths elaborate; report any pre-existing `i_axi_wlast` warning. | PASS; both exit 0 |
| Change metrics | `python "C:\Users\PC\.codex\skills\vlsit-rtl-spec-change-implementer\scripts\vlsit_rtl_change_metrics.py" compare "C:\HQuan\rtl_snapshots\axi2apb_rule_v2_baseline_20261025" "common_rtl\006_AXI2APB_Bridge\rtl_v2"` | Baseline/added/deleted non-comment RTL lines and percentage. | 1,058 baseline; +16, -0; 1.51% |

Simulation, synthesis, and formal equivalence are not proposed for this coding-structure-only update.

## 8. Approval

User approved plan version 1, including the listed RTL files, `rtl_v2/`, the helper script and registry entry, and the validation commands.

## 9. Final implementation report

### Requirement traceability

- ENM-06 / R-036: each current-state register now has a dedicated state-only process in `rtl_v2/m_axi2apb_apb_ctrl.sv`, `rtl_v2/m_axi2apb_rd_seq.sv`, and `rtl_v2/m_axi2apb_wr_seq.sv`.
- Top interface and behavior preservation: `rtl_v2/m_axi2apb_bridge.sv` is copied unchanged; all four modules remain in the generated `rtl_v2/filelist.f`.

### Changed files

- `common_rtl/006_AXI2APB_Bridge/rtl_v2/m_axi2apb_apb_ctrl.sv`: split owner and APB state registers.
- `common_rtl/006_AXI2APB_Bridge/rtl_v2/m_axi2apb_rd_seq.sv`: split the read state register.
- `common_rtl/006_AXI2APB_Bridge/rtl_v2/m_axi2apb_wr_seq.sv`: split the write state register.
- `common_rtl/006_AXI2APB_Bridge/rtl_v2/m_axi2apb_bridge.sv`: copied unchanged.
- `common_rtl/006_AXI2APB_Bridge/rtl_v2/filelist.f`: generated compile order.
- `scripts/split_fsm_current_state.py` and `scripts/README.md`: tested and registered the guarded transformer.

The original `common_rtl/006_AXI2APB_Bridge/rtl/` SystemVerilog sources were not edited.

### Validation results and remaining risks

- VLSIT RTL rule checker: PASS, 0 errors and 0 warnings, including ENM-06 and R-036.
- VLSIT lint script: PASS, 0 errors and 1 warning. The unchanged `UNUSEDSIGNAL` warning is for top-level `i_axi_wlast`; malformed WLAST recovery is outside the approved AXI profile.
- Parameter elaboration at `PARA_AXI_ID_W=1` and `16`: both Verilator runs exited 0; each reported the same `i_axi_wlast` warning.
- Helper script: successfully transformed the actual AXI2APB source set into the new output folder without editing the source folder.
- Simulation, synthesis, and formal equivalence were not run. This change only separates sequential processes; those checks were not part of the approved plan.

### RTL code-change metrics

- Baseline nonblank, non-comment RTL lines: 1,058.
- Added RTL code lines: 16.
- Deleted RTL code lines: 0.
- Percentage: `(16 + 0) / 1,058 × 100 = 1.51%`.
- Metrics changed files: `m_axi2apb_apb_ctrl.sv`, `m_axi2apb_rd_seq.sv`, and `m_axi2apb_wr_seq.sv`.

Implementation status: Complete.
