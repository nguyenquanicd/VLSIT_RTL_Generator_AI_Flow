#!/usr/bin/env python3
"""Extract bounded, line-numbered diagnostic excerpts from EDA logs."""

from __future__ import annotations

import argparse
import os
import re
from pathlib import Path


DIAGNOSTIC = re.compile(r"\b(error|fatal|critical|warning|assert(?:ion)?|failed|failure|pass(?:ed)?|summary|mismatch|timeout)\b", re.I)
ERROR = re.compile(r"\b(error|fatal|critical|failed|failure|mismatch|timeout)\b", re.I)
WARNING = re.compile(r"\bwarning\b", re.I)
SKIP_DIRS = {".git", ".agents", ".claude", ".venv", "venv", "node_modules", "build", "dist", "__pycache__"}


def files_from(paths: list[Path]):
    for supplied in paths:
        path = supplied.expanduser()
        if path.is_dir():
            for current, dirs, files in os.walk(path):
                dirs[:] = sorted(d for d in dirs if d.lower() not in SKIP_DIRS)
                for filename in sorted(files):
                    candidate = Path(current, filename)
                    if candidate.suffix.lower() in {".log", ".out", ".txt"}:
                        yield candidate
        elif path.is_file():
            yield path
        else:
            print(f"NOTICE: path not found: {path}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("paths", nargs="+", type=Path, help="Log files or directories containing logs")
    parser.add_argument("--max-matches", type=int, default=24, help="Maximum diagnostic lines shown per file")
    parser.add_argument("--tail-lines", type=int, default=6, help="Number of final lines shown per file")
    parser.add_argument("--max-files", type=int, default=8, help="Maximum log files shown")
    args = parser.parse_args()
    if not 1 <= args.max_matches <= 200 or not 0 <= args.tail_lines <= 50 or not 1 <= args.max_files <= 100:
        parser.error("--max-matches must be 1..200, --tail-lines 0..50, and --max-files 1..100")

    paths = list(files_from(args.paths))
    for path in paths[: args.max_files]:
        error_count = warning_count = total_matches = 0
        excerpts: list[tuple[int, str]] = []
        recent: list[tuple[int, str]] = []
        seen: set[str] = set()
        try:
            with path.open(encoding="utf-8", errors="replace") as stream:
                for line_no, raw in enumerate(stream, 1):
                    line = raw.rstrip("\r\n")
                    if ERROR.search(line):
                        error_count += 1
                    if WARNING.search(line):
                        warning_count += 1
                    recent.append((line_no, line[:500]))
                    if len(recent) > args.tail_lines:
                        recent.pop(0)
                    if DIAGNOSTIC.search(line):
                        total_matches += 1
                        key = re.sub(r"\s+", " ", line).strip().casefold()
                        if key not in seen and len(excerpts) < args.max_matches:
                            seen.add(key)
                            excerpts.append((line_no, line[:500]))
        except OSError as exc:
            print(f"\n## {path}\nRead error: {exc}")
            continue
        print(f"\n## {path}\nDiagnostic lines: {total_matches}; error-like: {error_count}; warnings: {warning_count}")
        for line_no, line in excerpts:
            print(f"{line_no}: {line}")
        if total_matches > len(excerpts):
            print(f"... {total_matches - len(excerpts)} diagnostic occurrence(s) not shown or deduplicated")
        if recent:
            print("Tail:")
            for line_no, line in recent:
                print(f"{line_no}: {line}")
    if len(paths) > args.max_files:
        print(f"\n... {len(paths) - args.max_files} additional log file(s) omitted; increase --max-files to include them.")
    print("\nExcerpts are for navigation only. Inspect original log lines before reporting any tool result.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
