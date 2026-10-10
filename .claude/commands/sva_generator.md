# Phase 3b: SVA Generator — /sva_generator

Generate interface-level SystemVerilog Assertions from the approved verification contract. Gate 3b is the user's property review.

## Independence boundary

Require approved schemas/verification_contract.json and matching specification/configuration revisions. Read the approved contract, golden specification, exact applicable protocol-standard clauses, and recorded user decisions. Do not read RTL to infer ports, hierarchy, state, encodings, or expected behavior. Historical RV32IM examples are illustrative only. Generate no RTL bind files.

## Procedure

1. Map every applicable REQ-ID to at least one property or explain a source-based exception. Include reset, legal/illegal transactions, timing bounds, and recovery behavior where the contract specifies them.
2. For each assertion, place a concise natural-language // NL: explanation immediately above the property and a REQ-ID reference. Guard simulation-only assertions with SYNTHESIS conditionals as needed.
3. Derive an interface checker from contract-level signals. Create src/sva/filelist_sva.f in compile order. Compile against src/verification/contract_if.sv or the contract-derived shell. This proves syntax/elaboration only, never DUT behavior.
4. Add a documented sva-compile target to the single design-root Makefile. Run it when a compatible compiler is available, capture versions, logs, and exit status, and repair compilation errors before review.
5. Present each property and its expected behavior, REQ-ID mapping, uncheckable requirements, and compile status. Use .agents/skills/decision_prompt_standard.md for Gate 3b review. Record approval in schemas/rtm.json only after the user accepts the reviewed properties.

At DUT integration, inspect RTL only for adapter compatibility. A mismatch is an integration failure; do not change the oracle or assertions to match the implementation.
