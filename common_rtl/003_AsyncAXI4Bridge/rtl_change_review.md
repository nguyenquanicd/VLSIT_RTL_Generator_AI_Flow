# RTL Change Review — Async AXI Bridge Top Names — Plan Version 1

Status: Implemented

## 1. Design and input summary

- RTL root: `rtl/` in `common_rtl/003_AsyncAXI4Bridge`.
- Existing specifications: `AsyncAXI4Bridge_Design_Specification.md` and `rtl/generation_notes/AsyncAXI4Bridge_Resolved_Design_Specification.md`.
- Requested change: rename the three profile-specific top modules to the names given by the designer.
- Task-start RTL snapshot: `verification/change_snapshots/top_rename_plan_v1_20261026/` (18 source files).
- The working tree already contains edits to specification and RTL files. The snapshot captures their current state; no existing user edits are to be reverted.
- Analysis scope: module names, file names, top references in specifications and integration collateral. No functional behavior or interface signals are changed.

## 2. Requirement comparison

| ID | New requirement | Existing specification | Current source evidence | Intended result |
|---|---|---|---|---|
| USER-NAME-001 | Use `m_vlsit_async_axi3_bridge` for the AXI3 profile. | DEC-021 and the resolved profile list use `m_vlsit_axi3_async_top`. | `rtl/axi3/m_vlsit_axi3_async_top.sv`, its module declaration, filelist and testbench instance use the old name. | Rename the top module and file to `m_vlsit_async_axi3_bridge`. |
| USER-NAME-002 | Use `m_vlsit_async_axi4_bridge` for AXI4 base. | The main specification describes `m_vlsit_axi_async_top`. | `rtl/axi4_base/m_vlsit_axi_async_top.sv`, its module declaration, filelist, testbench instance and diagram use the old name. | Rename the top module and file to `m_vlsit_async_axi4_bridge`. |
| USER-NAME-003 | Use `m_vlsit_async_user_axi4_bridge` for AXI4 USER. | The resolved profile list uses `m_vlsit_axi_user_async_top`. | `rtl/axi4_user/m_vlsit_axi_user_async_top.sv`, its module declaration, filelist and testbench instance use the old name. | Rename the top module and file to `m_vlsit_async_user_axi4_bridge`. |

## 3. Affected modules and files

| Module or artifact | File | Proposed change | Reason |
|---|---|---|---|
| AXI3 top | `rtl/axi3/m_vlsit_axi3_async_top.sv` → `rtl/axi3/m_vlsit_async_axi3_bridge.sv` | Rename the file and module declaration. | Match the requested profile name and the one-module-per-file rule. |
| AXI4 base top | `rtl/axi4_base/m_vlsit_axi_async_top.sv` → `rtl/axi4_base/m_vlsit_async_axi4_bridge.sv` | Rename the file and module declaration. | Match the requested profile name and the one-module-per-file rule. |
| AXI4 USER top | `rtl/axi4_user/m_vlsit_axi_user_async_top.sv` → `rtl/axi4_user/m_vlsit_async_user_axi4_bridge.sv` | Rename the file and module declaration. | Match the requested profile name and the one-module-per-file rule. |
| RTL profile filelists | `rtl/axi3/filelist.f`, `rtl/axi4_base/filelist.f`, `rtl/axi4_user/filelist.f` | Update top comments and renamed source filenames. | Keep each profile compile list consistent with its source tree. |
| Specifications | `AsyncAXI4Bridge_Design_Specification.md`, `rtl/generation_notes/AsyncAXI4Bridge_Resolved_Design_Specification.md` | Replace stale top references; define the three profile-specific names in the naming decision and profile list. | Keep requirements, hierarchy tables and traceability aligned with RTL. |
| RTL guide | `rtl/README.md` | Update both English and Vietnamese profile names and the example lint command. | Keep user-facing build instructions accurate. |
| Verification instantiations | `verification/tb/tb_axi_bridge.sv` | Update the three top module types; preserve parameters, connections and stimulus. | Keep the existing testbench attached to the renamed tops. |
| Filelist generator | `verification/scripts/prepare_filelists.py` | Update the profile-to-top mapping. | Regenerate filelists from the current top names. |
| Generated verification filelists | `verification/filelists/axi3_sim.f`, `axi3_synth.f`, `axi4_base_sim.f`, `axi4_base_synth.f`, `axi4_user_sim.f`, `axi4_user_synth.f` | Regenerate after updating the script. | Ensure simulation and synthesis builds use the renamed source files. |
| Block diagram sources and render | `figures/axi_bridge_diagram_spec.json`, `figures/axi_bridge_block_diagram.drawio`, `figures/axi_bridge_block_diagram.svg` | Update the AXI4 base top label. | Keep the diagram label consistent with the default profile top. |

Historical lint logs, prior rule reports, simulation logs and waveform evidence are excluded because they record earlier runs using the old names. Channel module names, ports, hierarchy, logic, parameters, and test scenarios are excluded from the change.

