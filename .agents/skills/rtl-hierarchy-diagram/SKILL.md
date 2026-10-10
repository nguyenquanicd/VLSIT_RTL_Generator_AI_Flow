---
name: rtl-hierarchy-diagram
description: Analyze Verilog, SystemVerilog, or VHDL RTL from a user-supplied source directory and create exactly two source-grounded artifacts: a multi-page draw.io hierarchy/interface diagram and a Markdown design analysis covering functions, interfaces, registers, implementation status, tradeoffs, and potential bugs.
---

# RTL Hierarchy Diagram and Analysis

Analyze an existing RTL design and create exactly two deliverables: one editable diagrams.net file and one Markdown analysis report. Do not modify RTL source files.

## Token-efficient artifact reads

Run `python scripts/prepare_skill_context.py --phase rtl-hierarchy-diagram --root <rtl-source-root>` before selecting files. Summarize large logs with `python scripts/summarize_eda_log.py <log-path>` and inspect cited lines in the original. These are navigation aids, not analysis evidence; avoid dumping full trees or logs.

## Required input: RTL source directory

- Require an explicit path to the RTL source directory for each analysis request. If omitted, ask: “Please provide the path to the RTL directory you want analyzed.” Wait for the answer before locating or reading RTL.
- Do not infer the RTL directory from the working directory, repository root, skill directory, output path, or an unrelated earlier request. If a path is invalid or ambiguous, clarify it before inspecting RTL.
- Treat the supplied directory as the RTL source root. Respect user-provided output paths and filenames.

## Deliverables

Create exactly these two files by default, in the requested output directory or the RTL directory when no output directory is specified:

1. rtl_hierarchy.drawio — editable multi-page hierarchy and interface diagram.
2. rtl_analysis.md — source-grounded functional and implementation analysis.

If the user specifies filenames or paths, use them. Do not overwrite an existing deliverable silently: choose a clearly numbered alternative or ask which file to replace. Do not create separate notes, images, PDFs, or auxiliary files unless the user requests them.

## RTL analysis workflow

1. Inventory relevant RTL and project context such as file lists, configuration headers, packages, and build scripts. Do not run tests, simulations, synthesis, or other executable flows unless asked; this skill performs static source analysis.
2. Identify the top module from the request or project configuration. If several candidates remain, list them and state the selection basis or ask for clarification when the choice changes the analysis materially.
3. Trace instantiations recursively. Record each instance, module, source location, parent, depth, parameters, and relevant generate condition. Distinguish unresolved/external modules and conditional hierarchy.
4. Trace important port connections through parent nets and assignments. Separate directly observed RTL facts from functional interpretation. Do not imply direct communication when signals only share a parent or pass through intermediate logic.
5. Analyze module behavior, state machines, datapaths, control logic, and interfaces deeply enough to explain the design without claiming behavior unsupported by the RTL.
6. Identify interfaces only from the port mappings and behavior. Consider APB, AXI channels, AXI-Stream, AHB, valid/ready, request/acknowledge, FIFO push/pop, interrupts, clocks/resets, and internal control/status paths. Name a standard protocol only when its expected signals and behavior provide evidence; otherwise describe it as a custom or partial interface. Record endpoints, direction, key signals, and any missing or unconnected signals.
7. Find configuration and status registers in RTL, including address decode, read/write behavior, reset values, fields, side effects, and status sources. Do not assume a register map from names alone. If addresses or access properties cannot be established, mark them unknown and explain why.
8. Identify implementation state, such as implemented, partially implemented, tied-off, stubbed, conditionally compiled, or external/unresolved, with source evidence. This describes what the inspected RTL implements; it is not a product maturity or verification claim.
9. Derive advantages, disadvantages, and potential bugs from concrete RTL evidence. For every potential bug, report the source location, triggering condition, likely effect, and confidence. Clearly label hypotheses as potential risks, not confirmed defects. If none are found, say that the static review found no specific candidate and does not prove the RTL bug-free.

## Markdown report requirements

The report must be concise but detailed enough to review and must include these sections:

