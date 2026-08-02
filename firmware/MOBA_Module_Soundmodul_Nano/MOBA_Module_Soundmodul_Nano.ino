/*
 * SPDX-License-Identifier: MIT
 * Copyright (c) 2026 Sven Häber
 *
 * MOBA-Module Sound Module firmware 1.0.0
 * Arduino Nano + JQ6500-16P
 *
 * Design principles:
 * - The Nano is the autonomous runtime controller.
 * - Configuration is stored in EEPROM.
 * - The JQ6500 BUSY signal is sampled as an analog value on A2.
 * - A playing sound is never replaced by another sound.
 * - Automatic and hardware-input triggers share one FIFO queue.
 * - A sound can occur only once in playback or in the queue, preventing an
 *   uncontrolled backlog.
 * - During STARTING or PLAYING, the firmware accepts only STATUS, IDENTIFY,
 *   PING, VOLUME and RESET as controlling PC commands.
 * - RESET clears the queue and disables automation.
 *
 * Operating modes:
 * SOFTWARE:
 *   Manual PC playback plus permanent, random and interval automation.
 *   Hardware inputs are ignored while the PC session is active.
 * INPUTS:
 *   IN1 through IN10 trigger sound indexes 1 through 10.
 *   Software automation and manual PLAY commands are disabled.
 *
 * Wiring:
 *   JQ6500 TX   -> Nano D10
 *   Nano D11    -> 1 kOhm resistor -> JQ6500 RX
 *   JQ6500 BUSY -> Nano A2
 *   JQ6500 GND  -> Nano GND
 *
 *   IN1..IN8 -> D2..D9
 *   IN9      -> A0
 *   IN10     -> A1
 *   Connect switches between an input and GND; INPUT_PULLUP is enabled.
 *
 * The MOBA-Module name and logo are not licensed under the MIT License.
 * See TRADEMARKS.md.
 */

#include <Arduino.h>
#include <EEPROM.h>
#include <SoftwareSerial.h>
#include <JQ6500_Serial.h>
#include <stddef.h>

namespace {

#include "src/Core.hpp"
#include "src/Queue.hpp"
#include "src/Scheduler.hpp"
#include "src/Playback.hpp"
#include "src/Protocol.hpp"

}  // namespace

void setup() {
  Serial.begin(PC_BAUD);
  jqSerial.begin(JQ_BAUD);
  jqSerial.listen();

  pinMode(JQ_BUSY_PIN, INPUT);
  pinMode(RANDOM_SEED_PIN, INPUT);

  initializeInputs();
  loadConfig();

  pcSessionActive = false;
  lastPcActivityAt = 0;

  if (config.automationEnabled != 0U) {
    config.automationEnabled = 0;
    saveConfig();
  }

  randomSeed(
    static_cast<unsigned long>(analogRead(RANDOM_SEED_PIN)) ^
    micros()
  );

  delay(250);
  initializeJq6500(false);
  initializeAutomation(millis());
  dispatchNext();

  printIdentity();
  printConfiguration();
  printStatus();
}

void loop() {
  const unsigned long now = millis();

  sampleBusy(now);
  readPcCommands();
  checkPcSessionTimeout(now);
  sampleInputs(now);
  processScheduler(now);
  dispatchNext();
}
