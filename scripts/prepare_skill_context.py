#!/usr/bin/env python3
"""Print a compact, phase-focused inventory of design artifacts."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path


PHASES = {
    "rtl-hierarchy-diagram": {"rtl", "build"},
    "source-command-autoflow": {"spec", "config", "rtl", "sva", "tb", "trace", "build", "docs"},
    "source-command-spec-writer": {"spec"},
    "source-command-spec-parser": {"spec", "config"},
    "source-command-config-ui": {"spec", "config"},
    "source-command-rtl-generator": {"spec", "config", "rtl", "build"},
    "source-command-sva-generator": {"spec", "config", "rtl", "sva", "trace", "build"},
    "source-command-tb-generator": {"config", "rtl", "tb", "trace", "build"},
    "source-command-verification": {"config", "rtl", "sva", "tb", "trace", "build"},
    "source-command-spec-pdf-generator": {"spec", "config", "sva", "tb", "trace", "build", "docs"},
}
SKIP_DIRS = {".git", ".agents", ".claude", ".venv", "venv", "node_modules", "build", "dist", "__pycache__"}
RTL_EXTENSIONS = {".v", ".vh", ".sv", ".svh", ".vhd", ".vhdl"}
LOG_EXTENSIONS = {".log", ".out"}


def categories(path: Path) -> set[str]:
    name = path.name.lower()
    parts = {part.lower() for part in path.parts}
    result: set[str] = set()
    if any(word in name for word in ("spec", "requirement")) or "spec" in parts:
        result.add("spec")
    if "config" in name or "config" in parts:
        result.add("config")
    if "rtm" in name or "verification_report" in name:
        result.add("trace")
    if (
        path.suffix.lower() in RTL_EXTENSIONS
        or "rtl" in parts
        or "rtl_rule" in name
        or "coding_rule" in name
        or ("rtl" in name and "rule" in name)
    ):
        result.add("rtl")
    if "sva" in parts or "assert" in name:
        result.add("sva")
    if "tb" in parts or "testbench" in parts or "testplan" in name or "tests" in parts:
        result.add("tb")
    if (
        path.suffix.lower() in LOG_EXTENSIONS
        or path.suffix.lower() in {".ys", ".tcl", ".f", ".flist"}
        or name in {"makefile", "synth_report.json"}
        or "synth" in name
        or "compile" in name
    ):
        result.add("build")
    if "docs" in parts or "specification.pdf" in name:
        result.add("docs")
    return result


def walk_files(root: Path):
    for current, dirs, files in os.walk(root):
        dirs[:] = sorted(d for d in dirs if d.lower() not in SKIP_DIRS)
        for filename in sorted(files):
            yield Path(current, filename)


def markdown_headings(path: Path) -> list[str]:
    if path.suffix.lower() != ".md" or path.stat().st_size > 2_000_000:
        return []
    found = []
    try:
        with path.open(encoding="utf-8", errors="replace") as stream:
            for line_no, line in enumerate(stream, 1):
                if line.startswith("#"):
                    found.append(f"{line_no}:{line.lstrip('#').strip()[:100]}")
                    if len(found) == 12:
                        break
    except OSError:
        return []
    return found


def json_outline(path: Path) -> str:
    if path.suffix.lower() != ".json" or path.stat().st_size > 1_000_000:
        return ""
    try:
        data = json.loads(path.read_text(encoding="utf-8", errors="replace"))
    except (OSError, json.JSONDecodeError):
        return "JSON keys unavailable"
    if not isinstance(data, dict):
        return f"JSON top-level type: {type(data).__name__}"
    keys = list(data)[:24]
    status = {
        key: data[key]
        for key in data
        if key.lower().startswith(("gate_", "status", "design", "top", "pass", "fail", "mutation"))
        and isinstance(data[key], (str, int, float, bool, type(None)))
    }
    suffix = f"; status={json.dumps(status, ensure_ascii=False)}" if status else ""
    return f"JSON keys: {', '.join(keys)}{suffix}"


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--phase", required=True, choices=sorted(PHASES))
    parser.add_argument("--root", required=True, type=Path, help="Active design artifact directory")
    parser.add_argument("--include", action="append", default=[], type=Path, help="Explicit input file; repeatable")
    parser.add_argument("--max-files", type=int, default=12, help="Maximum files listed per artifact category")
    args = parser.parse_args()
    root = args.root.expanduser().resolve()
    if not root.is_dir():
        parser.error(f"artifact root is not a directory: {root}")
    if args.max_files < 1 or args.max_files > 100:
        parser.error("--max-files must be between 1 and 100")

    selected: dict[str, list[Path]] = {category: [] for category in sorted(PHASES[args.phase])}
    for path in walk_files(root):
        try:
            relative = path.relative_to(root)
        except ValueError:
            continue
        for category in categories(relative) & selected.keys():
            selected[category].append(path)

    explicit = []
    for supplied in args.include:
        path = supplied.expanduser()
        if not path.is_absolute():
            path = root / path
        path = path.resolve()
        if path.is_file():
            explicit.append(path)
        else:
            print(f"NOTICE: explicit input not found: {path}")

    print(f"Phase: {args.phase}\nArtifact root: {root}")
    print("Index only; open selected source files for technical decisions and verification.")
    for category, paths in selected.items():
        print(f"\n[{category}] {len(paths)} file(s)")
        for path in paths[: args.max_files]:
            relative = path.relative_to(root).as_posix()
            size = path.stat().st_size
            estimate = (size + 3) // 4
            details = json_outline(path) or ""
            headings = markdown_headings(path)
            if headings:
                details = (details + "; " if details else "") + "headings: " + " | ".join(headings)
            print(f"- {relative} ({size} bytes, ~{estimate} tokens){'; ' + details if details else ''}")
        if len(paths) > args.max_files:
            print(f"- ... {len(paths) - args.max_files} additional file(s) omitted")
    if explicit:
        print("\n[explicit inputs]")
        for path in explicit[: args.max_files]:
            print(f"- {path} ({path.stat().st_size} bytes)")
    print("\nThis index may omit relevant inputs. The active specification and original artifacts remain authoritative.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
