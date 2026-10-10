# Phase 2: Configuration — /config_ui

Select legal design parameters from the approved specification and create schemas/final_config.json. Gate 2 requires explicit approval when this command runs independently; full /autoflow may approve Gate 2 automatically only when all choices are specification defaults and every constraint passes.

## Procedure

1. Read schemas/structured_spec.json and the approved specification. Build a table with name, type, default, legal values, function, affected features, and affected REQ-IDs.
2. Show current and proposed values. Explain each option, dependency, and supported area, timing, throughput, or compatibility effect. Follow .agents/skills/decision_prompt_standard.md for all user decisions. Do not silently change a default.
3. Reject invalid values immediately. Validate every specification constraint, including dependencies, mutual exclusions, alignment, and parameter ranges. The historical RV32IM C1–C5 constraints apply only when that IP specification defines them.
4. Select the RTL style rule file. If the user supplied one, record its exact path and source_kind. Otherwise use spec_template/VLSIT_RTL_Design_Rule.md as the repository default. Never substitute Result snapshots or an unrelated project's rule file.
5. Show a final summary of parameter values, effects, constraints, and rule source. Recommend approval only if all constraints pass.

## Output

Write schemas/final_config.json using the repository schema. Keep gate_2_approved=false until the required approval occurs. On approval, record the decision and set it true. Do not generate RTL, assertions, tests, or other code here.
