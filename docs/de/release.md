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

## Noch vor dem Merge

1. Reihenfolge der verwendeten Sounddateien 1 bis 10 dokumentieren.
2. Deutsche und englische Dokumentation abschließend lesen.
3. Marken- und Logoausnahme abschließend prüfen.
4. `python scripts/validate.py` auf dem finalen Branch ausführen.
5. `python scripts/package_source.py` ausführen.
6. Finale Release-Dateien und Prüfsummen zusammenstellen.
7. Draft-Pull-Request auf `Ready for review` setzen.
8. Pull Request per `Squash and merge` nach `main` übernehmen.

## Tag und GitHub-Release

Nach dem Merge:

1. annotierten Tag `v1.0.0` auf dem neuen `main`-Commit erstellen;
2. GitHub-Release zunächst als Draft anlegen;
3. folgende Dateien hochladen:

```text
MOBA-Module-Soundmodul-1.0.0-Windows-x64.exe
MOBA-Module-Soundmodul-1.0.0-source.zip
moba-module-soundmodul-wiring-de.png
moba-module-soundmodul-wiring-en.png
SHA256SUMS.txt
```

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
