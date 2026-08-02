// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Sven Häber

bool parseUnsigned(
  const char* text,
  uint16_t minimum,
  uint16_t maximum,
  uint16_t& result
) {
  while (*text == ' ') {
    ++text;
  }

  if (*text == '\0') {
    return false;
  }

  char* endPointer = nullptr;
  const unsigned long value = strtoul(text, &endPointer, 10);

  while (endPointer != nullptr && *endPointer == ' ') {
    ++endPointer;
  }

  if (
    endPointer == nullptr ||
    endPointer == text ||
    *endPointer != '\0' ||
    value < minimum ||
    value > maximum
  ) {
    return false;
  }

  result = static_cast<uint16_t>(value);
  return true;
}

bool parseFiveValues(
  const char* text,
  uint32_t& value1,
  uint32_t& value2,
  uint32_t& value3,
  uint32_t& value4,
  uint32_t& value5
) {
  char local[COMMAND_CAPACITY];
  strncpy(local, text, sizeof(local) - 1U);
  local[sizeof(local) - 1U] = '\0';

  char* token = strtok(local, " ");
  uint32_t* values[5] = {
    &value1, &value2, &value3, &value4, &value5
  };

  for (uint8_t index = 0; index < 5U; ++index) {
    if (token == nullptr) {
      return false;
    }

    char* endPointer = nullptr;
    const unsigned long parsed = strtoul(token, &endPointer, 10);

    if (
      endPointer == token ||
      *endPointer != '\0'
    ) {
      return false;
    }

    *values[index] = static_cast<uint32_t>(parsed);
    token = strtok(nullptr, " ");
  }

  return token == nullptr;
}

bool commandLocked() {
  return playerState == PlayerState::Starting ||
    playerState == PlayerState::Playing ||
    playerState == PlayerState::Resetting;
}

void setVolume(uint8_t volume) {
  selectedVolume = volume;
  config.volume = volume;
  saveConfig();

  mp3.setVolume(selectedVolume);

  Serial.print(F("OK VOLUME VALUE="));
  Serial.println(selectedVolume);
}

