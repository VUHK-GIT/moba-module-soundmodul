# Veröffentlichung von Version 1.0.0

## Grundsatz

Die Veröffentlichung erfolgt kontrolliert aus dem Branch
`release/1.0.0-open-source`. Das Repository bleibt bis zur finalen Abnahme
privat. Binärdateien, Sounddateien und geschützte Markenassets werden nicht in
den Quellcode-Branch eingecheckt.

## Bestätigter Releasekandidat

Für den Releasekandidaten wurde bestätigt:

- PureBasic 6.40, Windows x64;
- Hardwaretest mit R1 und R2 jeweils 1 kΩ bestanden;
- BUSY-Werte mit R2 unverändert und bestätigt:
  - Leerlauf ungefähr 2 bis 3 ADC-Schritte;
  - Wiedergabe ungefähr 537 bis 540 ADC-Schritte;
- EXE lokal auf dem Build-System getestet;
- EXE zusätzlich auf einem zweiten Windows-Rechner erfolgreich getestet;
- geprüfte EXE:
  `MOBA-Module-Soundmodul-1.0.0-Windows-x64.exe`;
- SHA-256:
  `f7e7f848cc7c67181d3f7ac73f5abb816b72dacdd0afa2af39682b97c81c2946`.

Eine namentliche Zuordnung von Sounddateien zu den Soundindizes 1 bis 10 ist
keine Voraussetzung für Version 1.0.0. Anwender wählen und übertragen ihre
Sounddateien selbst.

## Noch vor dem Merge

1. Draft-Pull-Request auf `Ready for review` setzen.
2. Pull Request per `Squash and merge` nach `main` übernehmen.

## Tag und GitHub-Release

Nach dem Merge:

1. auf GitHub ein neues Release anlegen und dabei den Tag `v1.0.0` auf dem
   neuen `main`-Commit erstellen;
2. Release zunächst als Draft speichern;
3. folgende Dateien hochladen:

```text
MOBA-Module-Soundmodul-1.0.0-Windows-x64.exe
moba-module-soundmodul-wiring-de.png
moba-module-soundmodul-wiring-en.png
SHA256SUMS.txt
```

GitHub stellt für den Tag automatisch Quellcodearchive als ZIP und TAR.GZ bereit.
Ein zusätzlich manuell erzeugtes Quellcode-ZIP ist für die Veröffentlichung
nicht erforderlich. `scripts/package_source.py` bleibt als optionales Werkzeug
für lokale, reproduzierbare Pakete erhalten.

4. Releasebeschreibung und Prüfsummen kontrollieren;
5. Release veröffentlichen;
6. Repository erst danach auf öffentlich umstellen;
7. abgemeldet prüfen, ob README, Lizenz, Dokumentation und Downloads korrekt
   erreichbar sind.

## Nicht in Git einchecken

- Windows-EXE;
- ZIP-Releasepakete;
- MP3- oder WAV-Dateien;
- proprietäre Uploader;
- offizielles MOBA-Module-Logo oder Icon als frei nutzbares Einzelasset.
