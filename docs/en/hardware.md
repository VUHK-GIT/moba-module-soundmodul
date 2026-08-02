# Hardware and wiring

## Required components

- Arduino Nano compatible with ATmega328P;
- JQ6500-16P audio module with internal flash;
- one 1 kOhm resistor in the Nano-to-JQ6500 RX line;
- speaker suitable for the JQ6500 output;
- up to ten switches or external open-collector contacts;
- common ground between Nano, JQ6500 and external inputs.

## JQ6500 connection

```text
JQ6500 TX   -> Nano D10
Nano D11    -> 1 kOhm -> JQ6500 RX
JQ6500 BUSY -> Nano A2
JQ6500 GND  -> Nano GND
```

## Hardware inputs

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

Connect each switch between its input and GND. The firmware enables
`INPUT_PULLUP`, so an input is active when pulled low.

A3 remains unconnected and is used as an additional random seed source.

## Confirmed BUSY values

Values measured on the target hardware:

- playing: approximately 537 to 540 ADC counts;
- idle: approximately 2 to 3 ADC counts.

Firmware thresholds are 350 for BUSY on and 150 for BUSY off, with 30 ms
debouncing.