## 4. Design choices

| Strategy | Functional coverage | Change size | Compatibility | Complexity | Risk |
|---|---|---|---|---|---|
| Rename the existing top modules and update all current source references (recommended and only planned strategy). | All three profiles retain their current RTL behavior and interfaces. | Three RTL file renames plus name-reference updates in listed collateral. | Existing integrations using old top names must update their instantiation names. | Low. | Low; module identifiers and source paths are the only RTL changes. |

## 5. Minimal-change rationale

The requested names are explicit, and the AXI3 example establishes the `m_vlsit_` prefix. The AXI4 base and USER names follow the same pattern. Updating every active in-repository reference avoids stale elaboration targets. Legacy alias modules are excluded because they would add modules and are not requested. No channel names, ports, RTL logic or verification behavior will change.

## 6. Open questions, assumptions, conflicts and risks

- Assumption: the requested names map to `m_vlsit_async_axi3_bridge`, `m_vlsit_async_axi4_bridge`, and `m_vlsit_async_user_axi4_bridge` respectively.
- Compatibility risk: external projects that instantiate any old top name must update it.
- No unresolved behavior or interface question was found.

## 7. Proposed validation

| Check | Command | Expected evidence | Status |
|---|---|---|---|
| RTL rule checker | `python C:\Users\PC\.codex\skills\vlsit-rtl-generator\scripts\vlsit_rtl_check.py check rtl\axi3 rtl\axi4_base rtl\axi4_user` | `RESULT: PASS`; 15 existing HIE-02 warnings, matching baseline. | PASS |
| AXI3 RTL lint | `python C:\Users\PC\.codex\skills\vlsit-rtl-generator\scripts\vlsit_lint_rtl.py lint rtl\axi3\filelist.f --top m_vlsit_async_axi3_bridge --tool auto` | No lint errors; existing warnings reported separately. | PASS: 0 errors, 25 `PINCONNECTEMPTY` warnings. |
| AXI4 base RTL lint | `python C:\Users\PC\.codex\skills\vlsit-rtl-generator\scripts\vlsit_lint_rtl.py lint rtl\axi4_base\filelist.f --top m_vlsit_async_axi4_bridge --tool auto` | No lint errors; existing warnings reported separately. | PASS: 0 errors, 25 `PINCONNECTEMPTY` warnings. |
| AXI4 USER RTL lint | `python C:\Users\PC\.codex\skills\vlsit-rtl-generator\scripts\vlsit_lint_rtl.py lint rtl\axi4_user\filelist.f --top m_vlsit_async_user_axi4_bridge --tool auto` | No lint errors; existing warnings reported separately. | PASS: 0 errors, 25 `PINCONNECTEMPTY` warnings. |
| Testbench elaboration | `make -C verification build/axi4_base_synth/Vtb_axi_bridge.exe build/axi4_user_synth/Vtb_axi_bridge.exe build/axi3_synth/Vtb_axi_bridge.exe` | All three testbench variants elaborate against the new module names. | BLOCKED before build: MSYS `make.exe` exited with `NtCreateDirectoryObject(...): 0xC0000022`. |
| Active-reference scan | Search source, specification, filelist, script and diagram files for all three old top identifiers. | No active references remain outside explicitly excluded historical evidence and this snapshot. | PASS: no old identifiers found. |

Full simulation is not proposed because no RTL logic, ports, parameters or test scenarios change. The existing simulation results remain applicable to behavior, while testbench elaboration checks the renamed module bindings.

## 8. Approval

Plan version 1 was approved by the designer on 2026-10-26.

## 9. Final implementation report

### Traceability and changed files

- `USER-NAME-001`: renamed `rtl/axi3/m_vlsit_axi3_async_top.sv` to `rtl/axi3/m_vlsit_async_axi3_bridge.sv`; updated declaration and AXI3 references.
- `USER-NAME-002`: renamed `rtl/axi4_base/m_vlsit_axi_async_top.sv` to `rtl/axi4_base/m_vlsit_async_axi4_bridge.sv`; updated declaration and AXI4 base references.
- `USER-NAME-003`: renamed `rtl/axi4_user/m_vlsit_axi_user_async_top.sv` to `rtl/axi4_user/m_vlsit_async_user_axi4_bridge.sv`; updated declaration and AXI4 USER references.
- Updated specification files: `AsyncAXI4Bridge_Design_Specification.md` and `rtl/generation_notes/AsyncAXI4Bridge_Resolved_Design_Specification.md`.
- Updated RTL collateral: `rtl/README.md`, `rtl/axi3/filelist.f`, `rtl/axi4_base/filelist.f`, and `rtl/axi4_user/filelist.f`.
- Updated verification sources: `verification/tb/tb_axi_bridge.sv` and `verification/scripts/prepare_filelists.py`.
- Regenerated verification filelists: `verification/filelists/axi3_sim.f`, `axi3_synth.f`, `axi4_base_sim.f`, `axi4_base_synth.f`, `axi4_user_sim.f`, and `axi4_user_synth.f`.
- Updated diagram artifacts: `figures/axi_bridge_diagram_spec.json`, `figures/axi_bridge_block_diagram.drawio`, and `figures/axi_bridge_block_diagram.svg`.
- Created the approved review report `rtl_change_review.md` and task-start RTL snapshot `verification/change_snapshots/top_rename_plan_v1_20261026/`.
- RTL hierarchy, ports, parameters, logic and test scenarios were unchanged. Historical lint logs, the older rule report, simulation logs and waveform evidence were preserved.

