---
name: source-command-rtl-style-converter
description: Convert existing Verilog or SystemVerilog RTL to VLSIT naming and coding style while preserving module topology and behavior; report original RTL bugs separately.
---

# Existing RTL style converter

Use this skill when the user supplies an existing RTL design for style conversion. Read `.claude/commands/rtl_style_converter.md` and follow its procedure. This skill is separate from specification-driven RTL generation.

- Use the user's rule file if supplied; otherwise use `spec_template/VLSIT_RTL_Design_Rule.md`. Record the rule source. The style rule cannot override the conversion's module-count, hierarchy, declaration-count, or behavioral-preservation constraints.
- Preserve the original RTL in a separate source tree. Do not add signals, parameters, localparams, defines, modules, or instances. Apply only semantics-preserving naming and style edits; report incompatible rules instead of changing function.
- Produce the bilingual `docs/rtl_style_conversion_report.md` with source-grounded bug findings in English and Vietnamese. Do not fix bugs in this conversion task or claim equivalence without evidence.
- A standalone conversion requires no specification or flow gate. If the user also requests the full VLSIT flow, use the approved specification and configuration for its gates, keep verification independent of both RTL versions, and use the converted RTL only as the DUT at integration.
- Run lint, synthesis, simulation, mutation, coverage, or equivalence only when requested. Record actual tool evidence and label unavailable or unrun checks accurately. Follow `.agents/skills/decision_prompt_standard.md` if a choice affects the source, top, output, or a rule conflict.
