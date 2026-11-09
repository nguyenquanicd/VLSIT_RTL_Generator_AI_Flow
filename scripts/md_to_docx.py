#!/usr/bin/env python3
"""Convert Markdown with TeX math to DOCX using Pandoc."""

import argparse
import sys
from pathlib import Path

from md_to_docx_pdf import convert_markdown


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, help="Input Markdown file")
    parser.add_argument("output", type=Path, help="Output DOCX file")
    parser.add_argument("--reference-doc", type=Path, help="Optional Pandoc reference DOCX for Word styles")
    parser.add_argument("--force", action="store_true", help="Replace an existing output file")
    args = parser.parse_args()
    if args.output.suffix.lower() != ".docx":
        parser.error("output must use the .docx extension")
    try:
        convert_markdown(
            args.source,
            args.output,
            "docx",
            reference_doc=args.reference_doc,
            force=args.force,
        )
    except (FileNotFoundError, FileExistsError, RuntimeError, ValueError, OSError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
