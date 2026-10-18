# Master Orchestrator — /autoflow

Run the specification-driven RTL and verification flow from design input through final documentation. Keep RTL generation and verification generation independent until DUT integration.

## Start and resume

Accept a specification path, --describe to invoke /spec_writer, or --from <phase> to resume from validated existing artifacts. For an existing RTL implementation, also accept `--rtl-source <directory>` with a specification path; ask for the top and a separate output path if they are not clear. If no input is given, explain the applicable modes with an example and recommendation, then ask. On resume, validate upstream approvals, artifact revisions, and file integrity before skipping completed work.

## Gate sequence

1. /spec_parser creates structured requirements. Stop at Gate 1 for explicit user approval.
2. /config_ui validates parameters and style source. Full autoflow may approve Gate 2 automatically only when no unsupported choice or failed constraint remains; otherwise request approval.
3. /verification_contract builds the independent interface and oracle from the approved specification, configuration, and exact applicable protocol standards. Stop at Gate 3a for explicit approval.
4. After Gate 3a, use `/rtl_generator` for a new implementation, or `/rtl_style_converter` for an explicitly supplied existing RTL source. The converter preserves module count, hierarchy, declarations, and behavior, reports suspected original bugs separately, and may leave incompatible style rules unmet. `/sva_generator` and `/tb_generator` use the approved verification contract and golden sources. Neither verification generator may read either RTL version for expected behavior, signals, hierarchy, or coverage intent.
5. Stop at Gate 3b for user review of SVA properties. Gate 4 test-plan approval may be automatic in full autoflow only when the plan has no unresolved issue and contract-shell compilation passes.
6. Integrate the generated or converted DUT through a contract-to-RTL adapter. Treat interface mismatches as failures. `/verification` runs simulation and mutation checks; optional `/code_coverage` shows measured baseline and asks for an explicit target. Stop at Gate 5 for user sign-off. A style-conversion report is not Gate 5 evidence.
7. After Gate 5, /spec_pdf_generator builds final documentation.

## Execution discipline

Create or reuse one design-root Makefile during preflight. All lint, synthesis, contract-shell compilation, DUT compilation, test execution, regression, mutation, and coverage commands belong in documented recipes. Save every generated test case and execution log. Make help explains targets, tools, versions, inputs, and outputs; make -n shows commands.

Report progress after each phase. Never represent an unavailable, skipped, or failed check as a pass. Do not automatically sign Gate 1, Gate 3a, Gate 3b, or Gate 5. Do not proceed past unresolved technical ambiguities or revision mismatches. Use .agents/skills/decision_prompt_standard.md for every choice.
