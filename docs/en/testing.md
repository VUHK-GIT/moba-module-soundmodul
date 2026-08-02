# Testing

## Automated validation

Run from the repository root:

```bash
python scripts/validate.py
```

The script:

- verifies that every release version is `1.0.0`;
- compiles the firmware with host-side Arduino stubs using strict warnings;
- checks JavaScript syntax with Node.js;
- checks the PureBasic procedure structure;
- verifies that source-code comments are English;
- validates the wiring SVGs, net list and both separate 1 kΩ resistors;
- checks for the separate JQ6500 audio-loading requirement;
- checks that release artifacts are not committed.

## Required hardware tests

Before publishing, complete and record these tests in the pull request:

1. load suitable test audio files into the JQ6500 separately;
2. visually verify R1 1 kΩ between D11 and RX and R2 1 kΩ between BUSY and A2;
3. verify power, common ground, SGND and speaker connections;
4. manually play several available sound indexes;
5. verify volume control;
6. measure BUSY raw values with R2 installed and confirm the thresholds;
7. verify BUSY transition and natural playback end;
8. verify FIFO playback of a queued second sound;
9. verify the connected hardware inputs;
10. close the application normally and verify standalone fallback;
11. disconnect USB or terminate the application and verify fallback after about four seconds;
12. move to another COM port and verify automatic reconnection;
13. verify reset behavior and the expected possible speaker click;
14. cold-start Nano and JQ6500 after complete power removal.

A named mapping of audio files to sound indexes 1 through 10 is not a release
requirement. Users select their own audio files and load them separately into
the JQ6500.

## Release-candidate evidence

The following status was confirmed on 2 August 2026:

- Windows application built with PureBasic 6.40 for Windows x64;
- generated release executable functionally tested on the Windows build system;
- release executable also started and passed a functional test on a second Windows computer;
- hardware setup with both separate resistors R1 and R2 functionally tested;
- R1: Nano D11 -> 1 kΩ -> JQ6500 RX;
- R2: JQ6500 BUSY -> 1 kΩ -> Nano A2;
- BUSY raw values remained unchanged with R2 installed:
  - idle: approximately 2 to 3 ADC counts;
  - playback: approximately 537 to 540 ADC counts;
- the existing thresholds remain confirmed: 150 for BUSY off and 350 for BUSY on;
- verified release filename:
  `MOBA-Module-Soundmodul-1.0.0-Windows-x64.exe`;
- file size: 457728 bytes;
- SHA-256:
  `f7e7f848cc7c67181d3f7ac73f5abb816b72dacdd0afa2af39682b97c81c2946`;
- embedded file and product version: `1.0.0.0`;
- x64 Windows GUI, DPI awareness, normal-user execution, ASLR and DEP/NX were
  confirmed through static PE inspection;
- icon, version resource and application manifest are embedded;
- the release executable is not digitally signed. Windows SmartScreen may
  therefore display a warning on systems where the file has no established reputation.

## General release evidence

For version 1.0.0 record at least:

- date and tester;
- Nano and JQ6500 variants used;
- checksums of tested firmware and executable;
- measured BUSY values while idle and playing;
- result of every test item;
- known limitations.
