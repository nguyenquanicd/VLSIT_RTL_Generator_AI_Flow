# Specification-Driven Verification Flow Proposal

## 1. Purpose

This proposal describes how to make the verification flow independent of generated RTL when defining expected behavior.

The specification and the selected protocol-standard revisions are the verification golden sources. Generated RTL is the design under test (DUT); it is compiled and simulated, but it must not be used to infer expected results, test scenarios, assertion intent, protocol behavior, or coverage targets.

This distinction matters: a flow that never compiles or simulates the DUT cannot verify its implementation. Independence means that the verification oracle is established without consulting the implementation and remains unchanged when the implementation changes, unless the approved specification changes.

## 2. Current Flow Dependencies to Remove

The current instructions couple verification artifacts to implementation details in several places:

- The SVA generator reads generated RTL for port names, internal states, enum encodings, and types. It also binds assertions to RTL module names.
- The testbench generator selects the top module and its ports from generated RTL.
- The verification phase searches RTL source tags to choose mutation targets.
- The RTM requires an RTL trace (rtl_traced) as a verification sign-off condition.
- The structured-spec schema records requirements and parameters, but does not provide a structured protocol-standard baseline or a reviewed verification contract.

These dependencies can cause the testbench and assertions to follow an implementation mistake. The SVA and testbench must instead follow an approved interface contract and behavioral contract derived from the golden sources.

## 3. Source-of-Truth Policy

Use these sources in order:

1. **Approved design specification**: defines product-specific behavior, configuration, timing, reset, exceptions, and supported features.
2. **Selected normative standards**: define applicable protocol requirements. Record the exact document identifier, revision, applicable clauses, errata, and selected profile.
3. **Approved configuration and user decisions**: define enabled features, legal parameter values, and resolutions to ambiguities.
4. **Verification contract**: a reviewed, machine-readable expression of the requirements above. This is the direct input to the reference model, tests, assertions, and coverage plan.
5. **Generated RTL**: the DUT only. It may be compiled, simulated, and checked for conformance to the contract. It must not be used to define the contract or expected behavior.

If the design specification conflicts with a protocol standard, or if either source leaves required behavior ambiguous, record the conflict or ambiguity and stop sign-off for the affected requirement until it is resolved. Do not silently choose behavior by inspecting RTL.

Record a standard's exact revision rather than relying on “latest.” Store document identifiers, revision, clause references, errata, source location, and a content hash where available. Keep copyrighted standards documents in their authorized source location; the project can store references and hashes instead of duplicating the documents.

## 4. Proposed Verification Artifacts

### 4.1 Golden manifest

Add a manifest such as schemas/golden_manifest.json to lock the source baseline:

- Design-specification path, revision, and SHA-256
- Standard identifier, revision, errata, clause list, source path or URL, and SHA-256 where available
- Approved configuration revision and hash
- Approval status and timestamp
- Open ambiguities and their disposition

If a golden source changes, invalidate the affected verification contract, model, tests, and sign-off evidence. Do not reuse results from a different baseline.

### 4.2 Verification contract

Add schemas/verification_contract.json, reviewed before RTL generation. It should include:

- Golden-source references and hashes
- Approved top-level interface: port names, directions, widths, clock/reset behavior, and parameter profile
- Requirement-to-source mapping, including standard clause references
- Preconditions, stimulus, observable outputs, expected behavior, and timing bounds
- Reset, error, boundary, backpressure, and recovery behavior
- Test IDs, property IDs, coverage points, and exclusions for every requirement
- Assumptions, unresolved items, and reviewer approval

Example structure:

