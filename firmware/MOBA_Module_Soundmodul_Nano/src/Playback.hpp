// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Sven Häber

bool rawMeansBusy(int rawValue, bool currentState) {
  if (currentState) {
    return rawValue > BUSY_OFF_THRESHOLD;
  }

  return rawValue >= BUSY_ON_THRESHOLD;
}

void setReadyState() {
  playerState = PlayerState::Ready;
  currentSound = 0;
  currentTrigger = Trigger::None;
  currentInput = 0;
  busyWasSeen = false;
}

void printIdentity() {
  Serial.print(F("MMSM-NANO "));
  Serial.print(FIRMWARE_VERSION);
  Serial.print(F(" STATE="));
  Serial.print(stateText(playerState));
  Serial.print(F(" SESSION="));
  Serial.print(pcSessionActive ? 1 : 0);
  Serial.print(F(" MODE="));
  Serial.print(modeText(controlMode()));
  Serial.print(F(" CONFIGURED_MODE="));
  Serial.print(modeText(configuredControlMode()));
  Serial.print(F(" AUTOMATION="));
  Serial.print(config.automationEnabled);
  Serial.print(F(" VOLUME="));
  Serial.println(selectedVolume);
}

void printSettings() {
  Serial.print(F("SETTINGS SESSION="));
  Serial.print(pcSessionActive ? 1 : 0);
  Serial.print(F(" MODE="));
  Serial.print(modeText(controlMode()));
  Serial.print(F(" CONFIGURED_MODE="));
  Serial.print(modeText(configuredControlMode()));
  Serial.print(F(" AUTOMATION="));
  Serial.print(config.automationEnabled);
  Serial.print(F(" RANDOM_MIN_SECONDS="));
  Serial.print(config.randomSecondsMin);
  Serial.print(F(" RANDOM_MAX_SECONDS="));
  Serial.print(config.randomSecondsMax);
  Serial.print(F(" VOLUME="));
  Serial.println(selectedVolume);
}

void printConfiguration() {
  printSettings();

  for (uint8_t index = 0; index < SOUND_COUNT; ++index) {
    const SoundConfig& sound = config.sound[index];

    Serial.print(F("CONFIG SOUND="));
    Serial.print(index + 1U);
    Serial.print(F(" PERMANENT="));
    Serial.print((sound.flags & FLAG_PERMANENT) != 0U ? 1 : 0);
    Serial.print(F(" RANDOM="));
    Serial.print((sound.flags & FLAG_RANDOM) != 0U ? 1 : 0);
    Serial.print(F(" INTERVAL="));
    Serial.print((sound.flags & FLAG_INTERVAL) != 0U ? 1 : 0);
    Serial.print(F(" INTERVAL_SECONDS="));
    Serial.println(sound.intervalSeconds);
  }

  emitQueue();
}

void printStatus() {
  Serial.print(F("STATUS STATE="));
  Serial.print(stateText(playerState));
  Serial.print(F(" SESSION="));
  Serial.print(pcSessionActive ? 1 : 0);
  Serial.print(F(" BUSY="));
  Serial.print(busyStable ? 1 : 0);
  Serial.print(F(" BUSY_RAW="));
  Serial.print(busyRaw);
  Serial.print(F(" CURRENT="));
  Serial.print(currentSound);
  Serial.print(F(" TRIGGER="));
  Serial.print(triggerText(currentTrigger));
  Serial.print(F(" INPUT="));
  Serial.print(currentInput);
  Serial.print(F(" VOLUME="));
  Serial.print(selectedVolume);
  Serial.print(F(" MODE="));
  Serial.print(modeText(controlMode()));
  Serial.print(F(" CONFIGURED_MODE="));
  Serial.print(modeText(configuredControlMode()));
  Serial.print(F(" AUTOMATION="));
  Serial.print(config.automationEnabled);
  Serial.print(F(" QUEUE_COUNT="));
  Serial.print(queueCount);
  Serial.print(F(" INPUT_MASK="));
  Serial.print(inputMask());
  Serial.print(F(" UPTIME="));
  Serial.println(millis());
}

