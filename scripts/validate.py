#!/usr/bin/env python3
"""Validate the open-source source tree without requiring target hardware."""

from __future__ import annotations

import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
VERSION = "1.0.0"


def fail(message: str) -> None:
    raise RuntimeError(message)


def run(command: list[str], cwd: Path | None = None) -> None:
    result = subprocess.run(command, cwd=cwd, text=True, capture_output=True)
    if result.returncode != 0:
        fail(
            f"Command failed: {' '.join(command)}\n"
            f"stdout:\n{result.stdout}\n"
            f"stderr:\n{result.stderr}"
        )


def check_versions() -> None:
    expected = {
        ROOT / "VERSION": VERSION,
        ROOT / "firmware/MOBA_Module_Soundmodul_Nano/src/Core.hpp":
            f'constexpr char FIRMWARE_VERSION[] = "{VERSION}";',
        ROOT / "software/purebasic/MOBA_Module_Soundmodul.pb":
            f'#APP_VERSION = "{VERSION}"',
    }
    for path, token in expected.items():
        text = path.read_text(encoding="utf-8-sig")
        if token not in text:
            fail(f"Version token missing in {path}: {token}")

    source_files = (
        list(ROOT.rglob("*.ino"))
        + list(ROOT.rglob("*.hpp"))
        + list(ROOT.rglob("*.pb"))
        + list(ROOT.rglob("*.pbi"))
    )
    for path in source_files:
        text = path.read_text(encoding="utf-8-sig")
        if re.search(r"\b(?:alpha|beta|rc)\d*\b", text, re.IGNORECASE):
            fail(f"Pre-release marker found in stable source: {path}")


def check_license_headers() -> None:
    required = [
        ROOT / "firmware/MOBA_Module_Soundmodul_Nano/MOBA_Module_Soundmodul_Nano.ino",
        ROOT / "firmware/MOBA_Module_Soundmodul_Nano/src/Core.hpp",
        ROOT / "firmware/MOBA_Module_Soundmodul_Nano/src/Queue.hpp",
        ROOT / "firmware/MOBA_Module_Soundmodul_Nano/src/Scheduler.hpp",
        ROOT / "firmware/MOBA_Module_Soundmodul_Nano/src/Playback.hpp",
        ROOT / "firmware/MOBA_Module_Soundmodul_Nano/src/Protocol.hpp",
        ROOT / "software/purebasic/MOBA_Module_Soundmodul.pb",
        *(sorted((ROOT / "software/purebasic/src").glob("*.pbi"))),
        ROOT / "software/purebasic/ui/index.template.html",
        *(sorted((ROOT / "software/purebasic/ui/src/styles").glob("*.css"))),
        *(sorted((ROOT / "software/purebasic/ui/src/scripts").glob("*.js"))),
    ]
    for path in required:
        text = path.read_text(encoding="utf-8-sig")
        if "SPDX-License-Identifier: MIT" not in text:
            fail(f"SPDX license header missing: {path}")
        if "Copyright (c) 2026 Sven Häber" not in text:
            fail(f"Copyright header missing: {path}")


def check_comment_language() -> None:
    firmware_dir = ROOT / "firmware/MOBA_Module_Soundmodul_Nano"
    firmware = "\n".join(
        path.read_text(encoding="utf-8")
        for path in [
            firmware_dir / "MOBA_Module_Soundmodul_Nano.ino",
            *(sorted((firmware_dir / "src").glob("*.hpp"))),
        ]
    )
    purebasic_dir = ROOT / "software/purebasic"
    purebasic = "\n".join(
        path.read_text(encoding="utf-8-sig")
        for path in [
            purebasic_dir / "MOBA_Module_Soundmodul.pb",
            *(sorted((purebasic_dir / "src").glob("*.pbi"))),
        ]
    )

    comment_text = "\n".join(re.findall(r"/\*.*?\*/|//[^\n]*", firmware, re.DOTALL))
    comment_text += "\n" + "\n".join(
        line for line in purebasic.splitlines() if line.lstrip().startswith(";")
    )

    german_comment_markers = [
        "Kernprinzip", "Betriebsarten", "Verdrahtung", "Warteschlange",
        "Fenster", "Anwendung für", "Eingänge werden", "wird gespeichert",
        "ausschließlich", "beziehungsweise",
    ]
    found = [marker for marker in german_comment_markers if marker in comment_text]
    if found:
        fail(f"German source-code comment markers found: {found}")


