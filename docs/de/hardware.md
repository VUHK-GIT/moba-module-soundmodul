# Hardware und Verdrahtung

## Benötigte Komponenten

- Arduino Nano mit ATmega328P;
- JQ6500-16P mit internem Flash-Speicher;
- ein Widerstand 1 kOhm in der Leitung vom Nano zum JQ6500-RX;
- geeigneter Lautsprecher;
- bis zu zehn Schalter oder externe Open-Collector-Kontakte;
- gemeinsame Masse zwischen Nano, JQ6500 und externen Eingängen.

## JQ6500-Verbindung

```text
JQ6500 TX   -> Nano D10
Nano D11    -> 1 kOhm -> JQ6500 RX
JQ6500 BUSY -> Nano A2
JQ6500 GND  -> Nano GND
```

## Hardwareeingänge

```text
IN1  -> D2
IN2  -> D3
IN3  -> D4
IN4  -> D5
IN5  -> D6
IN6  -> D7
IN7  -> D8
IN8  -> D9
IN9  -> A0
IN10 -> A1
```

Jeder Schalter wird zwischen Eingang und GND angeschlossen. Die Firmware
verwendet `INPUT_PULLUP`; ein Eingang ist daher aktiv, wenn er gegen GND gezogen
wird.

A3 bleibt unbeschaltet und dient als zusätzliche Zufallsquelle.

## Bestätigte BUSY-Werte

Auf der Zielhardware gemessene Werte:

- Wiedergabe: ungefähr 537 bis 540 ADC-Schritte;
- Leerlauf: ungefähr 2 bis 3 ADC-Schritte.

Die Firmware verwendet 350 als Einschalt- und 150 als Ausschaltschwelle sowie
30 ms Entprellung.
