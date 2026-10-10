# Phase 0: Specification Writer — /spec_writer

Create a reviewable hardware IP specification from the user's design description. The approved specification is the golden source for both RTL and verification.

## Inputs and decisions

1. Inspect the user's description and existing specification files. Ask only for missing facts that affect behavior or interface: IP purpose, ports and protocols, clocks and resets, parameters and legal values, functional behavior, timing, errors, and optional features.
2. For each user decision, follow .agents/skills/decision_prompt_standard.md. Explain terms, supported options, effects, a concrete example, and a reasoned recommendation. Do not invent missing requirements.
3. Separate normative requirements from assumptions, examples, implementation suggestions, and unresolved decisions. Record each requirement's source. Identify the exact revision and errata of any applicable protocol standard.

## Output and review

Write spec.md or the user-requested path. Include overview, scope, features, parameter table, interface and protocol table, clock/reset behavior, functional behavior, timing and latency, error handling, register map, constraints, and open questions where applicable. Define externally observable behavior precisely enough for an RTL-independent verification oracle.

Review the draft with the user, apply corrections, and obtain explicit approval before Gate 1 parsing. Report the path and unresolved items. Do not create RTL, SVA, or a testbench in this phase.
