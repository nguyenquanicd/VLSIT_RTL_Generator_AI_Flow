# Phase 1: Specification Parser — /spec_parser

Convert an approved hardware specification into traceable, atomic requirements. Gate 1 requires explicit user approval.

## Inputs

Use the supplied specification path. Otherwise identify a likely specification file by name and content; ask for a path if none is identifiable. Check that it describes an IP interface, parameters, behavior, or timing. If suitability is uncertain, explain the evidence and ask whether to continue.

## Requirement extraction

1. Read every section. Assign unique, zero-padded REQ-IDs starting with REQ-001. Classify functional, interface, timing, and constraint requirements. Mark optional behavior explicitly.
2. Split behaviors that can fail independently or require separate checks. Do not create requirements for rationale, out-of-scope statements, or illustrative waveforms.
3. Preserve exact source references, protocol standard revisions and clauses, legal parameter values, observable effects, timing, and error cases. Record RTL module and parameter mappings separately from verification intent.
4. Score ambiguity from 0 to 1. Scores above 0.3 require user review. After three unsuccessful clarification attempts, mark needs_human_decision=true and ambiguity_score=0.35; block Gate 1 until the user resolves, retains, or removes the requirement.
5. Provide an sva_hint such as property, static, or cover where the source supports it. Do not infer an assertion from implementation details.
6. Show the requirement table, ambiguity analysis, proposed splits/merges, and mappings. Use .agents/skills/decision_prompt_standard.md for decisions and approval.

## Output and gate

Validate against `.claude/skills/rtl-flow-maintainer/schemas/structured_spec_schema.json`. Write `schemas/structured_spec.json` only with the reviewed content. Set `gate_1_approved=true` only after explicit approval; otherwise keep it false and report blockers. Do not generate RTL, SVA, or tests.
