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
- BUSY detection on Nano A2; the BUSY line includes the external **R2 1 kΩ**
  series resistor;
- FIFO queue with duplicate suppression;
- automatic fallback to hardware-input mode when the PC application closes,
  crashes, disconnects or stops communicating;
- German user interface;
- English source-code identifiers and comments;
- German and English documentation.

## Important audio-file requirement

The Nano firmware and Windows application do **not** upload audio to the
JQ6500-16P. Before first use, load the required sounds separately into the
JQ6500 internal flash through the module's USB interface. Upload order defines
the sound indexes: the first file is sound 1, the second file is sound 2, and so
on.

The repository does not distribute audio files or a proprietary JQ6500 uploader.
A named mapping of files to sound indexes 1 through 10 is not required for the
release; users select and manage their own audio files. See
[docs/en/jq6500-sounds.md](docs/en/jq6500-sounds.md).

## Repository layout

```text
firmware/                 Arduino Nano firmware
software/purebasic/       Windows desktop application source
software/purebasic/ui/    German UI template and modular CSS/JavaScript sources
docs/en/                  English documentation
docs/de/                  German documentation
docs/assets/wiring/       Authoritative SVG wiring diagrams and net list
scripts/                  Validation and packaging tools
tests/firmware_host/      Host-side Arduino compatibility stubs
```

## Quick start

1. Load the required sounds into the JQ6500-16P separately over USB.
2. Wire the Arduino Nano, JQ6500-16P and the ten inputs as described in
   [docs/en/hardware.md](docs/en/hardware.md). Two separate 1 kΩ resistors are
   required: R1 in the RX line and R2 in the BUSY-to-A2 line.
3. Install the upstream `JQ6500_Serial` Arduino library.
4. Upload
   `firmware/MOBA_Module_Soundmodul_Nano/MOBA_Module_Soundmodul_Nano.ino`.
5. Run `python scripts/prepare_ui.py` to assemble the embedded interface. Add
   the official logo locally before this step only for an authorized branded
   build.
6. Build the Windows application with PureBasic 6.10 LTS or newer by opening
   `software/purebasic/MOBA_Module_Soundmodul.pb`.
7. Start the application. It scans available COM ports automatically.

Detailed build instructions: [docs/en/build-windows.md](docs/en/build-windows.md)

## Downloads

Official Windows executables are published as assets on the corresponding
GitHub Release. Executables are intentionally not committed to the source tree.

The official version `1.0.0` is distributed as a Windows x64 executable. The
initial executable is not digitally signed, so Windows SmartScreen may display
a warning on systems where the file has no established reputation. The
published SHA-256 checksum is provided for integrity verification.

## License

The source code and documentation are licensed under the [MIT License](LICENSE).

The MOBA-Module name, logo and icon are **not** covered by the MIT License. See
[TRADEMARKS.md](TRADEMARKS.md) and [ASSETS.md](ASSETS.md).

Third-party notices are listed in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Status

Version 1.0.0 was built with PureBasic 6.40 for Windows x64 and functionally
tested on the project hardware with both R1 and R2 installed. The release branch
remains private until the remaining publication checks are complete.
