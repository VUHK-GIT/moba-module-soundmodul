# Tests

## Automatische Prüfung

Im Repository-Stamm ausführen:

```bash
python scripts/validate.py
```

Das Skript prüft:

- alle Versionsangaben auf `1.0.0`;
- Firmwareübersetzung mit Arduino-Hoststubs und strengen Warnungen;
- JavaScript-Syntax mit Node.js;
- PureBasic-Prozedurstruktur;
- englische Quellcodekommentare;
- Ausschluss von Release-Binärdateien aus dem Repository.

## Erforderliche Hardwaretests

Vor einer Veröffentlichung prüfen:

1. manuelle Wiedergabe der Soundindizes 1, 2 und 3;
2. Lautstärkeregelung;
3. BUSY-Wechsel und natürliches Wiedergabeende;
4. FIFO-Wiedergabe eines währenddessen eingereihten zweiten Sounds;
5. alle zehn Hardwareeingänge;
6. normales Schließen der Anwendung und Standalone-Rückfall;
7. USB-Trennung oder Programmabsturz und Rückfall nach ungefähr vier Sekunden;
8. COM-Port-Wechsel und automatische Wiederverbindung;
9. Reset-Verhalten und mögliches Lautsprecherknacken.
