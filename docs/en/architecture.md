# Architecture

## Responsibilities

The Arduino Nano is the authoritative runtime component. The Windows
application is a configuration and control client, not a required scheduler.

The Nano owns:

- EEPROM configuration;
- JQ6500 command sequencing;
- BUSY-state evaluation;
- the FIFO playback queue;
- hardware-input debouncing;
- permanent, random and interval automation;
- PC-session timeout and standalone fallback.

The desktop application owns:

- COM-port discovery;
- the German user interface;
- configuration editing;
- manual playback commands;
- diagnostics and status display.

## Session model

```text
no active PC session
        |
        | SESSION START
        v
active PC session
        |
        | SESSION END or 4 s communication timeout
        v
standalone INPUTS mode
```

Without an active PC session, the effective mode is always `INPUTS`. The saved
GUI mode remains stored but is not effective until the next PC session.

## Safe fallback

On session end or timeout, the Nano disables automation, clears the queue,
resets schedules, aborts a running sound through JQ6500 reset when necessary,
and re-enables hardware-input operation.
