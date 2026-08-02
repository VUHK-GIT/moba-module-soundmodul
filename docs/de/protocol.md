# Serielles Protokoll

Die Desktop-Anwendung kommuniziert mit dem Nano bei 115200 Baud über
zeilenweise abgeschlossene ASCII-Befehle.

## Sitzungsbefehle

```text
SESSION START
SESSION END
PING
IDENTIFY
STATUS
```

`SESSION START` aktiviert die PC-Steuerung. Jeder akzeptierte Befehl erneuert
den Vier-Sekunden-Timeout. `SESSION END` stellt sofort den Standalone-Betrieb
über die Eingänge wieder her.

Ohne aktive Sitzung werden Steuer- und Konfigurationsbefehle abgewiesen:

```text
ERR NO_SESSION
```

## Zentrale Steuerbefehle

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

## Wichtige Eigenschaften

Der getestete JQ6500 besitzt keinen zuverlässig nutzbaren unmittelbaren
STOP-Befehl. Für einen bestätigten Abbruch wird `RESET` verwendet; dabei kann
ein hörbares Knacken entstehen. Die Dateianzahl aus `MEDIA?` ist ausschließlich
Diagnose und niemals Voraussetzung für die Wiedergabe.
