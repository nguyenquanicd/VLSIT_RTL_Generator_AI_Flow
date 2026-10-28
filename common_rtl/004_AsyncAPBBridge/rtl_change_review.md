# RTL Change Review: Asynchronous APB Bridge Top-Module Rename

**Plan version:** 1  
**Status:** Approved and implemented; lint and static checks pass; full quick regression incomplete  
**Date:** 2026-10-26  
**Project:** `common_rtl/004_AsyncAPBBridge`

## 1. Design and input summary

The production RTL top is currently `m_vlsit_apbcdc_top` in `rtl/m_vlsit_apbcdc_top.sv`. It instantiates the requester-side and completer-side APB blocks and exposes both asynchronous clock domains. The user requests the new top name `m_vlsit_async_apb_bridge`, an update to the overall specification and design references, and validation.

The target design specification is `AsyncAPBBridge_Design_Specification.md`. It was already modified before this task. The planned specification edits are limited to exact references to the old top symbol and its SDC filename; unrelated existing changes will be preserved.

## 2. Requirement comparison and source evidence

| Requirement | Current source evidence | Planned result |
|---|---|---|
| Rename the production top module to `m_vlsit_async_apb_bridge` | `rtl/m_vlsit_apbcdc_top.sv` declares `module m_vlsit_apbcdc_top`; both RTL filelists and the verification runner name the old source file | Rename the RTL file and module declaration; update both filelists and the runner |
| Update design specification and implementation references | The specification uses the old top name in the hierarchy tables, requirement traceability, source-list section and DEC-015; the testbench instantiates the old module | Update all production-design references and the named testbench instance |
| Keep function and interfaces unchanged | The top connects `m_vlsit_apbcdc_mst`, `m_vlsit_apbcdc_slv` and the synchronizer path; no port or parameter rename was requested | Preserve every port, parameter, child module, instance, and connection; this is an identity/file-path change only |

The figures in `figures/` contain no old top-module identifier. The prototype under `waveforms/proto/` is explicitly documented as historical/throw-away and is not part of the delivered RTL filelist; its similarly named module and testbench are excluded from this rename. Existing simulation waveform artifacts will not be overwritten.

## 3. Affected files

| File | Planned edit | Reason |
|---|---|---|
| `rtl/m_vlsit_apbcdc_top.sv` -> `rtl/m_vlsit_async_apb_bridge.sv` | Rename file and module declaration only | VLSIT HIE-01 requires the source filename to match the module name |
| `rtl/filelist.f` | Update top comment and source filename | Keep the design compile list valid |
| `lint/filelist_lint.f` | Update top source filename | Keep the lint source list valid |
| `verification/tb_apbcdc.sv` | Update top-module comment and instance type; keep ports and test behavior unchanged | Compile the existing testbench against the renamed top |
| `verification/vlsit_run_sim.py` | Update the top source filename in `RTL` | Make the documented verification runner compile the new file |
| `constraints/m_vlsit_apbcdc_top.sdc` -> `constraints/m_vlsit_async_apb_bridge.sdc` | Rename file and update its header/source comments; keep all constraints unchanged | Keep the top-related constraint filename and documentation consistent |
| `constraints/check_sdc.py` | Update the SDC filename in its docstring and both source calls | Keep the local SDC checker operational |
| `AsyncAPBBridge_Design_Specification.md` | Replace old production top references; update the SDC path; record that the designer confirmed the top name while leaving the other DEC-015 names unconfirmed | Keep the specification and traceability aligned with implementation |
| `rtl_change_review.md` | This review and, after implementation, the final validation record | Preserve the approved scope and evidence |

No block-diagram source or rendered figure needs a change because the figures do not label the old module name.

## 4. Design choice

| Strategy | Functional coverage | Change size | Interface/backward compatibility | Complexity | Risk |
|---|---|---|---|---|---|
| Rename the production top and its direct metadata/integration references (selected) | Full requested rename; no behavior change | One RTL module/file identity plus direct references | Port-level interface stays the same; external SoC instantiations must change the module type, and external scripts sourcing the old SDC path must change | Low | Low within this repository; external integrations must be updated |

