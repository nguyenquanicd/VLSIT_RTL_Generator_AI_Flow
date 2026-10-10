#!/usr/bin/env python3
"""Print a high-value skill-change proposal; never modifies skill files."""

from __future__ import annotations

import argparse
from pathlib import Path


def parse_evidence(value: str, root: Path) -> tuple[str, Path]:
    if "=" not in value:
        raise argparse.ArgumentTypeError("evidence must use DESIGN_ID=PATH")
    design, raw_path = value.split("=", 1)
    if not design.strip() or not raw_path.strip():
        raise argparse.ArgumentTypeError("evidence must include a design ID and path")
    path = Path(raw_path.strip()).expanduser()
    if not path.is_absolute():
        path = root / path
    return design.strip(), path.resolve()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--skill", required=True, help="Skill directory name")
    parser.add_argument("--finding", required=True, help="Observed accuracy or flow issue")
    parser.add_argument("--change", required=True, help="Exact proposed skill change")
    parser.add_argument("--benefit", required=True, help="Why this improves typical designs")
    parser.add_argument("--impact", choices=("high", "medium", "low"), required=True)
    parser.add_argument("--scope", choices=("cross-design", "single-design"), required=True)
    parser.add_argument("--evidence", action="append", default=[], metavar="DESIGN_ID=PATH", help="Existing evidence file; repeat for each design")
    parser.add_argument("--root", type=Path, default=Path.cwd(), help="Base for relative evidence paths")
    args = parser.parse_args()
    root = args.root.expanduser().resolve()
    try:
        evidence = [parse_evidence(item, root) for item in args.evidence]
    except argparse.ArgumentTypeError as exc:
        parser.error(str(exc))
    missing = [(design, path) for design, path in evidence if not path.is_file()]
    design_ids = {design.casefold() for design, path in evidence if path.is_file()}
    paths = {path for design, path in evidence if path.is_file()}

    reasons = []
    if args.impact != "high":
        reasons.append("impact is not high")
    if args.scope != "cross-design":
        reasons.append("scope is not cross-design")
    if len(design_ids) < 2:
        reasons.append("evidence does not cover at least two distinct designs")
    if len(paths) < 2:
        reasons.append("evidence does not reference at least two distinct files")
    if missing:
        reasons.append("one or more evidence files do not exist")
    if reasons:
        print("No proposal emitted: " + "; ".join(reasons) + ".")
        print("A skill update requires a high-impact, reusable benefit supported by existing evidence from multiple designs.")
        return 0

    print("## Skill update proposal")
    print(f"- Target skill: `{args.skill}`")
    print(f"- Observed finding: {args.finding}")
    print(f"- Proposed change: {args.change}")
    print(f"- Expected broad benefit: {args.benefit}")
    print("- Evidence:")
    for design, path in evidence:
        print(f"  - `{design}`: `{path}`")
    print("- Approval: ask the user to approve this exact change. Do not edit skill files or support assets until the user explicitly confirms.")
    print("This script only prints a proposal; it never writes files.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
