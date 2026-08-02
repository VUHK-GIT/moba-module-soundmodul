# Veröffentlichungsablauf

1. Hardwaretests aus `docs/de/testing.md` vollständig durchführen.
2. Bei Bedarf offizielles Logo und Icon lokal ergänzen und danach
   `python scripts/prepare_ui.py` ausführen.
3. Windows-x64-EXE mit PureBasic erstellen.
4. `python scripts/validate.py` ausführen.
5. `python scripts/package_source.py` ausführen.
6. Geprüften Release-Pull-Request nach `main` übernehmen.
7. Tag `v1.0.0` auf dem geprüften Commit erstellen.
8. GitHub-Release für `v1.0.0` anlegen.
9. Windows-EXE, Quellcode-ZIP und `SHA256SUMS.txt` als Release-Dateien
   hochladen.
10. Repository erst nach der abschließenden Prüfung von privat auf öffentlich
    umstellen.

Die EXE gehört in das GitHub-Release und nicht in die Git-Historie.
