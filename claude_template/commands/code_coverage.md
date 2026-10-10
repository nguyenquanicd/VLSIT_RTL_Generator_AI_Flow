# Phase 5b · RTL Code Coverage — /code_coverage

## User decisions

Follow `.agents/skills/decision_prompt_standard.md` for every choice. Show the measured baseline before asking the user to set a target. Explain the metric, denominator, scope, uncovered points, valid options, trade-offs, an example, and the best-supported recommendation. Do not treat an example percentage as an approved target.

Use this command after the approved baseline simulation and before Gate 5 when the user wants a code-coverage measurement or target.

## Evidence and scope

- Read current `work/sim_results.json` and logs when called inside Phase 5, plus `schemas/verification_report.json`, `schemas/selected_testplan.json`, approved `schemas/verification_contract.json`, `schemas/final_config.json`, `schemas/structured_spec.json`, and `schemas/rtm.json`. Prefer the current run over an older report. Reuse an existing coverage result only if RTL/configuration, test plan, simulator, and coverage settings match. Requirement coverage and mutation score are not code coverage.
- Measure the elaborated synthesizable DUT RTL hierarchy. Exclude testbench and SVA from the DUT code-coverage denominator. State per-instance or merged scope, metric, covered/coverable denominator, exclusions, simulator/version, and evidence paths. Do not combine unlike metrics into one percentage.
- Offer only metrics supported by the installed simulator, for example line/statement, branch, condition/expression, toggle, or FSM coverage. Recommend line/statement coverage as the easiest first metric to interpret, but do not invent a threshold. If measurement is unsupported, report `N/A` and ask whether to use a supported simulator or proceed without a target.
- If the preceding regression was not coverage-instrumented, rerun its unchanged approved test plan with instrumentation before asking for the target. Never estimate a baseline.

## One Makefile for all test runs

- Keep one canonical `<design-root>/Makefile` for testbench compile, individual tests, regression, coverage instrumentation/merge/report, and reruns for coverage closure. Create it if missing; otherwise extend the existing file. Put every tool invocation in its documented recipe; do not run equivalent commands directly or create per-step runner scripts.
- Provide a `help` target documenting targets, required variables, tool/version assumptions, inputs, and outputs. Provide at least `tb-compile`, `test`, `regression`, `coverage-baseline`, `coverage-regression`, and `coverage-report`, and expose `COVERAGE_MAX_ROUNDS` (default 5). `make -n <target>` must display the commands to be executed.
- Run targets from the design root and record the target, variables, exit status, log/report paths, and tool versions. Spell out compiler, simulator, coverage-instrumentation, merge, and report-tool invocations in the Makefile recipe; do not hide EDA execution inside helpers or runner scripts. A visible helper may process report data only and must be kept in the project.

## Baseline, target, and closure

1. Reuse or run the approved baseline regression through the Makefile. Save raw coverage data and logs under `work/coverage/`.
2. Show the measured percentage, metric, numerator/denominator, scope, simulator/version, uncovered-point summary, and functional test result before asking for a target. If the baseline regression has any functional failure, stop closure and diagnose it before asking for a target. Explain that line/statement coverage measures eligible DUT code points reached by simulation; it differs from REQ-ID coverage, functional coverage, and mutation score.
3. Ask for a target from 0–100% for the measured metric, or let the user continue without a target. If the user wants another supported metric, measure and show its baseline first; never translate percentages between metrics. Example: 60% means at least 60% of the declared coverable points in that metric and scope. Recommend line/statement as the easiest initial metric to interpret. Recommend a threshold only when project requirements or evidence support it; there is no universal threshold. If the user already supplied the target and metric, show the baseline and continue without asking them to repeat it.
4. For uncovered points, RTL may be used only to locate structural gaps. Derive legal stimulus and expected behavior from the approved verification contract and its specification/configuration/exact-standard sources. Never use RTL behavior as the golden result. If no contract-backed test can cover a point, request clarification or mark it unreachable/excluded only with evidence and user review.
5. Generate only tests for specified legal behavior. Save each as a persistent SystemVerilog file in `src/tb/tests/`, with unique TC-ID, REQ-ID/standard-clause trace, deterministic seed where applicable, and a failing check. Preserve the Gate 4-approved `test_cases` array; append closure tests under `coverage_closure.test_cases` in `schemas/selected_testplan.json`, including the user-selected metric/target, uncovered code point, and specification clause. Add each test to `src/tb/filelist_tb.f` and register it with the testbench dispatcher so `make test TC=<TC-ID>` can select it; Makefile regression targets run both base and coverage-closure tests. Never use ephemeral or in-memory tests.
6. After each addition, compile and run the full selected suite, merge coverage, and create a report using only Makefile targets. Count a new test's coverage only after its functional checks pass. Keep each round's log and report.
7. Continue until target reached, five closure rounds, or two consecutive rounds add no coverable points. After each round, show the user persisted TC-IDs/files, specification trace, Make targets, and measured change. Do not weaken checks, change the target, suppress points, or modify RTL just to raise coverage. A functional failure is a verification failure and exits this loop for spec-based diagnosis.
8. If unmet, show the remaining gap and ask whether to revise the target, clarify missing specification, or stop with target unmet. Never report an unmet target as pass. Gate 5 remains unapproved while a selected mandatory target is unmet.

## Outputs

- Keep tests under `src/tb/tests/`, update plan and file list, and keep raw databases, per-round logs, and merged reports under `work/coverage/`.
- Update `schemas/verification_report.json` with status (`not_requested`, `not_supported`, `baseline_only`, `target_met`, or `target_unmet`), metric, baseline/final/target percentages, covered/coverable counts, scope/exclusions, simulator/version, added TC-IDs and source-file paths, iteration count, and evidence paths. Preserve functional simulation and mutation results separately.
- Report the final measured result, target status, all generated testcase paths, and the Makefile targets the user can run to reproduce compile, regression, and coverage.
