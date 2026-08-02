# JQ6500-16P mit Sounddateien bespielen

## Grundsatz

Der JQ6500-16P besitzt einen internen Flash-Speicher. Die Nano-Firmware und die
Windows-Anwendung dieses Projekts übertragen **keine** Sounddateien. Das Modul
muss vor dem Einbau beziehungsweise vor der ersten Nutzung separat über seinen
USB-Anschluss bespielt werden.

Sounddateien sind nicht Bestandteil dieses Repositorys. Für verwendete Sounds
müssen die jeweiligen Urheber- und Nutzungsrechte beachtet werden.

## Vorgehen unter Windows

1. JQ6500-16P ausschließlich über seinen USB-Anschluss mit dem Windows-PC
   verbinden.
2. Den zum Modul gehörenden JQ6500-Uploader starten. Bei vielen Modulen erscheint
   dafür ein virtuelles CD-Laufwerk mit `MusicDownload.exe`.
3. Im Bereich `Files` die gewünschten MP3-Dateien auswählen.
4. Die Reihenfolge kontrollieren. Sie ist verbindlich für die späteren
   Soundindizes:

   ```text
   erste übertragene Datei  -> Sound 1
   zweite übertragene Datei -> Sound 2
   ...
   zehnte übertragene Datei -> Sound 10
   ```

5. Im Bereich `Flash` den Schreibvorgang starten und vollständig abwarten.
6. Das Modul sicher trennen und anschließend mit Lautsprecher oder über die
   MOBA-Module-Firmware testen.

## Wichtige Hinweise

- Der interne Speicher ist klein. Dateien bei Bedarf passend komprimieren.
- Die Projektsoftware liest keine Dateinamen aus dem internen Flash. Die
  Dateireihenfolge muss daher außerhalb des Moduls dokumentiert werden.
- Ein fehlender Soundindex kann dazu führen, dass ein Auslösebefehl keine
  Wiedergabe startet. Deshalb vor dem Release mindestens Sound 1 bis 3 und für
  den vollständigen Eingangstest Sound 1 bis 10 bereitstellen.
- Der Uploader ist Drittsoftware und wird nicht in diesem Repository verteilt.
- Nach einer Änderung der Soundreihenfolge müssen Bedienungs- und Testunterlagen
  entsprechend aktualisiert werden.

## Referenz

Weitere technische Hinweise zum JQ6500-Uploader stehen in
`docs/assets/wiring/SOURCES.md`.
