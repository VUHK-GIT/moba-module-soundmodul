# Windows-Anwendung erstellen

## Voraussetzungen

- Windows 10 oder Windows 11;
- PureBasic 6.10 LTS oder neuer, x64;
- Microsoft WebView2 Runtime;
- Python 3.10 oder neuer zum Erzeugen von
  `software/purebasic/ui/index.html`;
- vollständig ausgechecktes Repository.

## Erstellung

1. `python scripts/prepare_ui.py` ausführen. Ohne geschütztes Logo wird eine Textmarke verwendet.
2. `software/purebasic/MOBA_Module_Soundmodul.pb` in PureBasic öffnen.
3. Windows-x64-Compiler auswählen.
4. Programm kompilieren oder EXE erstellen.
5. Für eine offizielle Veröffentlichung kann über die PureBasic-IDE das
   geschützte Programmicon ergänzt werden. Das Icon ist nicht Bestandteil der
   MIT-Lizenz.

Die HTML-Oberfläche wird beim Kompilieren über PureBasic `IncludeBinary`
eingebettet. Neben der fertigen EXE werden keine externen UI-Dateien benötigt.

## Release-EXE

EXE-Dateien werden nicht in den Quellcode-Branch eingecheckt. Die fertige EXE
wird als Datei des GitHub-Releases mit dem Tag `v1.0.0` hochgeladen.

Empfohlene Dateinamen:

```text
MOBA-Module-Soundmodul-1.0.0-Windows-x64.exe
MOBA-Module-Soundmodul-1.0.0-source.zip
SHA256SUMS.txt
```
