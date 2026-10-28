#!/usr/bin/env python3
"""Replace selected converted Markdown page bodies with the PDF text layer."""

from __future__ import annotations

import argparse
import re
from pathlib import Path

import fitz


PAGE_MARKER = re.compile(r"<!-- page (\d+) -->")
SOURCE_END = "<!-- END VERBATIM SOURCE -->"


def repair(source: Path, markdown: Path, pages: list[int]) -> None:
    text = markdown.read_text(encoding="utf-8")
    matches = list(PAGE_MARKER.finditer(text))
    page_indices = {int(match.group(1)): index for index, match in enumerate(matches)}
    missing = sorted(set(pages) - page_indices.keys())
    if missing:
        raise ValueError(f"Markdown page markers not found: {missing}")

    document = fitz.open(source)
    replacements: list[tuple[int, int, str]] = []
    for number in sorted(set(pages)):
        index = page_indices[number]
        marker = matches[index]
        if index + 1 < len(matches):
            body_end = matches[index + 1].start()
        else:
            body_end = text.index(SOURCE_END, marker.end())
        source_text = document[number - 1].get_text("text").strip()
        if not source_text:
            raise ValueError(f"PDF page {number} has no extractable text")
        replacements.append((marker.end(), body_end, "\n\n" + source_text + "\n\n"))

    for start, end, replacement in reversed(replacements):
        text = text[:start] + replacement + text[end:]
    markdown.write_text(text, encoding="utf-8")
    print(f"Rebuilt {len(replacements)} page body/bodies from the PDF text layer: {markdown}")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="Source PDF")
    parser.add_argument("markdown", type=Path, help="Converted Markdown to update in place")
    parser.add_argument("--pages", nargs="+", type=int, required=True)
    args = parser.parse_args()
    repair(args.source, args.markdown, args.pages)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
