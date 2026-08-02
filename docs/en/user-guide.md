# User guide

The application interface is German in version 1.0.0.

## Connection

On startup, the application scans available COM ports. If the Nano is moved to
another USB port, use `COM-Ports neu suchen` or select a port and press
`Verbinden`.

## Operating modes

- `Software`: manual playback and automation are controlled by the PC.
- `Eingänge`: the ten hardware inputs trigger sounds directly.

Without an active PC session, the Nano always operates in input mode.

## Automation

Each sound can be configured for:

- permanent replay after natural completion;
- random triggering using the global random range;
- fixed interval triggering.

New requests enter the FIFO queue. The same sound is not queued more than once.

## Reset

`Wiedergabe zurücksetzen` stops the current sound through JQ6500 reset, clears
the queue and disables automation. The hardware may produce a short click.
