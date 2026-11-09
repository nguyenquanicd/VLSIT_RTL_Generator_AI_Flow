#!/usr/bin/env python3
"""Export Markdown with TeX math to DOCX and/or PDF through Pandoc."""

from __future__ import annotations

import argparse
import glob
import os
import shutil
import subprocess
import sys
from pathlib import Path
from typing import List, Optional


def _windows_tool_candidates(name: str) -> List[Path]:
    if os.name != "nt":
        return []

    local_app_data = Path(os.environ.get("LOCALAPPDATA", Path.home() / "AppData/Local"))
    candidates: list[Path] = []
    if name == "pandoc":
        candidates.extend(
            [
                local_app_data / "Pandoc" / "pandoc.exe",
                local_app_data / "Programs" / "Pandoc" / "pandoc.exe",
            ]
        )
    elif name == "typst":
        patterns = [
            str(local_app_data / "Microsoft/WinGet/Packages/Typst.Typst_*/*/typst.exe"),
            str(local_app_data / "Microsoft/WinGet/Packages/Typst.Typst_*/typst-*/typst.exe"),
        ]
        for pattern in patterns:
            candidates.extend(Path(path) for path in glob.glob(pattern))
    return candidates


def find_executable(name: str) -> Optional[str]:
    on_path = shutil.which(name)
    if on_path:
        return on_path
    for candidate in _windows_tool_candidates(name):
        if candidate.is_file():
            return str(candidate)
    return None


def _resolve_pdf_engine(engine: str) -> str:
    # Allow either a known engine name or an explicit executable path.
    candidate = Path(engine)
    if candidate.is_file():
        return str(candidate.resolve())
    resolved = find_executable(engine)
    if not resolved:
        raise RuntimeError(
            f"PDF engine '{engine}' was not found. Install it or pass --pdf-engine with an installed engine."
        )
    return resolved


def convert_markdown(
    source: Path,
    destination: Path,
    output_format: str,
    pdf_engine: str = "typst",
    reference_doc: Optional[Path] = None,
    force: bool = False,
) -> None:
    source = source.resolve()
    destination = destination.resolve()
    if reference_doc:
        reference_doc = reference_doc.resolve()
    if not source.is_file():
        raise FileNotFoundError(f"Markdown source not found: {source}")

    pandoc = find_executable("pandoc")
    if not pandoc:
        raise RuntimeError("Pandoc was not found. Install Pandoc and make it available on PATH.")

    if output_format not in {"docx", "pdf"}:
        raise ValueError(f"Unsupported output format: {output_format}")
    destination_preexisted = destination.exists()
    if destination.exists() and not force:
        raise FileExistsError(f"Output already exists: {destination}; pass --force to replace it.")
    if reference_doc and not reference_doc.is_file():
        raise FileNotFoundError(f"Reference DOCX not found: {reference_doc}")

    command = [
        pandoc,
        source.name,
        "--from=markdown+tex_math_dollars",
        "--standalone",
        "--output",
        str(destination),
    ]
    if output_format == "pdf":
        command.append(f"--pdf-engine={_resolve_pdf_engine(pdf_engine)}")
    elif reference_doc:
        command.append(f"--reference-doc={reference_doc.resolve()}")

    destination.parent.mkdir(parents=True, exist_ok=True)
    print(f"Exporting {source.name} to {destination.name}...")
    try:
        subprocess.run(command, cwd=source.parent, check=True)
    except (subprocess.CalledProcessError, OSError) as exc:
        # Remove a partial file only when it did not exist before this invocation.
        if not destination_preexisted and destination.exists():
            destination.unlink()
        if isinstance(exc, subprocess.CalledProcessError):
            message = f"Pandoc failed with exit code {exc.returncode}."
        else:
            message = f"Could not run Pandoc: {exc}"
        raise RuntimeError(message) from exc

    if not destination.is_file() or destination.stat().st_size == 0:
        raise RuntimeError(f"Pandoc did not produce a non-empty output: {destination}")
    print(f"Created {destination}")


def main(argv: Optional[List[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="Export Markdown with dollar-delimited TeX math to DOCX, PDF, or both."
    )
    parser.add_argument("source", type=Path, help="Input Markdown file")
    parser.add_argument(
        "--format", choices=("docx", "pdf", "all"), default="all", help="Output format(s)"
    )
    parser.add_argument("--output-dir", type=Path, help="Output directory (default: source directory)")
    parser.add_argument("--reference-doc", type=Path, help="Optional Pandoc reference DOCX for Word styles")
    parser.add_argument("--pdf-engine", default="typst", help="PDF engine (default: typst)")
    parser.add_argument("--force", action="store_true", help="Replace existing output files")
    args = parser.parse_args(argv)

    source = args.source.resolve()
    output_dir = (args.output_dir or source.parent).resolve()
    formats = ("docx", "pdf") if args.format == "all" else (args.format,)
    if args.reference_doc and "docx" not in formats:
        parser.error("--reference-doc can be used only when DOCX output is selected")
    destinations = [output_dir / f"{source.stem}.{output_format}" for output_format in formats]
    existing = [path for path in destinations if path.exists()]
    if existing and not args.force:
        paths = ", ".join(str(path) for path in existing)
        print(f"Error: output already exists: {paths}; pass --force to replace it.", file=sys.stderr)
        return 1
    try:
        for output_format, destination in zip(formats, destinations):
            convert_markdown(
                source,
                destination,
                output_format,
                pdf_engine=args.pdf_engine,
                reference_doc=args.reference_doc,
                force=args.force,
            )
    except (FileNotFoundError, FileExistsError, RuntimeError, ValueError, OSError) as exc:
        print(f"Error: {exc}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
