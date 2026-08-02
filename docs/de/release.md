# Veröffentlichungsablauf 1.0.0

## Phase 1 – Release Candidate auf dem privaten Repository

1. Branch `release/1.0.0-open-source` auf den letzten Stand bringen.
2. `python scripts/validate.py` ausführen und GitHub Actions abwarten.
3. JQ6500 mit einer dokumentierten Reihenfolge Sound 1 bis 10 bespielen.
4. Hardware einschließlich R1 und R2 nach `docs/de/hardware.md` aufbauen.
5. Hardwaretests aus `docs/de/testing.md` vollständig durchführen.
6. Windows-x64-EXE mit PureBasic erstellen.
7. EXE auf einem zweiten Windows-System beziehungsweise einer sauberen
   Benutzerumgebung starten und COM-Verbindung sowie WebView2 prüfen.
8. `python scripts/package_source.py` ausführen.
9. SHA-256 für EXE, Quellcode-ZIP und weitere Release-Dateien erzeugen.
10. Ergebnisse und bekannte Einschränkungen im Draft-Pull-Request dokumentieren.

## Phase 2 – Pull Request freigeben

1. Alle offenen Prüfpunkte im Draft-Pull-Request kontrollieren.
2. Keine EXE, kein proprietäres Logo und keine Sounddateien im Quell-Branch.
3. Pull Request von `Draft` auf `Ready for review` setzen.
4. Diff und Dateiliste abschließend prüfen.
5. Pull Request vorzugsweise per **Squash merge** nach `main` übernehmen, damit
   die erste öffentliche Version einen klaren Release-Commit erhält.

## Phase 3 – Tag und GitHub-Release

1. Auf dem geprüften Merge-Commit den signierten oder annotierten Tag `v1.0.0`
   anlegen.
2. GitHub-Release zunächst als Draft erstellen.
3. Folgende Dateien hochladen:

   ```text
   MOBA-Module-Soundmodul-1.0.0-Windows-x64.exe
   MOBA-Module-Soundmodul-1.0.0-source.zip
   moba-module-soundmodul-wiring-de.png
   moba-module-soundmodul-wiring-en.png
   SHA256SUMS.txt
   ```

4. Release-Text aus `CHANGELOG.de.md` und `CHANGELOG.md` erstellen.
5. Prüfsummen herunterladen und unabhängig kontrollieren.
6. GitHub-Release veröffentlichen.

## Phase 4 – Repository öffentlich machen

Erst nach veröffentlichtem Release:

1. Repository-Einstellungen öffnen.
2. Unter `Settings → General → Danger Zone → Change repository visibility`
   das Repository von `Private` auf `Public` umstellen.
3. Den von GitHub geforderten Repository-Namen zur Bestätigung eingeben.
4. Danach ohne Anmeldung prüfen:
   - README und Lizenz sichtbar;
   - Release `v1.0.0` erreichbar;
   - EXE und Prüfsummen herunterladbar;
   - Verdrahtungs-SVGs werden dargestellt;
   - Issues und Security-Hinweise funktionieren;
   - geschützte Markenassets wurden nicht versehentlich veröffentlicht.

Die EXE gehört in das GitHub-Release und nicht in die Git-Historie.
