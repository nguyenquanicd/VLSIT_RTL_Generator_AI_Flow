# Specification Parser Authoring Rules

Use these rules when adapting /spec_parser for another hardware IP.

## Required sequence

1. Identify and validate the input specification.
2. Extract atomic requirements and assign unique REQ-IDs.
3. Score ambiguity and assign an appropriate sva_hint.
4. Review every requirement with needs_review=true.
5. Apply optional user edits.
6. Map each REQ-ID to affected parameters and planned RTL modules.
7. Present Gate 1 for explicit approval.

Do not skip ambiguity review because a specification looks clear at first glance. Keep unresolved behavior out of RTL and verification generation.

## Requirement granularity

Split behaviors when they can fail independently, have different controlling parameters or categories, or require separate assertions. Combine behaviors only when they share a trigger and observable outcome and the specification defines them as one atomic behavior. Do not create REQ-IDs for rationale, out-of-scope lists, comments, or illustrative waveforms.

## Ambiguity

Score 0.0–0.1 for fully specified behavior; 0.1–0.3 for a single interpretation requiring context; 0.3–0.6 for multiple plausible interpretations; and 0.6–1.0 when implementation details are missing. A score above 0.3 requires review. After three unsuccessful clarification attempts, mark needs_human_decision=true and block Gate 1 until the user decides. Never silently accept an ambiguous requirement.

## Mapping and hints

Complete requirement-to-parameter and requirement-to-module mapping before Gate 1. Map timing requirements to the responsible control block. Use property for cycle-accurate behavior, static for elaboration constraints, cover for reachability, assume for formal input constraints, and sequence for a reusable multicycle pattern. Choose a hint from the requirement's nature, not convenience.

## Gate 1 conditions

Require no pending human decisions, a module mapping for each applicable requirement, an explicit parameters_affected list (empty when none), and schema-valid output. The user must approve the reviewed artifact.

## Adapting to a new project

Replace specification section names, parameter names, planned module names, and input-validation cues with those of the new IP. Keep the seven-step sequence, ambiguity threshold, gate conditions, and schema path. Remove stale project-specific identifiers such as rv32im_ or PR_M_EXT_EN when they do not apply.

Before use, check all seven steps, source references, actual parameter/module mappings, ambiguity decisions, and conformance to `.claude/skills/rtl-flow-maintainer/schemas/structured_spec_schema.json`.
