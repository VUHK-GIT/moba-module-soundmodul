# Architektur

## Zuständigkeiten

Der Arduino Nano ist die maßgebliche Laufzeitkomponente. Die Windows-Anwendung
ist Konfigurations- und Bedienclient, aber kein erforderlicher Scheduler.

Der Nano übernimmt:

- EEPROM-Konfiguration;
- JQ6500-Befehlsfolge;
- BUSY-Auswertung;
- FIFO-Warteschlange;
- Entprellung der Hardwareeingänge;
- Dauer-, Zufalls- und Intervallautomatik;
- PC-Sitzungsüberwachung und Standalone-Rückfall.

Die Desktop-Anwendung übernimmt:

- COM-Port-Suche;
- deutsche Benutzeroberfläche;
- Bearbeitung der Konfiguration;
- manuelle Wiedergabebefehle;
- Diagnose und Statusanzeige.

## Sitzungsmodell

```text
keine aktive PC-Sitzung
        |
        | SESSION START
        v
aktive PC-Sitzung
        |
        | SESSION END oder 4 s Kommunikationsausfall
        v
Standalone-Modus INPUTS
```

Ohne aktive PC-Sitzung ist der wirksame Modus immer `INPUTS`. Der in der GUI
gespeicherte Modus bleibt erhalten, wird aber erst in der nächsten PC-Sitzung
wirksam.

## Sicherer Rückfall

Bei Sitzungsende oder Timeout deaktiviert der Nano die Automatik, leert die
Warteschlange, setzt Zeitpläne zurück, beendet einen laufenden Sound bei Bedarf
per JQ6500-Reset und aktiviert wieder die Hardwareeingänge.