~~~json
{
  "metadata": {
    "design_spec_revision": "1.0",
    "contract_revision": "1.0",
    "status": "approved"
  },
  "golden_sources": [
    {
      "kind": "design_spec",
      "document": "design_specification.md",
      "revision": "1.0",
      "sha256": "<digest>"
    },
    {
      "kind": "protocol_standard",
      "document": "<standard identifier>",
      "revision": "<selected revision>",
      "clauses": ["<clause reference>"],
      "sha256": "<digest>"
    }
  ],
  "interface_contract": {
    "top": "<specification-defined top interface>",
    "clock_reset": [],
    "ports": [],
    "parameters": []
  },
  "requirements": [
    {
      "req_id": "REQ-001",
      "sources": ["design_specification.md section 3.1"],
      "preconditions": [],
      "observable_behavior": "<approved expected behavior>",
      "timing": "<cycle or latency bounds>",
      "tests": ["TC-001"],
      "properties": ["AP-001"],
      "coverage_points": ["FC-001"],
      "assumptions": [],
      "status": "reviewed"
    }
  ]
}
~~~

The example is a structure proposal, not a replacement for the repository's current schema. The schema should be versioned and validated before the flow consumes this artifact.

### 4.3 Independent reference model and golden vectors

Create expected behavior from the approved specification and standard clauses. Keep the model algorithmically independent from the generated RTL where practical. For example, a protocol transaction model should express legal transaction-level behavior rather than copy the DUT's internal state machine.

Use directed golden vectors for reset, boundaries, errors, corner cases, and protocol sequencing. Add constrained-random stimulus only when the reference model can compute the expected outcome independently. Every vector and model result must trace back to one or more contract requirements.

Review the contract and representative expected vectors before running the DUT. A model generated from the same unclear prose as the RTL can share the same error; independent review and standard-derived vectors reduce that risk.

## 5. DUT Integration Without RTL-Derived Expectations

Use a stable adapter or wrapper whose interface is defined by the approved interface contract:

- The testbench connects only to the contract-defined interface.
- The adapter maps the implementation's top-level ports to that interface.
- Port or parameter mismatches are reported as DUT/interface conformance failures.
- Do not change the contract, testbench, or oracle to accommodate a generated RTL mismatch.
- Avoid hierarchical references to internal RTL signals in the primary sign-off testbench.

Separate syntax/elaboration checks from functional DUT simulation:

- **Verification-package compile:** compile the testbench, model, assertions, and contract-derived wrapper against a nonfunctional interface shell. This checks syntax and integration only. It is not a DUT pass.
- **DUT conformance and simulation:** compile the actual DUT through the adapter, check its interface against the contract, then run tests and assertions against the independent oracle.

The shell must never return passing functional results. Label its use and logs as compile-only.

## 6. Assertions, Tests, and Coverage

### Assertions

- Derive assertion intent from requirement text and standard clauses, not from RTL structure.
- Prefer checks at the specification-defined boundary: protocol handshakes, payload stability, reset behavior, response ordering, and externally visible timing.
- Use only contract-defined signals in sign-off assertions.
- If a requirement does not expose a behavior at the interface, document the limitation. Add a white-box assertion only when the approved specification explicitly defines the relevant architectural state as a requirement and the user approves the observability.
- Do not copy DUT enum encodings, FSM states, or internal names into the oracle.

### Tests

- Map every test to requirement IDs and source clauses.
- Cover normal behavior, boundaries, reset entry/release, errors, legal and illegal protocol sequences, backpressure, and recovery as applicable to the specification.
- Generate test choices from the approved configuration and protocol profile, not from implementation features discovered in RTL.
- Keep randomized seeds and inputs in the report so failures can be reproduced.

### Coverage

Measure requirement coverage, protocol-clause coverage, scenario coverage, and assertion activation. Treat code coverage as diagnostic only: it can identify unexercised implementation regions, but it cannot establish that the specification is correct or complete.

## 7. Gate and Phase Proposal

Preserve the existing gate names initially, but make each gate consume specification-derived artifacts:

