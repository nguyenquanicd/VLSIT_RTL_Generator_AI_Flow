# Phase 5: Verification — /verification

Integrate the generated DUT, or the style-converted existing DUT selected by `/autoflow`, with the independently prepared verification branch. Run the saved tests and present evidence for Gate 5. Only the user can sign off. A style-conversion report does not establish functional correctness.

## Sources and preflight

Require approved Gate 2 configuration, Gate 3a verification contract, Gate 3b properties, and Gate 4 test plan. Confirm specification/configuration revisions and all file lists match the approved baseline. The contract and normative sources remain the oracle. RTL may be read for interface adapter connectivity, compilation, simulation, and structural or mutation analysis only.

Check the single design-root Makefile for tool-check, compile, individual-test, regression, mutation, and coverage targets. Its help target must describe tools, versions, variables, inputs, and outputs. Use make -n to inspect commands. Save logs, versions, exit codes, and all test files. Do not run hidden EDA commands.

## Execution

1. Compile the DUT, adapter, SVA, and testbench together. An interface mismatch or compile failure stops simulation. Do not alter the contract, tests, assertions, or expected outcomes to accommodate RTL.
2. Run every selected applicable TC-ID through documented Make targets. Record actual pass/fail, simulator output, REQ-ID mapping, and reproducible command. A test is passed only when its checking logic and process exit status both pass.
3. Run mutation checks where supported. Record each mutation, whether it compiled, whether the tests detected it, and the score. Do not count non-compiling mutants as detected. If unavailable, report N/A rather than pass.
4. Measure baseline code coverage when supported. If the user requests a target, invoke /code_coverage, show baseline first, ask for a numeric target, and save every added specification-based test.
5. Update schemas/rtm.json and schemas/verification_report.json with raw evidence and statuses. Keep missing, unrun, N/A, failed, and passed distinct. Apply the repository RTM schema's sign-off conditions; a per-requirement mutation score below 85% blocks that requirement's sign-off where mutation is applicable.
6. Show the Gate 5 dashboard with each REQ-ID, properties, TC results, mutation evidence, optional coverage target, unresolved gaps, and exact Make targets for reproduction. Recommend approval only when required checks pass. Record gate_5_approved=true only after explicit user sign-off.

If a tool is unavailable, state which checks were not run and how to rerun them. Do not infer a functional pass from compilation or code coverage.