1. Design summary and analysis scope: RTL root, selected top, inspected files, assumptions, and limitations.
2. Functions and features: top-level purpose and the behavior of significant modules/features.
3. Main interfaces and relationships: a table of endpoints, protocol/interface, direction, key signals, functional role, and source evidence. Include handshake, interrupt, clock/reset, and internal links when relevant.
4. Configuration and status registers: a table with register/name, address, access, reset value, fields, behavior/side effects, source evidence, and unknowns. State explicitly when no such registers were identified.
5. Implementation status: implemented, partial, tied-off, stubbed, conditional, or external items and the evidence for each.
6. Advantages: concrete architectural or implementation strengths, each tied to observed RTL.
7. Disadvantages and limitations: concrete constraints, complexity, resource/throughput limitations, incomplete behavior, or maintainability issues visible from RTL.
8. Potential bugs and risks: issue, evidence/location, trigger, effect, and confidence. Distinguish confirmed source facts from inferred consequences; do not present unverified hypotheses as confirmed bugs.
9. Open questions and configuration-dependent behavior.

Cite evidence as relative file path and line number/range whenever practical. Use “not found in inspected RTL” for missing information rather than guessing. Keep protocol compliance, performance, safety, and verification claims within what source evidence supports.

## Draw.io structure and page order

- Use one editable multi-page .drawio XML file. Create one page per hierarchy depth, named and ordered 00_TOP, 01_LEVEL_1, 02_LEVEL_2, and so on from the top to the deepest level.
- Show only hierarchy blocks, parent-child arrows, concise interface/functional connection labels, and a compact legend when needed. Do not add descriptions, register tables, advantages/disadvantages, implementation status, bug analysis, or a Notes panel to the diagram; those belong in rtl_analysis.md.
- Label each module block with exactly two centered rows: instance name on row 1 and module name in parentheses on row 2. Example: u_fifo on row 1; (axis_fifo) on row 2. For the top block use TOP on row 1 and (top_module_name) on row 2, unless a more appropriate top instance label is specified by the user or source.
- On 00_TOP, show the top module and concise external-interface labels. On later pages show modules at that depth, immediate parent context, and their instantiation links.
- Draw hierarchy and functional links distinctly. Label important functional links with concise, source-confirmed names and directions such as APB, AXI read/write, AXI-Stream valid/ready, request/acknowledge, FIFO push/pop, or IRQ. Include only key signal names; do not draw every port or wire. Do not invent protocol compliance or direct links.
- Use solid black outlines for source-resolved modules and dashed black outlines for external/unresolved modules.

## Diagram visual requirements

- Use only black and white: white canvas and block fills, black outlines, text, and connectors. Do not use gray, gradients, shadows, or colored accents.
- Set all visible text to 18 pt, including block labels, interface labels, page titles, and legend.
- Use two-line block labels with enough width and height for the longer of the instance/module names. Keep sibling blocks close with consistent compact gaps; preserve clear boundaries and balanced character-to-block proportions. Align hierarchy levels and center parents over children where practical.
- Use balanced margins and simple connector routing. Avoid crossings, decorative elements, excessive empty space, clipping, overlap, and crowding. Expand the page to fit instead of reducing font size.

## Final checks and response

- Confirm the two deliverables are present and that no additional artifact was created by this skill.
- Check the draw.io XML is well formed, tabs are in top-to-deep order, blocks use the required two-line labels, and interface labels agree with traced RTL.
- Check the Markdown contains every required section, evidence is traceable, and register/status/bug claims distinguish facts from inference.
- If a preview can be rendered, inspect text fit, clipping, overlap, connectors, spacing, and page order. State if visual inspection was unavailable.
- Provide links to both files and a brief summary of the selected top, interfaces, register findings, implementation status, and the highest-priority potential risks or unresolved questions.

## RTL rule source

If the user requests a coding-rule compliance review, use their supplied RTL rule file; otherwise read `spec_template/VLSIT_RTL_Design_Rule.md` from the repository root. Do not substitute a historical rule under `Result/`. Keep any compliance observations source-grounded in `rtl_analysis.md`; this static-analysis skill does not modify RTL or add a third deliverable.

## Reusable skill improvement

At completion, assess whether observed issues justify a high-impact improvement across designs. Follow `.agents/skill_maintenance.md` and `scripts/propose_skill_update.py`; present a qualifying proposal and ask approval for the exact change. Never edit this skill or its support files without explicit user confirmation. If none qualifies, say so briefly.

