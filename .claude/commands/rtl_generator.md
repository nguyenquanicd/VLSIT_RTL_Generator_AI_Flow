# Phase 3R: RTL Generator — /rtl_generator

Generate synthesizable SystemVerilog from the approved specification and configuration. This is the RTL implementation branch; it does not create a verification oracle.

## Preconditions and sources

Require Gate 1 and Gate 2 approval. Read the approved specification, schemas/structured_spec.json, and schemas/final_config.json. Use the configured RTL rule file. For a legacy configuration without an explicit source_kind, treat its old path as unsupplied and use a rule file explicitly supplied for this design or spec_template/VLSIT_RTL_Design_Rule.md. Do not use historical Result snapshots as design inputs. Ask about unresolved behavior rather than inventing it.

## Generation

1. Derive the module list and compile order from the approved specification. Historical RV32IM module counts and names are examples, not universal requirements.
2. Put one module in each matching file under src/rtl/. Follow the selected RTL rules for naming, module structure, types, comments, width handling, clock/reset behavior, and synthesis restrictions. Tag implementing blocks with their REQ-IDs.
3. Generate each module in dependency order. Lint immediately after each module; repair issues before proceeding. Preserve actual tool output and distinguish unavailable tools from passing checks.
4. Create src/rtl/filelist.f in compile order. Check the complete design hierarchy and top module.
5. Use one design-root Makefile shared by all phases. Put tool checks, lint, and synthesis commands in documented recipes. Provide make help and allow command inspection with make -n. Save logs, tool versions, and exit codes; do not hide EDA invocations in helper scripts.
6. If synthesis is available, run the configured technology and corners through Make targets. Diagnose failures, repair RTL, and rerun. Record actual results in schemas/synth_report.json; label unavailable or unrun checks accurately.

## Boundary and report

The RTL may use the specification and RTL style rules. It must not read generated SVA, tests, coverage results, or RTL-derived expected behavior as a specification substitute. Report generated files, REQ-ID mapping, lint and synthesis status, unresolved requirements, and exact commands needed to reproduce checks. Lint and synthesis are implementation checkpoints, not Gate 3a or Gate 3b approvals.
