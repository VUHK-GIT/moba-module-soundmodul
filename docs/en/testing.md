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
- checks that release artifacts are not committed.

## Required hardware tests

Before publishing a release, verify:

1. manual playback of sound indexes 1, 2 and 3;
2. volume control;
3. BUSY transition and natural playback end;
4. FIFO playback of a queued second sound;
5. all ten hardware inputs;
6. normal application shutdown and standalone fallback;
7. USB disconnect or application crash and fallback after about four seconds;
8. COM-port change and automatic reconnection;
9. reset behavior and expected possible speaker click.
