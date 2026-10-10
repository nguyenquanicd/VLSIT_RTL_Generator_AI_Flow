---
name: source-command-code-coverage
description: "Measure RTL code coverage after baseline verification, let the user choose an explicit target, and close reachable coverage gaps with saved specification-based tests."
---

# source-command-code-coverage

Follow `.agents/skills/decision_prompt_standard.md` for every user decision. Use this skill after the verification baseline and before Gate 5 when the user wants an RTL code-coverage measurement or target.

For an existing design, first run `python scripts/prepare_skill_context.py --phase source-command-code-coverage --root <design-root>` to locate the contract, saved tests, RTL, and baseline coverage artifacts without dumping the full tree. Summarize large EDA logs with `python scripts/summarize_eda_log.py <log-path>` and inspect cited lines in the original; summaries are navigation aids, not evidence.

## Evidence and scope

- Read the current `work/sim_results.json` and logs when called inside Phase 5, plus `schemas/verification_report.json`, `schemas/selected_testplan.json`, approved `schemas/verification_contract.json`, `schemas/final_config.json`, `schemas/structured_spec.json`, and `schemas/rtm.json`. Prefer the current run's baseline over a prior report. Reuse a prior coverage result only when the RTL/configuration, test plan, simulator, and coverage settings match this run. A requirement-coverage percentage or mutation score is not code coverage.
- Measure the elaborated synthesizable DUT RTL hierarchy. Exclude testbench and SVA code from the DUT code-coverage denominator. State whether results are per instance or merged across instances, the covered-point denominator, exclusions, simulator/version, and the selected metric. Do not combine unlike metrics into one percentage.
- A percentage needs a named metric. Offer only metrics supported by the installed simulator, such as line/statement, branch, condition/expression, toggle, or FSM coverage. Recommend line/statement coverage for a first target because its denominator is easier to explain; do not invent a target. If no compatible measurement exists, report `N/A` and ask whether to use a supported simulator or continue without a target.
- If the previous simulation was not coverage-instrumented, rerun the same approved test plan with instrumentation before asking for a target. Do not claim a baseline based on estimates.

## Single-Makefile execution contract

- Keep one canonical `<design-root>/Makefile` for testbench compile, individual test execution, regression, coverage instrumentation/merge/report, and any rerun needed for coverage closure. If no Makefile exists, create this one; otherwise extend the existing file. Put every tool invocation in its documented Make target recipe; do not run equivalent commands directly or add per-step runner scripts.
- The Makefile must have a `help` target documenting each target, required variables, tool/version assumptions, inputs, and outputs. Provide targets for at least `tb-compile`, `test`, `regression`, `coverage-baseline`, `coverage-regression`, and `coverage-report`. Expose `COVERAGE_MAX_ROUNDS` (default 5) in `make help`. `make help` is the user-facing command index; `make -n <target>` must show the actual commands that target will execute.
- Execute these targets from the design root and record the exact Make target, variable values, exit status, and log/report paths for each run. Spell out every compiler, simulator, coverage-instrumentation, merge, and report-tool invocation in the Makefile recipe; do not hide EDA execution inside a helper or runner script. A visible helper may process report data only, and must be kept in the project.

## Baseline and target decision

1. Run or reuse the approved baseline regression through the Makefile and produce a real coverage report. Preserve its raw database and logs under `work/coverage/`.
2. Before asking for a threshold, show the measured baseline, metric, numerator/denominator, scope, tool/version, current uncovered points, and whether all existing test cases passed. If the baseline regression has any functional failure, stop coverage closure and diagnose it before asking for a target. Explain that line coverage counts eligible RTL source points reached by simulation; it is distinct from REQ-ID coverage, functional coverage, and mutation score.
3. Ask the user to either provide a target from 0–100% for the measured metric or proceed without a target. If they want a different supported metric, measure and show that metric's baseline before asking for its threshold; never translate a percentage between metrics. Explain that a target such as 60% means at least 60% of the declared coverable points for that metric and scope. Recommend line/statement coverage as a first metric when several are available, but recommend a threshold only when project requirements or evidence support it; otherwise state that no universal threshold is justified.
4. If the user already supplied the target and metric, report the baseline first, then proceed with that choice without asking them to repeat it. Do not interpret an example percentage as an approved target.

## Coverage closure loop

- For each uncovered point, use RTL only to locate the structural coverage gap. Derive stimulus, expected behavior, and pass/fail checks from the approved verification contract and its golden sources (approved specification, configuration, and exact protocol-standard revision). Never derive the golden result from RTL implementation details. If no contract-backed legal stimulus can cover a point, identify the gap and ask for the missing requirement or mark it unreachable/excluded only with evidence and user review.
- Add only tests that represent legal specified behavior. Every new test must be a persistent SystemVerilog file under `src/tb/tests/`, have a unique TC-ID, explicit REQ-ID/standard-clause trace, a deterministic seed when randomized, and checks that can fail. Preserve the Gate 4-approved `test_cases` array; append closure cases to a distinct `coverage_closure.test_cases` section in `schemas/selected_testplan.json`, recording the user-selected metric/target, uncovered point, and specification clause for each case. Add each source to `src/tb/filelist_tb.f` and register it with the testbench dispatcher so `make test TC=<TC-ID>` can select it. Makefile regression targets must run both the approved base cases and coverage-closure cases. Do not use temporary or in-memory tests. Preserve existing tests and reports; do not overwrite user-edited artifacts without a review decision.
- After adding tests, use only Makefile targets to compile and run the full selected regression, merge coverage data, and generate a report. Save each iteration's logs and reports. A new testcase must pass its functional checks before its coverage contribution is counted.
- Repeat until the selected target is reached, the configured maximum of five closure rounds is reached, or two consecutive rounds add no coverable points. After each round, show the user its persisted TC-IDs/files, spec trace, Make targets, and measured change. Do not change the target, weaken checks, suppress points, or modify RTL solely to improve the percentage. A functional failure is a verification failure: stop coverage closure and route it through the RTL/specification review flow.
- If the target remains unmet, report the remaining points and reason, then ask whether to revise the target, provide missing specification clarification, or stop with the target unmet. A selected target is not marked pass unless the measured final result meets it. Gate 5 remains unapproved while a selected mandatory target is unmet.

## Outputs and reporting

- Keep all added tests in `src/tb/tests/`; update the test plan and file list. Keep coverage databases, per-round logs, and merged reports in `work/coverage/`.
- Update `schemas/verification_report.json` with coverage status (`not_requested`, `not_supported`, `baseline_only`, `target_met`, or `target_unmet`), metric, baseline/final/target percentages, covered/coverable counts, scope/exclusions, simulator/version, added TC-IDs and source-file paths, iteration count, and evidence paths. Preserve functional simulation and mutation results as separate fields.
- Summarize the baseline before the target question and report the final measured result, whether the target was met, every generated testcase, and the Makefile targets the user can run to reproduce compile, regression, and coverage results.
