# Serial protocol

The desktop application communicates with the Nano at 115200 baud using
newline-terminated ASCII commands.

## Session commands

```text
SESSION START
SESSION END
PING
IDENTIFY
STATUS
```

`SESSION START` enables PC-controlled operation. Each accepted command refreshes
the four-second session timeout. `SESSION END` immediately restores standalone
input operation.

Without an active session, control and configuration commands return:

```text
ERR NO_SESSION
```

## Main control commands

```text
PLAY <1..10>
VOLUME <0..30>
RESET
MODE SOFTWARE
MODE INPUTS
AUTOMATION <0|1>
RANDOM_RANGE <minSeconds> <maxSeconds>
CONFIG <sound> <permanent> <random> <interval> <intervalSeconds>
CONFIG?
MEDIA?
```

## Important behavior

The JQ6500 does not provide a reliable immediate STOP command on the tested
module. `RESET` is used for a confirmed abort and may cause an audible click.
The `MEDIA?` count is diagnostic only and is never used as a prerequisite for
playback.
