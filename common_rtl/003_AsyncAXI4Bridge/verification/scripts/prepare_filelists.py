#!/usr/bin/env python3
"""Create self-contained simulator filelists from the approved RTL filelists."""
from pathlib import Path

HERE = Path(__file__).resolve().parent
VERIFICATION = HERE.parent
PROJECT = VERIFICATION.parent
RTL = PROJECT / "rtl"
OUT = VERIFICATION / "filelists"
PROFILES = {
    "axi4_base": "m_vlsit_axi_async_top",
    "axi4_user": "m_vlsit_axi_user_async_top",
    "axi3": "m_vlsit_axi3_async_top",
}


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    for profile, top in PROFILES.items():
        source_list = RTL / profile / "filelist.f"
        if not source_list.is_file():
            raise SystemExit(f"ERROR: missing approved filelist: {source_list}")
        source_files = []
        for raw_line in source_list.read_text(encoding="utf-8").splitlines():
            line = raw_line.strip()
            if not line or line.startswith("//") or line.startswith("+define+"):
                continue
            source = (source_list.parent / line).resolve()
            if not source.is_file():
                raise SystemExit(f"ERROR: source from {source_list.name} is missing: {source}")
            source_files.append(source.as_posix())
        if not source_files:
            raise SystemExit(f"ERROR: no RTL sources found for {profile}")
        for branch in ("synth", "sim"):
            content = []
            if branch == "synth":
                content.append("+define+VLSIT_SYNTHESIS")
            content.extend(source_files)
            content.append("")
            path = OUT / f"{profile}_{branch}.f"
            path.write_text("\n".join(content), encoding="utf-8", newline="\n")
            print(f"READY: {path.name} ({top}, {len(source_files)} RTL files, {branch})")


if __name__ == "__main__":
    main()
