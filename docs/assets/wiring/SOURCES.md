# Pinout and wiring references

The diagram is constructed from an explicit net list and was cross-checked
against the following references:

- Arduino Nano official documentation and downloadable pinout:
  https://docs.arduino.cc/hardware/nano/
- JQ6500-16P pin description:
  https://xpart.org/product/jq6500-voice-sound-module/
- JQ6500 wiring notes and serial-interface guidance:
  https://sparks.gogo.co.nz/jq6500/index.html

Project-specific measured/tested wiring:

- Arduino Nano D11 -> R1 1 kΩ -> JQ6500 RX
- JQ6500 BUSY -> R2 1 kΩ -> Arduino Nano A2

The two 1 kΩ resistors are separate components and are shown separately in the
authoritative SVG artwork and net list.
