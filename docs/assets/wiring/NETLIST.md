# MOBA-Module Sound Module 1.0.0 – Authoritative wiring net list

Copyright (c) 2026 Sven Häber

| Net | From | To | Series component |
|---|---|---|---|
| `POWER_5V` | Nano 5V | JQ6500 pin 12 DC-5V | — |
| `POWER_GND` | Nano GND | JQ6500 pin 11 GND | — |
| `POWER_SGND` | Nano GND | JQ6500 pin 6 SGND | — |
| `UART_RX_NANO` | JQ6500 pin 10 TX | Nano D10 (SoftwareSerial RX) | — |
| `UART_TX_NANO` | Nano D11 (SoftwareSerial TX) | JQ6500 pin 9 RX | R1 1 kΩ |
| `BUSY_ANALOG` | JQ6500 pin 8 BUSY | Nano A2 | R2 1 kΩ |
| `SPEAKER_PLUS` | JQ6500 pin 16 SPK+ | Speaker + | — |
| `SPEAKER_MINUS` | JQ6500 pin 15 SPK- | Speaker − | — |
| `INPUT_1` | Nano D2 | IN1 switch/open collector → GND | — |
| `INPUT_2` | Nano D3 | IN2 switch/open collector → GND | — |
| `INPUT_3` | Nano D4 | IN3 switch/open collector → GND | — |
| `INPUT_4` | Nano D5 | IN4 switch/open collector → GND | — |
| `INPUT_5` | Nano D6 | IN5 switch/open collector → GND | — |
| `INPUT_6` | Nano D7 | IN6 switch/open collector → GND | — |
| `INPUT_7` | Nano D8 | IN7 switch/open collector → GND | — |
| `INPUT_8` | Nano D9 | IN8 switch/open collector → GND | — |
| `INPUT_9` | Nano A0 | IN9 switch/open collector → GND | — |
| `INPUT_10` | Nano A1 | IN10 switch/open collector → GND | — |

## Additional components

- C1: 470 µF / 10 V between +5 V and GND, mounted close to the JQ6500.
- C2: 100 nF between +5 V and GND, mounted close to the JQ6500.
- JQ6500 pin 6 SGND and pin 11 GND both connect to the common ground.
- Arduino Nano A3 remains unconnected and is used by the firmware as an additional random source.
- JQ6500 pins 1–5, pin 7 and pins 13/14 remain unconnected in this project.
- Never connect JQ6500 SPK+ or SPK− to GND.
