#!/usr/bin/env python3
"""Create the source ZIP and SHA-256 file for an official release."""

from __future__ import annotations

import hashlib
import subprocess
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VERSION = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
DIST = ROOT / "dist"
ARCHIVE = DIST / f"MOBA-Module-Soundmodul-{VERSION}-source.zip"
CHECKSUMS = DIST / "SHA256SUMS.txt"
EXCLUDED_PARTS = {".git", "dist", "build", "release", "__pycache__"}
EXCLUDED_SUFFIXES = {".exe", ".msi", ".pyc"}


def main() -> int:
    subprocess.run([sys.executable, str(ROOT / "scripts/validate.py")], check=True)
    DIST.mkdir(exist_ok=True)
    if ARCHIVE.exists():
        ARCHIVE.unlink()

    with zipfile.ZipFile(ARCHIVE, "w", zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(ROOT.rglob("*")):
            if not path.is_file():
                continue
            relative = path.relative_to(ROOT)
            if any(part in EXCLUDED_PARTS for part in relative.parts):
                continue
            if path.suffix.lower() in EXCLUDED_SUFFIXES:
                continue
            archive.write(path, Path(f"moba-module-soundmodul-{VERSION}") / relative)

    digest = hashlib.sha256(ARCHIVE.read_bytes()).hexdigest()
    CHECKSUMS.write_text(f"{digest}  {ARCHIVE.name}\n", encoding="utf-8")
    print(ARCHIVE)
    print(CHECKSUMS)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