An old-name compatibility wrapper is excluded because it would add another RTL module and preserve a second top-level identity that the user did not request.

## 5. Minimality and preservation

Only the production top identifier, its matching filename, directly dependent source paths, and exact specification references will change. Child modules, instance names, ports, parameters, behavior, constraints, waveform content, and historical prototype sources remain unchanged. The pre-existing modification to the specification will be preserved by targeted substitutions rather than rewriting the document.

## 6. Assumptions, risks, and open items

- The requested rename applies to the delivered production RTL top, not the separate historical prototype under `waveforms/proto/`.
- Existing SoC RTL that instantiates `m_vlsit_apbcdc_top` must be updated to instantiate `m_vlsit_async_apb_bridge`; the port map is unchanged.
- External constraint scripts that refer to `m_vlsit_apbcdc_top.sdc` must use `m_vlsit_async_apb_bridge.sdc`.
- Existing generated waveform evidence is retained as historical output. The approved quick regression will compile and test the renamed production top into a new output directory.
- No behavior or specification gap is introduced by a symbol rename.

## 7. Validation plan

After approval, verify Python, capture the task-start RTL snapshot, and record baseline rule/lint findings before editing. Then run the corresponding checks on the renamed design.

```powershell
& 'C:/Users/PC/AppData/Local/Programs/Python/Python312/python.exe' --version
& 'C:/Users/PC/AppData/Local/Programs/Python/Python312/python.exe' 'C:/Users/PC/.codex/skills/vlsit-rtl-spec-change-implementer/scripts/vlsit_rtl_change_metrics.py' snapshot 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/rtl' 'C:/HQuan/rtl_snapshots/apbcdc_top_rename_20261026'
```

Baseline commands:

```powershell
& 'C:/Users/PC/AppData/Local/Programs/Python/Python312/python.exe' 'C:/Users/PC/.codex/skills/vlsit-rtl-generator/scripts/vlsit_rtl_check.py' check 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/rtl' --report 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/sanity/module_rename_20261026/baseline_rule_report.md'
& 'C:/Users/PC/AppData/Local/Programs/Python/Python312/python.exe' 'C:/Users/PC/.codex/skills/vlsit-rtl-generator/scripts/vlsit_lint_rtl.py' lint 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/lint/filelist_lint.f' --top m_vlsit_apbcdc_top --tool verilator --log 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/sanity/module_rename_20261026/baseline_verilator.log'
& 'C:/Users/PC/AppData/Local/Programs/Python/Python312/python.exe' 'C:/Users/PC/.codex/skills/vlsit-rtl-generator/scripts/vlsit_lint_rtl.py' lint 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/lint/filelist_lint.f' --top m_vlsit_apbcdc_top --tool slang --log 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/sanity/module_rename_20261026/baseline_slang.log'
```

Post-change commands:

```powershell
& 'C:/Users/PC/AppData/Local/Programs/Python/Python312/python.exe' 'C:/Users/PC/.codex/skills/vlsit-rtl-generator/scripts/vlsit_rtl_check.py' check 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/rtl' --report 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/sanity/module_rename_20261026/final_rule_report.md'
& 'C:/Users/PC/AppData/Local/Programs/Python/Python312/python.exe' 'C:/Users/PC/.codex/skills/vlsit-rtl-generator/scripts/vlsit_lint_rtl.py' lint 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/lint/filelist_lint.f' --top m_vlsit_async_apb_bridge --tool verilator --log 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/sanity/module_rename_20261026/final_verilator.log'
& 'C:/Users/PC/AppData/Local/Programs/Python/Python312/python.exe' 'C:/Users/PC/.codex/skills/vlsit-rtl-generator/scripts/vlsit_lint_rtl.py' lint 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/lint/filelist_lint.f' --top m_vlsit_async_apb_bridge --tool slang --log 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/sanity/module_rename_20261026/final_slang.log'
& 'C:/Users/PC/AppData/Local/Programs/Python/Python312/python.exe' 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/constraints/check_sdc.py'
& 'C:/Users/PC/AppData/Local/Programs/Python/Python312/python.exe' 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/verification/vlsit_run_sim.py' quick --out 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/verification/module_rename_20261026'
& 'C:/Users/PC/AppData/Local/Programs/Python/Python312/python.exe' 'C:/Users/PC/.codex/skills/vlsit-rtl-spec-change-implementer/scripts/vlsit_rtl_change_metrics.py' compare 'C:/HQuan/rtl_snapshots/apbcdc_top_rename_20261026' 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/004_AsyncAPBBridge/rtl'
```

