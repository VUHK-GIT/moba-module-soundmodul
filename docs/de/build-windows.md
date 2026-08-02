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
4. DPI-Awareness, Unterstützung moderner Windows-Themes, Ausführung im
   Benutzermodus, DLL-Preloading-Schutz und gemeinsame UCRT aktivieren.
5. Für die Release-EXE den Debugger deaktivieren.
6. Versionsinformationen aktivieren und Datei- sowie Produktversion auf
   `1.0.0.0` setzen.
7. Die EXE als `MOBA-Module-Soundmodul-1.0.0-Windows-x64.exe` erstellen.
8. Für eine offizielle Veröffentlichung kann über die PureBasic-IDE das
   geschützte Programmicon ergänzt werden. Das Icon ist nicht Bestandteil der
   MIT-Lizenz.

Die HTML-Oberfläche wird beim Kompilieren über PureBasic `IncludeBinary`
eingebettet. Neben der fertigen EXE werden keine externen UI-Dateien benötigt.

## Geprüfter Release-Build

Der Releasekandidat 1.0.0 wurde mit PureBasic 6.40 für Windows x64 erstellt und
auf dem Projektsystem funktional geprüft. Für die erzeugte EXE wurden folgende
Eigenschaften bestätigt:

- PE32+ Windows-x86-64-GUI-Anwendung;
- eingebettetes Icon, Versionsressource und Anwendungsmanifest;
- Datei- und Produktversion `1.0.0.0`;
- Ausführung als normaler Benutzer (`asInvoker`);
- DPI-Awareness aktiviert;
- ASLR und DEP/NX aktiviert;
- gemeinsame Windows-UCRT wird verwendet;
- keine Authenticode-Signatur.

Die fehlende digitale Signatur ist für die erste Veröffentlichung beabsichtigt.
Windows SmartScreen kann deshalb auf Systemen ohne bestehende Dateireputation
eine Warnung anzeigen. Nutzer sollen die veröffentlichte SHA-256-Prüfsumme
kontrollieren.

## Release-EXE

EXE-Dateien werden nicht in den Quellcode-Branch eingecheckt. Die fertige EXE
wird als Datei des GitHub-Releases mit dem Tag `v1.0.0` hochgeladen.

Empfohlene Dateinamen:

```text
MOBA-Module-Soundmodul-1.0.0-Windows-x64.exe
MOBA-Module-Soundmodul-1.0.0-source.zip
SHA256SUMS.txt
```