def check_purebasic_structure() -> None:
    purebasic_dir = ROOT / "software/purebasic"
    text = "\n".join(
        path.read_text(encoding="utf-8-sig")
        for path in [
            purebasic_dir / "MOBA_Module_Soundmodul.pb",
            *(sorted((purebasic_dir / "src").glob("*.pbi"))),
        ]
    )
    procedures = len(re.findall(r"(?mi)^Procedure(?:\.[A-Za-z]+)?\b", text))
    endings = len(re.findall(r"(?mi)^EndProcedure\b", text))
    if procedures != endings:
        fail(f"PureBasic Procedure/EndProcedure mismatch: {procedures}/{endings}")
    if 'IncludeBinary "ui\\index.html"' not in text:
        fail("PureBasic UI IncludeBinary statement is missing")


def check_firmware_syntax() -> None:
    compiler = shutil.which("g++")
    if not compiler:
        fail("g++ is required for firmware host syntax validation")
    with tempfile.TemporaryDirectory() as temp_dir:
        output = Path(temp_dir) / "sketch.o"
        run([
            compiler,
            "-std=c++17",
            "-Wall",
            "-Wextra",
            "-Werror",
            "-I",
            str(ROOT / "tests/firmware_host"),
            "-c",
            str(ROOT / "tests/firmware_host/sketch.cpp"),
            "-o",
            str(output),
        ])


def check_ui_generation() -> None:
    template = ROOT / "software/purebasic/ui/index.template.html"
    output = ROOT / "software/purebasic/ui/index.html"
    template_text = template.read_text(encoding="utf-8")
    for placeholder in ["{{STYLES}}", "{{BODY}}", "{{SCRIPT}}"]:
        if placeholder not in template_text:
            fail(f"UI template placeholder is missing: {placeholder}")
    body = ROOT / "software/purebasic/ui/src/body.html"
    if "{{BRAND_MARKUP}}" not in body.read_text(encoding="utf-8"):
        fail("UI body brand placeholder is missing")
    run([sys.executable, str(ROOT / "scripts/prepare_ui.py")])
    if not output.exists():
        fail("Generated UI file is missing")


def check_javascript() -> None:
    node = shutil.which("node")
    if not node:
        fail("Node.js is required for JavaScript syntax validation")
    html = (ROOT / "software/purebasic/ui/index.html").read_text(encoding="utf-8")
    scripts = re.findall(r"<script>(.*?)</script>", html, re.DOTALL | re.IGNORECASE)
    if not scripts:
        fail("No embedded JavaScript found in UI")
    with tempfile.TemporaryDirectory() as temp_dir:
        script_path = Path(temp_dir) / "ui.js"
        script_path.write_text("\n".join(scripts), encoding="utf-8")
        run([node, "--check", str(script_path)])


def check_repository_hygiene() -> None:
    forbidden_suffixes = {".exe", ".msi", ".zip", ".sha256"}
    ignored_roots = {"dist", "build", "release", ".git"}
    for path in ROOT.rglob("*"):
        if not path.is_file():
            continue
        relative = path.relative_to(ROOT)
        if relative.parts and relative.parts[0] in ignored_roots:
            continue
        if path.suffix.lower() in forbidden_suffixes:
            fail(f"Release artifact must not be committed: {relative}")


def main() -> int:
    checks = [
        check_versions,
        check_license_headers,
        check_comment_language,
        check_purebasic_structure,
        check_firmware_syntax,
        check_ui_generation,
        check_javascript,
        check_repository_hygiene,
    ]
    for check in checks:
        check()
        print(f"OK  {check.__name__}")
    print("All source validations passed.")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeError as error:
        print(f"ERROR: {error}", file=sys.stderr)
        raise SystemExit(1)
