# Bedienungsanleitung

Die Programmoberfläche ist in Version 1.0.0 deutsch.

## Verbindung

Beim Start prüft die Anwendung alle vorhandenen COM-Ports. Wird der Nano an
einen anderen USB-Anschluss gesteckt, `COM-Ports neu suchen` verwenden oder
einen Port auswählen und `Verbinden` anklicken.

## Betriebsarten

- `Software`: manuelle Wiedergabe und Automatik werden vom PC gesteuert.
- `Eingänge`: die zehn Hardwareeingänge lösen die Sounds direkt aus.

Ohne aktive PC-Sitzung arbeitet der Nano immer im Eingangsmodus.

## Automatik

Jeder Sound kann konfiguriert werden für:

- dauerhafte Wiederholung nach natürlichem Ende;
- zufällige Auslösung innerhalb des globalen Zufallsbereichs;
- Auslösung in einem festen Intervall.

Neue Anforderungen gelangen in die FIFO-Warteschlange. Derselbe Sound wird
nicht mehrfach eingereiht.

## Rücksetzen

`Wiedergabe zurücksetzen` beendet den aktuellen Sound per JQ6500-Reset, leert
die Warteschlange und deaktiviert die Automatik. Dabei kann ein kurzes Knacken
hörbar sein.