Expected evidence: no new rule-check or lint errors; the APB CDC quick regression passes all synthesis and metastability runs; the SDC checker passes; no old top symbol remains in production RTL, filelists, runner, testbench, constraints, or specification; the metric reports the RTL path/symbol change against the task-start snapshot.

## 8. Approval status

Plan version 1 was approved by the designer and implemented. The production top and all planned direct references were updated.

### Requirement-to-code traceability

- Top symbol and filename: rtl/m_vlsit_async_apb_bridge.sv declares m_vlsit_async_apb_bridge; the old production source path is absent.
- Compile integration: rtl/filelist.f, lint/filelist_lint.f, verification/tb_apbcdc.sv and verification/vlsit_run_sim.py refer to the new top/file.
- Constraints: constraints/m_vlsit_async_apb_bridge.sdc and constraints/check_sdc.py refer to the new SDC name; constraint commands and budgets are unchanged.
- Specification: all production top references and the SDC path in AsyncAPBBridge_Design_Specification.md use the new name. DEC-015 records only the top name as designer-confirmed; other names in that decision remain unconfirmed.
- The prototype under waveforms/proto/ and existing waveform evidence were intentionally retained as historical outputs.

### Validation results

- Python prerequisite: Python 3.12.10.
- Baseline and final RTL rule checks: PASS, 0 errors and the same 2 HIE-02 warnings in m_vlsit_apbcdc_mst and m_vlsit_apbcdc_slv.
- Baseline and final Verilator lint: PASS, 0 errors and the same 4 unused APB5 user-input warnings.
- Baseline and final slang lint: PASS, 0 errors and 0 warnings.
- SDC checker: PASS, exit code 0; 35 stub commands applied, all five max-delay budgets matched the expected values, and the expected N_SYNC=0 rejection was observed. This is not sign-off-tool STA.
- Quick CDC regression: INCOMPLETE. Icarus Verilog 14.0-devel emitted a compile failure at unchanged testbench line 274: “sorry: constant selects in always_* processes are not fully supported” for the indexed c_err array inside always_comb. The 64-run matrix did not finish. Three completed logs in verification/module_rename_20261026/logs pass their assertion and RESULT checks; they do not replace the incomplete matrix. Testbench logic was not changed to work around the simulator.
- Production-reference scan: no old top symbol remains in the RTL, filelists, testbench, runner, constraints or specification. The historical prototype is excluded by design.

### RTL code-change metric

- Baseline: 512 nonblank, non-comment RTL lines across the task-start RTL tree.
- Added: 129 lines.
- Deleted: 129 lines.
- Changed RTL file: m_vlsit_apbcdc_top.sv renamed to m_vlsit_async_apb_bridge.sv.
- Percentage: (129 + 129) / 512 x 100 = 50.39%. The metric counts the file rename as removal of one source and addition of another; source comparison confirms only the module identifier changed in the renamed RTL body.

### Remaining risks

- SoC instantiations using m_vlsit_apbcdc_top and external scripts using the old SDC filename need migration.
- The full quick regression should be rerun after selecting a simulator/tool setup that supports the existing testbench construct at line 274. No RTL behavior issue was observed by rule check, lint or SDC checks.
- No synthesis, formal verification or sign-off STA was run.

The requested module rename, specification update and design integration updates are complete; the quick simulation matrix remains unverified because the current Icarus version cannot compile the testbench consistently.