void initializeJq6500(bool announceReset) {
  if (announceReset) {
    Serial.print(F("EVENT RESET START PREVIOUS="));
    Serial.println(currentSound);
  }

  playerState = PlayerState::Resetting;
  busyWasSeen = false;

  mp3.reset();
  mp3.setSource(MP3_SRC_BUILTIN);
  mp3.setLoopMode(MP3_LOOP_ONE_STOP);
  mp3.setVolume(selectedVolume);
  delay(100);

  busyRaw = analogRead(JQ_BUSY_PIN);
  busyStable = rawMeansBusy(busyRaw, false);
  busyCandidate = busyStable;
  busyCandidateSince = millis();

  setReadyState();

  if (announceReset) {
    Serial.print(F("EVENT RESET DONE VOLUME="));
    Serial.println(selectedVolume);
    printStatus();
    emitQueue();
  }
}

void enterStandaloneInputs(const char* reason) {
  const bool stopRequired =
    playerState == PlayerState::Starting ||
    playerState == PlayerState::Playing ||
    playerState == PlayerState::Resetting ||
    busyStable;

  pcSessionActive = false;
  lastPcActivityAt = 0;

  if (config.automationEnabled != 0U) {
    config.automationEnabled = 0;
    saveConfig();
  }

  clearQueue();
  resetSchedules();

  if (stopRequired) {
    /*
      The JQ6500 does not provide a reliable immediate STOP command.
      Reset is therefore the only confirmed safe abort mechanism.
    */
    initializeJq6500(false);
  } else {
    setReadyState();
  }

  Serial.print(F("EVENT STANDALONE MODE=INPUTS REASON="));
  Serial.println(reason);
  printSettings();
  printStatus();
  emitQueue();
}

void beginPcSession() {
  pcSessionActive = true;
  lastPcActivityAt = millis();

  /*
    Starting a PC session discards pending hardware-input requests. A sound
    that is already playing may finish normally; the GUI detects it through
    the BUSY signal.
  */
  clearQueue();
  resetSchedules();

  if (config.automationEnabled != 0U) {
    config.automationEnabled = 0;
    saveConfig();
  }

  Serial.println(F("OK SESSION ACTIVE=1"));
  printSettings();
  printStatus();
  emitQueue();
}

void checkPcSessionTimeout(unsigned long now) {
  if (
    pcSessionActive &&
    timeReached(now, lastPcActivityAt + PC_SESSION_TIMEOUT_MS)
  ) {
    enterStandaloneInputs("TIMEOUT");
  }
}


void startPlayback(const QueueItem& item) {
  currentSound = item.sound;
  currentTrigger = item.trigger;
  currentInput = item.input;
  playerState = PlayerState::Starting;
  busyWasSeen = false;
  playCommandAt = millis();

  mp3.playFileByIndexNumber(currentSound);

  Serial.print(F("OK PLAY INDEX="));
  Serial.print(currentSound);
  Serial.print(F(" TRIGGER="));
  Serial.print(triggerText(currentTrigger));
  Serial.print(F(" INPUT="));
  Serial.println(currentInput);
}

void dispatchNext() {
  if (
    playerState != PlayerState::Ready ||
    busyStable ||
    queueCount == 0U
  ) {
    return;
  }

  QueueItem item;

  if (!dequeueSound(item)) {
    return;
  }

  emitQueue();
  startPlayback(item);
}

void handleBusyTransition(bool newState) {
  busyStable = newState;

  if (busyStable) {
    if (playerState == PlayerState::Starting) {
      busyWasSeen = true;
      playerState = PlayerState::Playing;

      Serial.print(F("EVENT START INDEX="));
      Serial.print(currentSound);
      Serial.print(F(" TRIGGER="));
      Serial.print(triggerText(currentTrigger));
      Serial.print(F(" INPUT="));
      Serial.println(currentInput);
    }

    return;
  }

  if (playerState == PlayerState::Playing && busyWasSeen) {
    const uint8_t endedSound = currentSound;
    const Trigger endedTrigger = currentTrigger;

    Serial.print(F("EVENT END INDEX="));
    Serial.print(endedSound);
    Serial.print(F(" TRIGGER="));
    Serial.println(triggerText(endedTrigger));

    setReadyState();

    if (
      automationActive() &&
      (config.sound[endedSound - 1U].flags & FLAG_PERMANENT) != 0U
    ) {
      enqueueSound(endedSound, Trigger::Permanent);
    }

    dispatchNext();
    printStatus();
  }
}

