# MOBA-Module Soundmodul

[English documentation](README.md)

Version **1.0.0** ist die erste stabile Open-Source-Version einer
Soundsteuerung für die Modellbahn auf Basis eines Arduino Nano und eines
JQ6500-16P. Der Nano arbeitet autonom und übernimmt Hardwareeingänge,
Wiedergabestatus, Konfigurationsspeicherung, Automatik und FIFO-Warteschlange.
Eine Windows-Anwendung dient zur Konfiguration, manuellen Wiedergabe und
Diagnose.

## Hauptfunktionen

- zehn Hardwareeingänge für Soundindex 1 bis 10;
- Windows-Steuerungssoftware in PureBasic;
- automatische COM-Port-Suche und manuelle Portauswahl;
- dauerhafte Konfiguration im EEPROM des Nano;
- Dauer-, Zufalls- und Intervallwiedergabe;
- BUSY-Erkennung über den real gemessenen Analogwert an Nano A2;
- FIFO-Warteschlange mit Unterdrückung doppelter Einträge;
- automatischer Rückfall auf Hardwareeingänge beim Schließen, Absturz,
  Trennen oder Kommunikationsausfall der PC-Anwendung;
- deutsche Programmoberfläche;
- englische Bezeichner und Kommentare im Quellcode;
- deutsche und englische Dokumentation.

## Verzeichnisstruktur

```text
firmware/                 Firmware für den Arduino Nano
software/purebasic/       Quellcode der Windows-Anwendung
software/purebasic/ui/    Deutsche UI-Vorlage und modulare CSS/JavaScript-Quellen
docs/en/                  Englische Dokumentation
docs/de/                  Deutsche Dokumentation
scripts/                  Prüf- und Paketwerkzeuge
tests/firmware_host/      Arduino-Kompatibilitätsstubs für den Hosttest
```

## Schnellstart

1. Arduino Nano, JQ6500-16P und die zehn Eingänge nach
   [docs/de/hardware.md](docs/de/hardware.md) verdrahten.
2. Die externe Arduino-Bibliothek `JQ6500_Serial` installieren.
3. Die Datei
   `firmware/MOBA_Module_Soundmodul_Nano/MOBA_Module_Soundmodul_Nano.ino`
   hochladen.
4. `python scripts/prepare_ui.py` ausführen, um die eingebettete Oberfläche zu erzeugen.
   Das offizielle Logo nur für einen autorisierten Markenbuild vorher lokal ergänzen.
5. Die Windows-Anwendung mit PureBasic 6.10 LTS oder neuer aus
   `software/purebasic/MOBA_Module_Soundmodul.pb` erstellen.
6. Anwendung starten. Die vorhandenen COM-Ports werden automatisch geprüft.

Ausführliche Bauanleitung: [docs/de/build-windows.md](docs/de/build-windows.md)

## Downloads

Offizielle Windows-EXE-Dateien werden als Dateien des jeweiligen GitHub-Releases
bereitgestellt. Sie werden nicht in den Quellcode-Branch eingecheckt.

## Lizenz

Quellcode und Dokumentation stehen unter der [MIT-Lizenz](LICENSE).

Name, Logo und Icon von MOBA-Module sind **nicht** Bestandteil der MIT-Lizenz.
Siehe [TRADEMARKS.md](TRADEMARKS.md) und [ASSETS.md](ASSETS.md).

Hinweise zu Drittkomponenten stehen in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
