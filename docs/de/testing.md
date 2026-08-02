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
- Verdrahtungs-SVGs, Netzliste und beide getrennten 1-kΩ-Widerstände;
- Dokumentationshinweis zum separaten Bespielen des JQ6500;
- Ausschluss von Release-Binärdateien aus dem Repository.

## Erforderliche Hardwaretests

Vor einer Veröffentlichung prüfen und das Ergebnis im Pull Request festhalten:

1. JQ6500 separat mit einer dokumentierten Testdatei-Reihenfolge bespielen;
2. Sichtprüfung: R1 1 kΩ zwischen D11 und RX sowie R2 1 kΩ zwischen BUSY und A2;
3. Versorgung, gemeinsame Masse, SGND und Lautsprecheranschlüsse prüfen;
4. manuelle Wiedergabe der Soundindizes 1, 2 und 3;
5. Lautstärkeregelung;
6. BUSY-Rohwerte mit eingebautem R2 erneut messen und Schwellen bestätigen;
7. BUSY-Wechsel und natürliches Wiedergabeende;
8. FIFO-Wiedergabe eines währenddessen eingereihten zweiten Sounds;
9. alle zehn Hardwareeingänge mit Sound 1 bis 10;
10. normales Schließen der Anwendung und Standalone-Rückfall;
11. USB-Trennung oder Programmabsturz und Rückfall nach ungefähr vier Sekunden;
12. COM-Port-Wechsel und automatische Wiederverbindung;
13. Reset-Verhalten und mögliches Lautsprecherknacken;
14. erneuter Start nach vollständiger Trennung von Nano und JQ6500.

## Freigabenachweis

Für die Version 1.0.0 mindestens dokumentieren:

- Datum und Tester;
- verwendete Nano- und JQ6500-Variante;
- Prüfsumme der getesteten Firmware und EXE;
- Sounddatei-Reihenfolge 1 bis 10;
- gemessene BUSY-Werte im Leerlauf und während Wiedergabe;
- Ergebnis jedes Prüfpunkts;
- bekannte Einschränkungen.
