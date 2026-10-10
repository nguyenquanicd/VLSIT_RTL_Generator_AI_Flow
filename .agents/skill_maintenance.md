# Skill improvement policy

After each skill run, assess the issues observed during that run. Propose a change only when it is likely to improve RTL/design correctness or verification quality across typical designs, has high impact, and is supported by existing evidence from at least two distinct design contexts. Use `scripts/propose_skill_update.py` to enforce this threshold.

Do not propose project-specific requirements, user naming preferences, one-off ambiguities, speculative cleanup, or tool-version changes as general skill improvements. Cite the evidence file and the distinct design represented by it. Do not scan all historical artifacts solely to manufacture a proposal; use evidence already inspected or a narrowly relevant comparison.

Present any qualifying proposal with the target skill, exact change, broad benefit, and evidence. Ask the user to approve that exact change. Do not edit `SKILL.md`, references, templates, or other skill support files before explicit user confirmation. A confirmation authorizes only the stated proposal. If no proposal meets the threshold, briefly say that no high-value reusable update was identified.

Example invocation: `python scripts/propose_skill_update.py --skill source-command-rtl-generator --finding "..." --change "..." --benefit "..." --impact high --scope cross-design --evidence DESIGN_A=path/to/evidence_a.log --evidence DESIGN_B=path/to/evidence_b.log`. Evidence paths are checked for existence; the skill must also confirm that each file supports the finding and represents a distinct design.
