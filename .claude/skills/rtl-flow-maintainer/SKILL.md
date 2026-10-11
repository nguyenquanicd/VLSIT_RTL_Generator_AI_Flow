---
name: rtl-flow-maintainer
description: Maintain and adapt the VLSIT RTL flow's Claude Code commands, JSON schemas, and specification-parser authoring rules for a hardware IP.
---

# RTL Flow Maintainer

Use this skill when the user asks to create, adapt, or update a Claude Code phase command or its output schema. The runnable phase prompts are the 11 files in `.claude/commands/`. There is one canonical copy of each command; do not recreate a separate command-template tree.

## Procedure

1. Identify the requested IP and phase. Read the corresponding `.claude/commands/<phase>.md`, the approved design specification, and only the supporting resources needed for that phase.
2. For specification parsing, read [spec-parser-authoring-rules.md](references/spec-parser-authoring-rules.md). Adapt section references, parameter names, planned modules, ambiguity review, and requirement mapping to the target IP.
3. For artifact formats, read the applicable JSON schema in [schemas](schemas/). Keep schema paths in commands, Codex skills, and documentation consistent with this directory. Design outputs still belong in the working design's `schemas/` directory.
4. Preserve gate approvals, specification and standard traceability, independent verification intent, saved test cases, and the single documented design-root Makefile. Do not infer expected behavior from generated RTL or historical snapshots.
5. Keep skill and command instructions in technical English. Documentation and README files may be bilingual English and Vietnamese.
6. Review the exact changed files and references. If a reusable improvement is discovered during a normal flow run, follow `.agents/skill_maintenance.md` and request the user's approval before changing skill instructions or support files.

Do not use this maintenance skill to run a design phase. Invoke the appropriate phase command from `.claude/commands/` for that work.
