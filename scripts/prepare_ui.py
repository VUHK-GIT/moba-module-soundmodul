#!/usr/bin/env python3
"""Assemble the embedded UI with an optional proprietary MOBA-Module logo."""

from __future__ import annotations

import base64
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
UI = ROOT / "software/purebasic/ui"
TEMPLATE = UI / "index.template.html"
BODY = UI / "src/body.html"
STYLE_DIR = UI / "src/styles"
SCRIPT_DIR = UI / "src/scripts"
OUTPUT = UI / "index.html"
LOGO = ROOT / "software/purebasic/assets/moba-module_logo.png"
FALLBACK = '<div class="brand-wordmark" aria-label="MOBA-Module">MOBA-MODULE</div>'


def brand_markup() -> str:
    if not LOGO.exists():
        print("Official logo not found; generated UI uses the text fallback.")
        return FALLBACK

    encoded = base64.b64encode(LOGO.read_bytes()).decode("ascii")
    print(f"Embedded proprietary logo from {LOGO}")
    return f'<img src="data:image/png;base64,{encoded}" alt="MOBA-Module">'


def main() -> int:
    html = TEMPLATE.read_text(encoding="utf-8")
    body = BODY.read_text(encoding="utf-8").replace(
        "{{BRAND_MARKUP}}", brand_markup()
    )
    replacements = {
        "{{STYLES}}": "\n".join(
            path.read_text(encoding="utf-8")
            for path in sorted(STYLE_DIR.glob("*.css"))
        ),
        "{{BODY}}": body,
        "{{SCRIPT}}": "\n".join(
            path.read_text(encoding="utf-8")
            for path in sorted(SCRIPT_DIR.glob("*.js"))
        ),
    }
    for placeholder, content in replacements.items():
        if placeholder not in html:
            raise RuntimeError(f"Missing placeholder {placeholder} in {TEMPLATE}")
        html = html.replace(placeholder, content)

    OUTPUT.write_text(html, encoding="utf-8")
    print(OUTPUT)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
