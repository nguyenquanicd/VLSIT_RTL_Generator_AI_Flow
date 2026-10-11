# Phase 3a · Verification Contract — /verification_contract

Create the reviewed verification baseline after Gate 2 and before `/rtl_generator`.

## Independence boundary

- Read the approved specification, `schemas/structured_spec.json`, approved `schemas/final_config.json`, exact selected protocol-standard revisions/errata, and recorded user decisions.
- Do not read generated RTL, RTL file lists, synthesis reports, or `Result/` RTL. Do not infer interface, expected behavior, test/property intent, or coverage goals from implementation details.
- Protocol requirements need an exact standard identifier, revision/profile, errata, and clause. If missing, ask the user to select or provide the source with analysis, choices, examples, trade-offs, and a recommendation. Do not assume “latest.”
- Missing specification-defined interface or observable behavior is an open requirement gap; report it and keep Gate 3a closed until resolved.

## Output

Create `schemas/verification_contract.json` using `.claude/skills/rtl-flow-maintainer/schemas/verification_contract_schema.json`. Include:

- Specification, configuration, standards, clauses, revisions, hashes where available, and user decisions.
- Contract-level logical interface: signal names, direction, width, clock/reset role, and approved parameter profile. Do not include RTL module names, internal states, enum encodings, or implementation hierarchy.
- Per REQ-ID: golden-source clauses, preconditions, legal stimulus, observable outputs, expected behavior, timing/error/recovery rules, and planned test, property, and functional-coverage IDs.
- Assumptions, exclusions, unresolved issues, status, and approval record.

Generate `src/verification/contract_if.sv` and `src/verification/filelist_contract.f` from the contract signals. The shell is verification-only and supports syntax/elaboration checks, never a functional DUT pass.

RTL module mapping in `structured_spec.json` is for RTL generation only and must not be used by verification generators.

## Gate 3a

Check Gate 1 and Gate 2 approvals and matching revisions. Present interface and source baseline, requirement-to-clause mapping, planned checks, open gaps, and assumptions. Explain each decision with concrete options, effects, example, and recommendation. Recommend approval only when no unresolved item can change expected behavior. On approval, set contract and approval status to `approved` with timestamp; otherwise retain `draft` and do not unlock SVA/testbench generation.

This review does not require generated RTL. Verification source compilation may use a contract-derived interface shell and proves syntax/elaboration only, never DUT behavior.

Initialize or reuse one design-root Makefile before either branch runs; each branch extends it. The shared Makefile is not an RTL output dependency.

## Integration boundary

The integration adapter maps the approved logical interface to the DUT after both branches have artifacts. RTL may be inspected only for interface conformance and connectivity. A missing/mismatched port or parameter is an integration failure; do not modify the contract, testbench, SVA, or oracle to match RTL. Keep one design-root Makefile and extend it for all EDA and verification commands.

