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

1. JQ6500 separat mit geeigneten Test-Sounddateien bespielen;
2. Sichtprüfung: R1 1 kΩ zwischen D11 und RX sowie R2 1 kΩ zwischen BUSY und A2;
3. Versorgung, gemeinsame Masse, SGND und Lautsprecheranschlüsse prüfen;
4. manuelle Wiedergabe mehrerer vorhandener Soundindizes;
5. Lautstärkeregelung;
6. BUSY-Rohwerte mit eingebautem R2 messen und Schwellen bestätigen;
7. BUSY-Wechsel und natürliches Wiedergabeende;
8. FIFO-Wiedergabe eines währenddessen eingereihten zweiten Sounds;
9. angeschlossene Hardwareeingänge prüfen;
10. normales Schließen der Anwendung und Standalone-Rückfall;
11. USB-Trennung oder Programmabsturz und Rückfall nach ungefähr vier Sekunden;
12. COM-Port-Wechsel und automatische Wiederverbindung;
13. Reset-Verhalten und mögliches Lautsprecherknacken;
14. erneuter Start nach vollständiger Trennung von Nano und JQ6500.

Eine namentliche Zuordnung von Sounddateien zu den Soundindizes 1 bis 10 ist
keine Voraussetzung für die Veröffentlichung. Die Sounddateien werden vom
Anwender selbst ausgewählt und separat auf den JQ6500 übertragen.

## Freigabenachweis für den Releasekandidaten

Am 2. August 2026 wurde folgender Stand bestätigt:

- Windows-Anwendung mit PureBasic 6.40 für Windows x64 erstellt;
- erzeugte Release-EXE lokal unter Windows funktional geprüft;
- Release-EXE zusätzlich auf einem zweiten Windows-Rechner erfolgreich gestartet und funktional geprüft;
- Hardwareaufbau mit den beiden getrennten Widerständen R1 und R2 erfolgreich geprüft;
- R1: Nano D11 -> 1 kΩ -> JQ6500 RX;
- R2: JQ6500 BUSY -> 1 kΩ -> Nano A2;
- die BUSY-Rohwerte blieben mit eingebautem R2 unverändert:
  - Leerlauf: ungefähr 2 bis 3 ADC-Schritte;
  - Wiedergabe: ungefähr 537 bis 540 ADC-Schritte;
- die bestehenden Schaltschwellen 150 für BUSY-aus und 350 für BUSY-ein bleiben bestätigt;
- Dateiname der geprüften Release-Datei:
  `MOBA-Module-Soundmodul-1.0.0-Windows-x64.exe`;
- Dateigröße: 457728 Byte;
- SHA-256:
  `f7e7f848cc7c67181d3f7ac73f5abb816b72dacdd0afa2af39682b97c81c2946`;
- eingebettete Datei- und Produktversion: `1.0.0.0`;
- x64-Windows-GUI, DPI-Awareness, Ausführung als normaler Benutzer, ASLR und
  DEP/NX wurden statisch in der EXE bestätigt;
- Icon, Versionsressource und Anwendungsmanifest sind eingebettet;
- die Release-EXE ist nicht digital signiert. Windows SmartScreen kann deshalb
  auf Systemen ohne bestehende Dateireputation eine Warnung anzeigen.

## Allgemeiner Freigabenachweis

Für die Version 1.0.0 mindestens dokumentieren:

- Datum und Tester;
- verwendete Nano- und JQ6500-Variante;
- Prüfsumme der getesteten Firmware und EXE;
- gemessene BUSY-Werte im Leerlauf und während Wiedergabe;
- Ergebnis jedes Prüfpunkts;
- bekannte Einschränkungen.
