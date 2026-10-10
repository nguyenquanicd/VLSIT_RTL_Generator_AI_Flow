# Phase 6: Final Specification Document — /spec_pdf_generator

After Gate 5 sign-off, create final IP documentation from approved artifacts and actual check results.

## Preconditions and sources

Require schemas/verification_report.json with gate_5_approved=true. Read the approved specification, schemas/final_config.json, schemas/structured_spec.json, schemas/verification_contract.json, schemas/rtm.json, schemas/selected_testplan.json, actual verification report, optional schemas/synth_report.json, and src/rtl/filelist.f. Keep source revisions and measured results traceable. Never invent a missing value or convert an unrun check into a pass.

## Document

Create docs/specification.md. Include, where applicable, cover and revision, quick reference, overview, parameter and feature tables, port list, clock/reset behavior, module hierarchy, microarchitecture, functional behavior, register map, error handling, verification summary, requirement traceability, synthesis results, limitations, and reproduction commands. Use only approved artifacts for parameters, ports, registers, and requirements. Use actual report values for simulation, mutation, coverage, area, cells, and tool versions. Mark unsupported sections TBD or N/A with a reason.

The document and README may be bilingual English–Vietnamese. Keep skill and command instructions in technical English.

If a PDF converter is available, create docs/specification.pdf and check that conversion succeeded. If unavailable, retain Markdown and report the PDF as not generated. Report final paths, source revisions, and any incomplete sections.
