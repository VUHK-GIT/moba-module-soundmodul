# Wiring diagram assets

This directory contains the authoritative, deterministically constructed wiring
artwork for MOBA-Module Sound Module 1.0.0.

- `moba-module-soundmodul-wiring-de.svg`: German diagram;
- `moba-module-soundmodul-wiring-en.svg`: English diagram;
- `NETLIST.md`: authoritative electrical net list;
- `SOURCES.md`: pinout and upload references.

The net list, not visual proximity, defines the electrical connections.

The BUSY path includes the dedicated second series resistor:

```text
JQ6500 BUSY -> R2 1 kΩ -> Arduino Nano A2
```

The UART transmit path uses a separate resistor:

```text
Arduino Nano D11 -> R1 1 kΩ -> JQ6500 RX
```

PNG exports are generated for GitHub Release assets. The editable SVG files are
kept in the source repository and render directly on GitHub.

Copyright (c) 2026 Sven Häber.

Documentation is licensed under the MIT License. The MOBA-Module name and brand
assets are excluded from the MIT License.
