# RTL Change Review: APB2TLUL Bridge Rule-Check Repair

**Plan version:** 1  
**Status:** Approved and implemented; validation passed  
**Target:** `common_rtl/008_APB2TLUL_Bridge`

## 1. Objective and baseline

Resolve the six RTL rule-check errors reported in `sanity/rerun_20261026/rtl_check_report.md` while preserving the bridge behavior and hierarchy. The baseline report lists three FIL-05 alignment errors and three FIL-06 missing functional port-group comment errors.

The same report lists eight NAM-08 warnings for TL-UL protocol names (`error`, `source`, and `address`). These names match the externally defined protocol signals and are retained under the protocol-name exception in NAM-02. They are not part of this repair.

Applicable RTL source: `spec_template/VLSIT_RTL_Design_Rule.md`, especially FIL-05, FIL-06, P13, and NAM-02. The interface specification is `common_rtl/008_APB2TLUL_Bridge/APB2TLUL_Bridge_Design_Specification.md`.

## 2. Proposed minimal change

Change only ANSI port declaration order, alignment, and functional-group comments in these three files:

| RTL file | Functional port groups |
|---|---|
| `rtl/m_apb_if.sv` | Clock and reset; APB4 completer interface; TL-UL request interface; TL-UL response interface |
| `rtl/m_tlul_if.sv` | Clock and reset; bridge request interface; TL-UL channel A; TL-UL channel D; bridge response interface |
| `rtl/m_apb_tlul_bridge.sv` | Clock and reset; APB4 completer interface; TL-UL channel A; TL-UL channel D |

Within each group, align the direction, type, packed width, and port-name columns as required by FIL-05. Put a short `//` comment above each functional group, separate groups with a blank line, and keep clock/reset first.

Do not add, remove, or rename ports or parameters. Do not change port widths/directions, internal RTL, assignments, instances, module count, hierarchy, file lists, verification sources, or the design specification. This is a declaration-formatting change only. The existing testbench uses named port connections. Positional instantiations outside this repository may be affected by the planned declaration reordering; integration should follow P13 and use named connections.

## 3. Strategy assessment

| Strategy | Rule coverage | Change size | Compatibility | Complexity | Risk |
|---|---|---|---|---|---|
| Reformat and group ports in place (selected) | Resolves FIL-05 and FIL-06; retains justified NAM-08 protocol-name warnings | Three module headers only | Signal API is unchanged; positional instantiations can depend on order | Low | Low, provided integrations use named connections |

Renaming protocol-facing signals to silence NAM-08 would conflict with preserving standard TL-UL signal names and could reduce interface clarity. It is excluded from this change.

## 4. Validation after approval

Before editing, snapshot the current RTL using:

```powershell
& 'C:/Users/PC/AppData/Local/Programs/Python/Python312/python.exe' `
  'C:/Users/PC/.codex/skills/vlsit-rtl-spec-change-implementer/scripts/vlsit_rtl_change_metrics.py' `
  snapshot 'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/008_APB2TLUL_Bridge/rtl' `
  'C:/HQuan/rtl_snapshots/apb_tlul_port_rule_baseline_20261026'
```

After the approved edit, run the IP's single Makefile flow with the skill-script path corrected for this checkout and use isolated output directories:

```powershell
& 'C:/Users/PC/Tools/msys64/usr/bin/make.exe' all `
  'SKILL=../../../VLSIT_CODEX_CLAUDE_SKILLS/.claude/skills/vlsit-rtl-generator/scripts' `
  'SANITY=sanity/rule_fix_20261026' `
  'BUILD=build/rule_fix_20261026' `
  'PYTHON=C:/Users/PC/AppData/Local/Programs/Python/Python312/python.exe' `
  'OSSCAD=C:/Tools/oss-cad-suite'
```

Then compute the change metric:

```powershell
& 'C:/Users/PC/AppData/Local/Programs/Python/Python312/python.exe' `
  'C:/Users/PC/.codex/skills/vlsit-rtl-spec-change-implementer/scripts/vlsit_rtl_change_metrics.py' `
  compare 'C:/HQuan/rtl_snapshots/apb_tlul_port_rule_baseline_20261026' `
  'C:/HQuan/102_MyGithub/VLSIT_RTL_Generator_AI_Model/common_rtl/008_APB2TLUL_Bridge/rtl'
```

Execution results:

- Approval: explicit APPROVE plan v1 received.
- RTL rule check: PASS, 0 errors and 8 NAM-08 warnings. FIL-05 and FIL-06 are clean.
- Verilator lint: PASS, 0 errors and 5 unused-input warnings (i_apb_pprot, i_tlul_d_param, i_tlul_d_size, i_tlul_d_sink, i_tlul_d_user).
- slang lint: PASS, 0 errors and 0 warnings.
- Default simulation: PASS, 440 TL-UL requests; 36 protocol assertions, 0 failures, 0 unexercised.
- Narrow-parameter simulation: PASS, 440 TL-UL requests; 36 protocol assertions, 0 failures, 0 unexercised.
- Change metric: 340 baseline RTL code lines; 6 added and 6 deleted, 3.53%. This metric counts changed port-list lines; comparison confirms parameter declarations and module bodies are unchanged and all port declarations are preserved.
- Logs and rule report: sanity/rule_fix_20261026/.

Note: the Makefile's default `SKILL` path points to a different checkout. The command-line override above selects the existing skill scripts and does not modify the Makefile.

## 5. Approval and completion

Plan version 1 was approved and implemented. The requested rule-check repair is complete.
