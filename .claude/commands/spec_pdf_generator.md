# Phase 6: Final Specification Document — /spec_pdf_generator

After Gate 5 sign-off, create final IP documentation from approved artifacts and actual check results.

## Preconditions and sources

Require schemas/verification_report.json with gate_5_approved=true. Read the approved specification, schemas/final_config.json, schemas/structured_spec.json, schemas/verification_contract.json, schemas/rtm.json, schemas/selected_testplan.json, actual verification report, optional schemas/synth_report.json, and src/rtl/filelist.f. Keep source revisions and measured results traceable. Never invent a missing value or convert an unrun check into a pass.

## Document

Create the authoritative final document `docs/specification.md`. Include, where applicable, cover and revision, quick reference, overview, parameter and feature tables, port list, clock/reset behavior, module hierarchy, microarchitecture, functional behavior, register map, error handling, verification summary, requirement traceability, synthesis results, limitations, and reproduction commands. Use only approved artifacts for parameters, ports, registers, and requirements. Use actual report values for simulation, mutation, coverage, area, cells, and tool versions. Mark unsupported sections TBD or N/A with a reason. Preserve equations in Pandoc-supported TeX Markdown (`$...$` inline and `$$...$$` display), and link figures with relative Markdown paths. DOCX/PDF are derived from this file; never edit them as independent sources.

The document and README may be bilingual English–Vietnamese. Keep skill and command instructions in technical English.

## Output selection and export

Always retain `docs/specification.md`. If the user has not specified whether to export DOCX or PDF, ask them to choose:

- A — Markdown only: easiest to review in Git; no paginated Word/PDF copy. Example: keep `docs/specification.md` and its figure directory in the repository.
- B — Markdown + DOCX: editable and commentable in Word; layout may reflow, and company styles require a reference DOCX. Example: send `docs/specification.docx` to reviewers for comments.
- C — Markdown + PDF: fixed layout for sharing; not directly editable. Example: attach `docs/specification.pdf` to a design review package.
- D — All three (recommended for Git history, Word review and stable sharing): requires regenerating exports after source edits. Example: store Markdown in Git and distribute DOCX/PDF.
- E — Another combination: follow the user's requested formats.

Explain the options and trade-offs, include the examples, recommend D for a reviewed and distributed design document, and let the user choose. Follow `.agents/skills/decision_prompt_standard.md`. Do not ask again if the requested formats are already clear.

Use the required prompt shape: give a concise analysis of the available document and requested distribution, define DOCX/PDF if needed, list the choices with their effects and trade-offs, give one concrete example, mark the recommendation and its trade-off, and state the exact response format. For example: `Choose A–E; reply D for all three, or E followed by the requested formats.`

Use Pandoc for DOCX and `scripts/md_to_docx.py` to export `docs/specification.md` to `docs/specification.docx`. A user-supplied `--reference-doc` may provide Word styles; without one, Pandoc's defaults apply. Use `scripts/md_to_pdf.py` for PDF; Pandoc needs a PDF engine, with Typst as the default. Other installed Pandoc engines may be selected. Do not install missing software without the user's approval. The scripts refuse to replace existing outputs unless `--force` is passed; obtain authorization before using it on existing files.

Check that every selected export exists and is non-empty. Report final paths, selected formats, source revisions, actual PDF engine, and incomplete sections. If a requested tool is unavailable, retain Markdown and report which export was not generated.
