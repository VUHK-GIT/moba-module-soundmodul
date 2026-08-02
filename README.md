# MOBA-Module Sound Module

[Deutsche Dokumentation](README.de.md)

Version **1.0.0** is the first stable open-source release of a model railway
sound controller built around an Arduino Nano and a JQ6500-16P audio module.
The Nano works autonomously: it manages hardware inputs, playback state,
configuration persistence, automation and a FIFO queue. A Windows desktop
application provides configuration, manual playback and diagnostics.

## Main features

- ten hardware inputs for sound indexes 1 through 10;
- Windows control application written in PureBasic;
- automatic COM-port discovery and manual port selection;
- persistent configuration stored in Nano EEPROM;
- permanent, random and interval-based playback modes;
- BUSY detection using the measured analog signal on Nano A2;
- FIFO queue with duplicate suppression;
- automatic fallback to hardware-input mode when the PC application closes,
  crashes, disconnects or stops communicating;
- German user interface;
- English source-code identifiers and comments;
- German and English documentation.

## Repository layout

```text
firmware/                 Arduino Nano firmware
software/purebasic/       Windows desktop application source
software/purebasic/ui/    German UI template and modular CSS/JavaScript sources
docs/en/                  English documentation
docs/de/                  German documentation
scripts/                  Validation and packaging tools
tests/firmware_host/      Host-side Arduino compatibility stubs
```

## Quick start

1. Wire the Arduino Nano, JQ6500-16P and the ten inputs as described in
   [docs/en/hardware.md](docs/en/hardware.md).
2. Install the upstream `JQ6500_Serial` Arduino library.
3. Upload
   `firmware/MOBA_Module_Soundmodul_Nano/MOBA_Module_Soundmodul_Nano.ino`.
4. Run `python scripts/prepare_ui.py` to assemble the embedded interface.
   Add the official logo locally before this step only for an authorized branded build.
5. Build the Windows application with PureBasic 6.10 LTS or newer by opening
   `software/purebasic/MOBA_Module_Soundmodul.pb`.
6. Start the application. It scans available COM ports automatically.

Detailed build instructions: [docs/en/build-windows.md](docs/en/build-windows.md)

## Downloads

Official Windows executables are published as assets on the corresponding
GitHub Release. Executables are intentionally not committed to the source tree.

## License

The source code and documentation are licensed under the [MIT License](LICENSE).

The MOBA-Module name, logo and icon are **not** covered by the MIT License. See
[TRADEMARKS.md](TRADEMARKS.md) and [ASSETS.md](ASSETS.md).

Third-party notices are listed in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Status

Version 1.0.0 is the first stable release. The repository remains private until
the release branch and documentation have been reviewed.
