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

1. load a documented test-file order into the JQ6500 separately;
2. visually verify R1 1 kΩ between D11 and RX and R2 1 kΩ between BUSY and A2;
3. verify power, common ground, SGND and speaker connections;
4. manually play sound indexes 1, 2 and 3;
5. verify volume control;
6. measure BUSY raw values with R2 installed and confirm the thresholds;
7. verify BUSY transition and natural playback end;
8. verify FIFO playback of a queued second sound;
9. test all ten hardware inputs with sounds 1 through 10;
10. close the application normally and verify standalone fallback;
11. disconnect USB or terminate the application and verify fallback after about four seconds;
12. move to another COM port and verify automatic reconnection;
13. verify reset behavior and the expected possible speaker click;
14. cold-start Nano and JQ6500 after complete power removal.

## Release evidence

For version 1.0.0 record at least:

- date and tester;
- Nano and JQ6500 variants used;
- checksums of tested firmware and executable;
- sound-file order 1 through 10;
- measured BUSY values while idle and playing;
- result of every test item;
- known limitations.