1. **Golden baseline approval:** approve the design-specification revision, standards and revisions, errata, configuration, and ambiguity list.
2. **Verification-contract review:** approve the interface contract, expected behavior, requirement-to-clause mapping, reference-model plan, tests, assertions, and coverage plan. This review must not require generated RTL.
3. **Verification-source review:** review the independent model, vectors, assertions, and testbench. Compile these sources against the interface shell for syntax/elaboration only.
4. **DUT integration:** connect the generated RTL as the DUT through the adapter. Check interface compatibility. A mismatch is a failure to integrate, not a reason to revise expected behavior.
5. **Execution and sign-off:** run simulation/formal checks, record tool outputs, and sign off against requirements and standard clauses using the locked golden baseline.

The test plan and oracle should be ready before the DUT exists. Actual DUT simulation necessarily waits until the implementation is available.

## 8. RTM and Report Changes

The RTM should trace verification to the golden sources, not require an RTL source tag. Replace rtl_traced as a sign-off prerequisite with evidence fields such as:

- spec_traced: requirement maps to an approved specification section
- standard_traced: applicable standard clause and revision are recorded, or explicitly marked not applicable
- oracle_reviewed: expected behavior is reviewed against the contract
- property_traced: reviewed assertions map to the requirement
- test_traced: selected tests map to the requirement
- coverage_status: required scenarios and clauses are exercised
- sim_status: result from the simulator against the DUT
- baseline_hashes: golden-source and verification-artifact hashes used for this run

Keep implementation traceability as a separate optional audit field. It can help debug implementation coverage, but it must not affect what the golden expected result is.

Mutation testing may remain as a supplemental test-quality metric. Do not use a mutation score as a substitute for requirement-based checks, and do not treat unavailable mutation results as evidence of correctness. Mutation targets may be derived from implementation only for this supplemental analysis; expected outputs must still come from the independent oracle.

## 9. Reproducibility and Change Control

For every run, record:

- Golden manifest and verification-contract hashes
- Specification revision, standard revisions, errata, profile, and configuration
- Reference-model, testbench, assertion, and adapter revisions
- DUT source revision or artifact hash
- Simulator/formal tool versions, options, random seeds, logs, and per-test result

If only the DUT changes, the golden contract and expected results remain fixed. If a requirement or standard baseline changes, create a new reviewed contract revision and rerun the affected verification.

## 10. Implementation Roadmap

### Priority 1 — Stop deriving behavior from RTL

Update both the Codex skills and Claude commands for SVA generation, testbench generation, and verification. State explicitly that RTL may be used only as the DUT for compile, interface-conformance, simulation, and supplemental mutation analysis. Remove instructions to read RTL for expected behavior, ports, states, and enum encodings.

### Priority 2 — Add golden-source metadata and contract

Extend the structured-spec and report schemas, or add versioned schemas for the golden manifest and verification contract. Require exact standard revisions and clause references for protocol-specific requirements.

### Priority 3 — Decouple verification planning from DUT generation

Generate and review the interface contract, reference-model plan, tests, assertions, and coverage before RTL generation. Add an adapter based on the approved interface contract.

### Priority 4 — Migrate RTM sign-off

Remove RTL-tag presence from verification eligibility. Make requirement/spec/standard traceability and actual DUT results the sign-off evidence. Preserve RTL mapping separately for implementation audit.

### Priority 5 — Validate the revised flow

Run a representative design through the revised gates. Confirm that:

- The verification contract can be approved with no generated RTL present.
- Verification sources compile against the interface shell without being marked as a DUT pass.
- The testbench and oracle are unchanged when only RTL implementation details change.
- A DUT interface mismatch is reported without changing the contract or expected results.
- Every reported pass, failure, and coverage item traces to a reviewed requirement or standard clause.

## 11. Acceptance Criteria

The flow meets the independence goal when:

1. Expected outputs and protocol checks can be reviewed and frozen before RTL generation.
2. No verification generator reads generated RTL to create expected behavior, vectors, coverage, or assertion intent.
3. The testbench uses a specification-defined interface contract and adapter.
4. RTL changes alone do not alter the golden manifest, contract, reference model, or expected results.
5. Every sign-off result traces to an approved specification requirement or exact standard clause.
6. Interface mismatch, ambiguity, missing standard revision, or unreviewed assumptions block sign-off rather than silently changing the oracle.
