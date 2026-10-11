---
name: source-command-verification-contract
description: "Create and review an RTL-independent verification contract from an approved specification, configuration, and exact protocol-standard revisions."
---

# source-command-verification-contract

Use this skill after Gate 2 and before RTL generation. It establishes the verification interface and behavioral oracle without reading generated RTL.

For an existing design root, run `python scripts/prepare_skill_context.py --phase source-command-verification-contract --root <design-root>` before selecting artifacts. Treat its output as an index; inspect the specification, approved configuration, and selected standard sources directly.

## Inputs and independence boundary

- Read only `schemas/structured_spec.json`, approved `schemas/final_config.json`, the user-provided design specification, selected normative standards and errata, and recorded user decisions.
- Do not read generated RTL, RTL file lists, synthesis reports, RTL rules, or historical `Result/` RTL to infer ports, behavior, timing, protocol rules, test intent, assertion intent, or coverage goals.
- Use the exact standard identifier, revision, profile, errata, and applicable clause for each protocol requirement. If these are missing, ask the user to select or supply the standard source using `.agents/skills/decision_prompt_standard.md`; explain choices, trade-offs, example, and recommendation. Do not use an unverified “latest” revision.
- If the specification does not define an interface signal, width, clock/reset, or externally observable behavior needed for checking, record the gap and block contract approval for affected requirements. Do not fill it from RTL.

## Outputs

Create `schemas/verification_contract.json` conforming to `.claude/skills/rtl-flow-maintainer/schemas/verification_contract_schema.json`. It must define:

- Golden-source identities and revisions, including spec and protocol-standard clauses.
- The contract-level interface: logical signal name, direction, width expression/value, clock/reset role, and applicable configuration. These are specification-facing names, not names copied from RTL.
- For each REQ-ID: source clauses, preconditions, legal stimulus, externally observable outputs, expected behavior, timing bounds, error/recovery cases, and planned TC-ID, property ID, and functional coverage point.
- Unresolved questions, assumptions, exclusions, and approval status.

Generate the verification-only interface shell at `src/verification/contract_if.sv` and its file list at `src/verification/filelist_contract.f` from the contract-level signals. The shell supports syntax/elaboration checks only and must never report a functional DUT pass.

The contract must not require RTL module names, internal states, enum encodings, or implementation hierarchy. RTL module mapping in `structured_spec.json` is for the RTL Generator only.

## Procedure and Gate 3a

1. Verify Gate 1 and Gate 2 approvals and confirm the contract's specification/configuration revisions match them.
2. Build the interface and per-requirement oracle from the approved specification and exact standards. Keep expected results independent from any RTL implementation.
3. Review each protocol-specific requirement for standard-clause traceability and each requirement for a checkable observable result. Mark `not_applicable` only with a source-based reason.
4. Present ambiguities and assumptions with concrete options, effects, examples, and a best-supported recommendation before asking the user to resolve them.
5. Show a concise contract summary: source baseline, interface signals, REQ-ID coverage by planned tests/properties, open gaps, and risks. Recommend approval only when no unresolved issue affects expected behavior.
6. On user approval, write the contract with `approval.status: "approved"`, approver decision, and timestamp. Otherwise keep it `draft` and do not unlock SVA/testbench generation.

The contract review (Gate 3a) occurs before RTL generation in the full flow. This skill may be run independently; if RTL already exists, ignore it completely.

## Downstream contract

- SVA and testbench generation consume the approved contract and golden sources only.
- Initialize or reuse one design-root Makefile before either branch runs; each branch extends its targets. The Makefile is shared infrastructure, not an RTL output dependency.
- Verification sources may compile against a contract-derived interface shell. Shell compilation proves syntax/elaboration only, never DUT behavior.
- At DUT integration, an adapter maps the contract interface to the generated RTL. Inspect RTL only for interface conformance and adapter connectivity. Missing or mismatched ports/parameters are integration failures; do not revise the contract, tests, assertions, or oracle to accommodate the RTL.
- Keep one documented design-root Makefile for all EDA and verification commands. Add or extend targets; never create a second Makefile or hide EDA invocation in runners.