void sampleBusy(unsigned long now) {
  if (!timeReached(now, lastBusySampleAt + BUSY_SAMPLE_MS)) {
    return;
  }

  lastBusySampleAt = now;
  busyRaw = analogRead(JQ_BUSY_PIN);

  const bool measuredState = rawMeansBusy(busyRaw, busyStable);

  if (measuredState != busyCandidate) {
    busyCandidate = measuredState;
    busyCandidateSince = now;
  }

  if (
    busyCandidate != busyStable &&
    timeReached(now, busyCandidateSince + BUSY_DEBOUNCE_MS)
  ) {
    handleBusyTransition(busyCandidate);
  }

  if (
    playerState == PlayerState::Starting &&
    !busyWasSeen &&
    timeReached(now, playCommandAt + BUSY_START_TIMEOUT_MS)
  ) {
    const uint8_t failedSound = currentSound;

    Serial.print(F("ERROR START_TIMEOUT INDEX="));
    Serial.print(failedSound);
    Serial.print(F(" BUSY_RAW="));
    Serial.println(busyRaw);

    setReadyState();
    dispatchNext();
    printStatus();
  }
}

void handleInputPress(uint8_t inputIndex) {
  const uint8_t inputNumber = static_cast<uint8_t>(inputIndex + 1U);

  if (controlMode() != ControlMode::Inputs) {
    Serial.print(F("EVENT INPUT_IGNORED INPUT="));
    Serial.print(inputNumber);
    Serial.println(F(" REASON=MODE_SOFTWARE"));
    return;
  }

  if (playerState == PlayerState::Resetting) {
    Serial.print(F("EVENT INPUT_IGNORED INPUT="));
    Serial.print(inputNumber);
    Serial.println(F(" REASON=RESETTING"));
    return;
  }

  if (enqueueSound(
    inputNumber,
    Trigger::Input,
    inputNumber
  )) {
    Serial.print(F("EVENT INPUT_QUEUED INPUT="));
    Serial.println(inputNumber);
  }

  dispatchNext();
}

void sampleInputs(unsigned long now) {
  for (uint8_t index = 0; index < INPUT_COUNT; ++index) {
    const bool pressed = digitalRead(INPUT_PINS[index]) == LOW;

    if (pressed != inputCandidate[index]) {
      inputCandidate[index] = pressed;
      inputCandidateSince[index] = now;
    }

    if (
      inputCandidate[index] != inputStable[index] &&
      timeReached(now, inputCandidateSince[index] + INPUT_DEBOUNCE_MS)
    ) {
      inputStable[index] = inputCandidate[index];

      if (inputStable[index]) {
        handleInputPress(index);
      }
    }
  }
}

void processScheduler(unsigned long now) {
  if (!timeReached(now, lastSchedulerAt + SCHEDULER_INTERVAL_MS)) {
    return;
  }

  lastSchedulerAt = now;

  if (!automationActive()) {
    return;
  }

  for (uint8_t index = 0; index < SOUND_COUNT; ++index) {
    const uint8_t sound = static_cast<uint8_t>(index + 1U);
    const SoundConfig& soundConfig = config.sound[index];

    if (
      (soundConfig.flags & FLAG_RANDOM) != 0U &&
      nextRandomAt[index] != 0U &&
      timeReached(now, nextRandomAt[index])
    ) {
      enqueueSound(sound, Trigger::Random);
      scheduleRandom(index, now);
    }

    if (
      (soundConfig.flags & FLAG_INTERVAL) != 0U &&
      nextIntervalAt[index] != 0U &&
      timeReached(now, nextIntervalAt[index])
    ) {
      enqueueSound(sound, Trigger::Interval);
      scheduleInterval(index, now);
    }
  }

  dispatchNext();
}
