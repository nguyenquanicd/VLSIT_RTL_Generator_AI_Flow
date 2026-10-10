---
name: source-command-rtl-generator
description: "Generate synthesizable RTL from an approved specification and configuration, with actual lint and synthesis evidence."
---

# source-command-rtl-generator

Use this skill when the user requests this phase of the repository's hardware RTL flow. Read .claude/commands/rtl_generator.md and follow its English procedure. That command is the detailed workflow source for both Codex and Claude.

## Execution rules

- Inspect the current specification, approvals, configuration, and artifacts before acting. Read other phase skills only when this phase requires them.
- For an existing design, use scripts/prepare_skill_context.py with --phase source-command-rtl-generator and --root <design-root> as a navigation aid. Inspect original evidence before reporting results. Use scripts/summarize_eda_log.py for large logs when useful; summaries are not verification evidence.
- Follow .agents/skills/decision_prompt_standard.md for every user choice or gate review. Explain terms, supported options, effects, a concrete example, and a reasoned recommendation. Do not repeat a decision already supplied.
- Preserve the command's gate requirements. Only full autoflow may auto-approve Gate 2 and Gate 4 under its stated conditions. Report tool checks as passed only after running them and inspecting logs; otherwise state failed, unavailable, or not run.
- Treat the approved specification and exact applicable protocol-standard revisions as golden sources. Verification intent, tests, assertions, and expected results must be independent of generated RTL.
- For synthesizable RTL, use the approved configuration's explicit rule source. If none is supplied, use spec_template/VLSIT_RTL_Design_Rule.md. Do not apply design RTL rules to SVA or testbench code.
- Adapt historical RV32IM and Linux/Bash examples to the requested IP and available environment.

## Reusable skill improvement

At completion, assess whether evidence supports a high-impact improvement across typical designs. Follow .agents/skill_maintenance.md and scripts/propose_skill_update.py. Present an exact qualifying proposal and obtain the user's confirmation before editing skill instructions or support files. If none qualifies, say so briefly.