### Checks and limits

- RTL rule checker: PASS; 0 errors and 15 HIE-02 warnings, the same warning count and category as the baseline.
- Verilator lint: PASS for AXI3, AXI4 base and AXI4 USER; each reports 0 errors and 25 `PINCONNECTEMPTY` warnings, matching baseline.
- Filelist generator: completed for all three profiles and both synthesis/simulation branches (22 RTL sources per generated filelist).
- Old-name scan: PASS; no old top identifiers remain in active source, specification, filelist, script or diagram files. Historical reports/logs and the baseline snapshot intentionally retain the original names.
- Testbench elaboration: not completed. GNU Make failed before invoking a build target because its MSYS runtime could not create a named system object (`0xC0000022`).
- Simulation: not run; this change only renames top modules and paths.
- Remaining risk: external integrations that instantiate the former top names must update their references.

### Rule-ID report

- Failed by `vlsit_rtl_check.py`: none.
- Warned and justified: `HIE-02` (15 warnings). These pre-existing channel wrappers combine channel packing/unpacking logic with their asynchronous FIFO instance; the top rename does not change their structure.
- Clean by `vlsit_rtl_check.py`: `ARI-04`, `CMT-01`, `CMT-05`, `COM-02`, `COM-03`, `COM-04`, `COM-06`, `COM-07`, `ENM-01`, `ENM-03`, `ENM-04`, `ENM-05`, `ENM-06`, `FIL-01`, `FIL-02`, `FIL-03`, `FIL-04`, `FIL-05`, `FIL-06`, `HIE-01`, `HIE-03`, `HIE-05`, `NAM-07`, `NAM-08`, `NAM-09`, `NAM-TBL`, `P1`, `P2`, `P3`, `P4`, `P6`, `P7`, `P11`, `P12`, `P13`, `P14`, `P17`, `P18`, `P19`, `P20`, `P21`, `P22`, `P24`, `P25`, `P26`, `P27`, `P29`, `P30`, `PAR-01`, `PAR-02`, `PAR-03`, `R-019`, `R-027`, `R-032`, `R-035`, `R-036`, `R-038`, `SCP-01`, `SEC-8.1`, `SEQ-01`, `TYP-02`, and `TYP-06`.
- Covered by lint: `TYP-03`, `COM-05`, `ARI-01`, `P5`, `P8`, and `P23`. All three lint runs had zero errors. Their 25 `PINCONNECTEMPTY` warnings per profile are intentional unconnected FIFO status outputs per the specification.
- Manually checked for this change: each renamed file matches its declared top module; the three profile names agree across the specifications, filelists, testbench, generator, README and diagrams; the active-reference scan found no old top names.
- Not manually checked in this rename-only task: `NAM-01`, `NAM-05`, `COM-01`, `SEQ-02`, `SEQ-04`, `RST-01`, `RST-02`, `CLK-01`, `P9`, `P15`, `P16`, `P28`, `PRT-01`, `SCP-02`, and `CHK-11`.
- Testbench elaboration was attempted but blocked by the MSYS Make runtime; no simulation or synthesis was run.

### RTL code-change metrics

Task-start baseline: 1,956 nonblank, non-comment RTL code lines. Added: 732. Deleted: 732. Percentage: `(732 + 732) / 1,956 × 100 = 74.85%`. The metric is path-based: the three renamed files are counted as removed and added in full, so this percentage reflects file renames rather than a change to RTL behavior or structure.

Changed RTL paths reported by the metric:

| Status | File | Code lines |
|---|---|---:|
| Removed | `axi3/m_vlsit_axi3_async_top.sv` | 225 |
| Added | `axi3/m_vlsit_async_axi3_bridge.sv` | 225 |
| Removed | `axi4_base/m_vlsit_axi_async_top.sv` | 236 |
| Added | `axi4_base/m_vlsit_async_axi4_bridge.sv` | 236 |
| Removed | `axi4_user/m_vlsit_axi_user_async_top.sv` | 271 |
| Added | `axi4_user/m_vlsit_async_user_axi4_bridge.sv` | 271 |

Completion status: requested top-module renames and in-repository reference updates are implemented. Rule checking and RTL lint passed; testbench elaboration remains unverified because the available Make runtime failed before compiling.