void processCommand(char* command) {
  while (*command == ' ') {
    ++command;
  }

  char* end = command + strlen(command);

  while (end > command && *(end - 1) == ' ') {
    --end;
  }

  *end = '\0';

  for (char* cursor = command; *cursor != '\0'; ++cursor) {
    if (*cursor >= 'a' && *cursor <= 'z') {
      *cursor = static_cast<char>(*cursor - ('a' - 'A'));
    }
  }

  if (*command == '\0') {
    return;
  }

  if (pcSessionActive) {
    lastPcActivityAt = millis();
  }

  if (
    strcmp(command, "IDENTIFY") == 0 ||
    strcmp(command, "HELLO?") == 0
  ) {
    printIdentity();
    return;
  }

  if (strcmp(command, "PING") == 0) {
    Serial.println(F("PONG"));
    return;
  }

  if (
    strcmp(command, "STATUS") == 0 ||
    strcmp(command, "STATUS?") == 0
  ) {
    printStatus();
    return;
  }

  if (strcmp(command, "SESSION START") == 0) {
    beginPcSession();
    return;
  }

  if (strcmp(command, "SESSION END") == 0) {
    if (pcSessionActive) {
      Serial.println(F("OK SESSION ENDING"));
      enterStandaloneInputs("SESSION_END");
    } else {
      Serial.println(F("OK SESSION ACTIVE=0"));
    }
    return;
  }

  if (!pcSessionActive) {
    Serial.println(F("ERR NO_SESSION"));
    return;
  }

  if (strcmp(command, "CONFIG?") == 0) {
    printConfiguration();
    return;
  }

  if (strcmp(command, "RESET") == 0) {
    config.automationEnabled = 0;
    saveConfig();
    clearQueue();
    resetSchedules();
    initializeJq6500(true);
    printSettings();
    return;
  }

  uint16_t value = 0;

  if (strncmp(command, "VOLUME ", 7) == 0) {
    if (!parseUnsigned(command + 7, MIN_VOLUME, MAX_VOLUME, value)) {
      Serial.println(F("ERR VOLUME_RANGE MIN=0 MAX=30"));
      return;
    }

    setVolume(static_cast<uint8_t>(value));
    return;
  }

  if (strcmp(command, "MEDIA?") == 0) {
    if (
      playerState != PlayerState::Ready ||
      busyStable ||
      queueCount != 0U ||
      automationActive()
    ) {
      Serial.println(F("ERR MEDIA_BUSY"));
      return;
    }

    const unsigned int fileCount = mp3.countFiles(MP3_SRC_BUILTIN);

    Serial.print(F("MEDIA SOURCE=BUILTIN COUNT="));
    Serial.print(fileCount);
    Serial.println(F(" NAMES=UNAVAILABLE"));
    return;
  }

  if (commandLocked()) {
    Serial.print(F("ERR LOCKED STATE="));
    Serial.println(stateText(playerState));
    return;
  }

  if (strncmp(command, "PLAY ", 5) == 0) {
    if (controlMode() != ControlMode::Software) {
      Serial.println(F("ERR MODE_INPUTS"));
      return;
    }

    if (!parseUnsigned(command + 5, 1, SOUND_COUNT, value)) {
      Serial.println(F("ERR PLAY_RANGE MIN=1 MAX=10"));
      return;
    }

    enqueueSound(static_cast<uint8_t>(value), Trigger::Manual);
    dispatchNext();
    return;
  }

  if (strcmp(command, "MODE SOFTWARE") == 0) {
    config.controlMode = static_cast<uint8_t>(ControlMode::Software);
    config.automationEnabled = 0;
    saveConfig();
    clearQueue();
    resetSchedules();
    Serial.println(F("OK MODE VALUE=SOFTWARE"));
    printSettings();
    emitQueue();
    return;
  }

  if (strcmp(command, "MODE INPUTS") == 0) {
    config.controlMode = static_cast<uint8_t>(ControlMode::Inputs);
    config.automationEnabled = 0;
    saveConfig();
    clearQueue();
    resetSchedules();
    Serial.println(F("OK MODE VALUE=INPUTS"));
    printSettings();
    emitQueue();
    return;
  }

  if (strncmp(command, "AUTOMATION ", 11) == 0) {
    if (!parseUnsigned(command + 11, 0, 1, value)) {
      Serial.println(F("ERR AUTOMATION_RANGE MIN=0 MAX=1"));
      return;
    }

    if (controlMode() != ControlMode::Software && value != 0U) {
      Serial.println(F("ERR AUTOMATION_MODE_INPUTS"));
      return;
    }

    config.automationEnabled = static_cast<uint8_t>(value);
    saveConfig();
    initializeAutomation(millis());
    dispatchNext();

    Serial.print(F("OK AUTOMATION VALUE="));
    Serial.println(config.automationEnabled);
    printSettings();
    return;
  }

  if (strncmp(command, "RANDOM_RANGE ", 13) == 0) {
    char local[COMMAND_CAPACITY];
    strncpy(local, command + 13, sizeof(local) - 1U);
    local[sizeof(local) - 1U] = '\0';

    char* first = strtok(local, " ");
    char* second = strtok(nullptr, " ");
    char* extra = strtok(nullptr, " ");

    if (first == nullptr || second == nullptr || extra != nullptr) {
      Serial.println(F("ERR RANDOM_RANGE_FORMAT"));
      return;
    }

    char* firstEnd = nullptr;
    char* secondEnd = nullptr;
    const uint32_t minimum =
      static_cast<uint32_t>(strtoul(first, &firstEnd, 10));
    const uint32_t maximum =
      static_cast<uint32_t>(strtoul(second, &secondEnd, 10));

    if (
      firstEnd == first ||
      secondEnd == second ||
      *firstEnd != '\0' ||
      *secondEnd != '\0' ||
      minimum < MIN_DELAY_SECONDS ||
      maximum < minimum ||
      maximum > MAX_DELAY_SECONDS
    ) {
      Serial.println(F("ERR RANDOM_RANGE_SECONDS MIN=1 MAX=86400"));
      return;
    }

    config.randomSecondsMin = minimum;
    config.randomSecondsMax = maximum;
    saveConfig();

    const unsigned long now = millis();

    for (uint8_t index = 0; index < SOUND_COUNT; ++index) {
      scheduleRandom(index, now);
    }

    Serial.print(F("OK RANDOM_RANGE MIN_SECONDS="));
    Serial.print(config.randomSecondsMin);
    Serial.print(F(" MAX_SECONDS="));
    Serial.println(config.randomSecondsMax);
    printSettings();
    return;
  }

  if (strncmp(command, "CONFIG ", 7) == 0) {
    uint32_t sound = 0;
    uint32_t permanent = 0;
    uint32_t randomEnabled = 0;
    uint32_t intervalEnabled = 0;
    uint32_t intervalSeconds = 0;

    if (
      !parseFiveValues(
        command + 7,
        sound,
        permanent,
        randomEnabled,
        intervalEnabled,
        intervalSeconds
      ) ||
      sound < 1U ||
      sound > SOUND_COUNT ||
      permanent > 1U ||
      randomEnabled > 1U ||
      intervalEnabled > 1U ||
      intervalSeconds < MIN_DELAY_SECONDS ||
      intervalSeconds > MAX_DELAY_SECONDS
    ) {
      Serial.println(F(
        "ERR CONFIG_FORMAT SOUND P R I SECONDS"
      ));
      return;
    }

    SoundConfig& soundConfig = config.sound[sound - 1U];
    soundConfig.flags = 0;

    if (permanent != 0U) {
      soundConfig.flags |= FLAG_PERMANENT;
    }
    if (randomEnabled != 0U) {
      soundConfig.flags |= FLAG_RANDOM;
    }
    if (intervalEnabled != 0U) {
      soundConfig.flags |= FLAG_INTERVAL;
    }

    soundConfig.intervalSeconds = intervalSeconds;
    saveConfig();

    removeQueuedSound(static_cast<uint8_t>(sound));

    if (automationActive()) {
      initializeSoundSchedule(
        static_cast<uint8_t>(sound - 1U),
        millis()
      );
      dispatchNext();
    }

    Serial.print(F("OK CONFIG SOUND="));
    Serial.println(sound);
    printConfiguration();
    return;
  }


  Serial.print(F("ERR UNKNOWN COMMAND="));
  Serial.println(command);
}

void readPcCommands() {
  while (Serial.available() > 0) {
    const char incoming = static_cast<char>(Serial.read());

    if (incoming == '\r' || incoming == '\n') {
      if (commandOverflow) {
        commandOverflow = false;
        commandLength = 0;
        Serial.println(F("ERR COMMAND_TOO_LONG"));
        continue;
      }

      if (commandLength > 0U) {
        commandBuffer[commandLength] = '\0';
        processCommand(commandBuffer);
        commandLength = 0;
      }

      continue;
    }

    if (incoming < 32 || incoming > 126) {
      continue;
    }

    if (commandOverflow) {
      continue;
    }

    if (commandLength < COMMAND_CAPACITY - 1U) {
      commandBuffer[commandLength++] = incoming;
    } else {
      commandOverflow = true;
    }
  }
}

void initializeInputs() {
  const unsigned long now = millis();

  for (uint8_t index = 0; index < INPUT_COUNT; ++index) {
    pinMode(INPUT_PINS[index], INPUT_PULLUP);

    const bool pressed = digitalRead(INPUT_PINS[index]) == LOW;
    inputStable[index] = pressed;
    inputCandidate[index] = pressed;
    inputCandidateSince[index] = now;
  }
}
