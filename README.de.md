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
- BUSY-Erkennung über Nano A2; die BUSY-Leitung enthält den externen
  Serienwiderstand **R2 mit 1 kΩ**;
- FIFO-Warteschlange mit Unterdrückung doppelter Einträge;
- automatischer Rückfall auf Hardwareeingänge beim Schließen, Absturz,
  Trennen oder Kommunikationsausfall der PC-Anwendung;
- deutsche Programmoberfläche;
- englische Bezeichner und Kommentare im Quellcode;
- deutsche und englische Dokumentation.

## Wichtiger Hinweis zu den Sounddateien

Der JQ6500-16P wird **nicht** durch die Nano-Firmware oder die Windows-Anwendung
mit Audiodateien befüllt. Vor der ersten Nutzung müssen die gewünschten Sounds
separat über den USB-Anschluss des JQ6500 in dessen internen Flash-Speicher
geschrieben werden. Die Reihenfolge beim Übertragen legt die Soundindizes fest:
die erste Datei ist Sound 1, die zweite Datei Sound 2 usw.

Das Repository enthält aus Lizenz- und Größengründen keine Sounddateien und
keinen proprietären JQ6500-Uploader. Siehe
[docs/de/jq6500-sounds.md](docs/de/jq6500-sounds.md).

## Verzeichnisstruktur

```text
firmware/                 Firmware für den Arduino Nano
software/purebasic/       Quellcode der Windows-Anwendung
software/purebasic/ui/    Deutsche UI-Vorlage und modulare CSS/JavaScript-Quellen
docs/en/                  Englische Dokumentation
docs/de/                  Deutsche Dokumentation
docs/assets/wiring/       Verbindliche SVG-Verdrahtungspläne und Netzliste
scripts/                  Prüf- und Paketwerkzeuge
tests/firmware_host/      Arduino-Kompatibilitätsstubs für den Hosttest
```

## Schnellstart

1. Den JQ6500-16P separat per USB mit den gewünschten Sounds bespielen. Die
   Dateireihenfolge als Zuordnung Sound 1 bis Sound 10 dokumentieren.
2. Arduino Nano, JQ6500-16P und die zehn Eingänge nach
   [docs/de/hardware.md](docs/de/hardware.md) verdrahten. Dabei sind **zwei
   getrennte 1-kΩ-Widerstände** erforderlich: R1 in der RX-Leitung und R2 in
   der BUSY-Leitung zu A2.
3. Die externe Arduino-Bibliothek `JQ6500_Serial` installieren.
4. Die Datei
   `firmware/MOBA_Module_Soundmodul_Nano/MOBA_Module_Soundmodul_Nano.ino`
   hochladen.
5. `python scripts/prepare_ui.py` ausführen, um die eingebettete Oberfläche zu
   erzeugen. Das offizielle Logo nur für einen autorisierten Markenbuild vorher
   lokal ergänzen.
6. Die Windows-Anwendung mit PureBasic 6.10 LTS oder neuer aus
   `software/purebasic/MOBA_Module_Soundmodul.pb` erstellen.
7. Anwendung starten. Die vorhandenen COM-Ports werden automatisch geprüft.

Ausführliche Bauanleitung: [docs/de/build-windows.md](docs/de/build-windows.md)

## Downloads

Offizielle Windows-EXE-Dateien werden als Dateien des jeweiligen GitHub-Releases
bereitgestellt. Sie werden nicht in den Quellcode-Branch eingecheckt.

Die offizielle Version `1.0.0` wird als Windows-x64-EXE veröffentlicht. Die EXE
ist zunächst nicht digital signiert; Windows SmartScreen kann deshalb auf
Systemen ohne bestehende Dateireputation eine Warnung anzeigen. Die
veröffentlichte SHA-256-Prüfsumme dient zur Integritätskontrolle.

## Lizenz

Quellcode und Dokumentation stehen unter der [MIT-Lizenz](LICENSE).

Name, Logo und Icon von MOBA-Module sind **nicht** Bestandteil der MIT-Lizenz.
Siehe [TRADEMARKS.md](TRADEMARKS.md) und [ASSETS.md](ASSETS.md).

Hinweise zu Drittkomponenten stehen in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## Status

Version 1.0.0 wurde mit PureBasic 6.40 für Windows x64 erstellt und auf der
Projekt-Hardware mit R1 und R2 funktional geprüft. Der Release-Branch bleibt bis
zum Abschluss der letzten Veröffentlichungsprüfungen privat.
