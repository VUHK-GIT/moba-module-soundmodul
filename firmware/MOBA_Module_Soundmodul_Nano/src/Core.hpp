// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Sven Häber

constexpr char FIRMWARE_VERSION[] = "1.0.0";
constexpr uint32_t CONFIG_MAGIC = 0x4D4D534DUL;  // MMSM
constexpr uint8_t CONFIG_VERSION = 2;

constexpr uint32_t PC_BAUD = 115200UL;
constexpr uint32_t JQ_BAUD = 9600UL;

constexpr uint8_t JQ_RX_PIN = 10;
constexpr uint8_t JQ_TX_PIN = 11;
constexpr uint8_t JQ_BUSY_PIN = A2;
constexpr uint8_t RANDOM_SEED_PIN = A3;

constexpr uint8_t SOUND_COUNT = 10;
constexpr uint8_t INPUT_COUNT = 10;
constexpr uint8_t INPUT_PINS[INPUT_COUNT] = {
  2, 3, 4, 5, 6, 7, 8, 9, A0, A1
};

constexpr uint8_t DEFAULT_VOLUME = 15;
constexpr uint8_t MIN_VOLUME = 0;
constexpr uint8_t MAX_VOLUME = 30;
constexpr uint32_t DEFAULT_INTERVAL_SECONDS = 300UL;
constexpr uint32_t MIN_DELAY_SECONDS = 1UL;
constexpr uint32_t MAX_DELAY_SECONDS = 86400UL;
constexpr uint32_t DEFAULT_RANDOM_SECONDS_MIN = 120UL;
constexpr uint32_t DEFAULT_RANDOM_SECONDS_MAX = 600UL;

constexpr int BUSY_ON_THRESHOLD = 350;
constexpr int BUSY_OFF_THRESHOLD = 150;
constexpr unsigned long BUSY_SAMPLE_MS = 5UL;
constexpr unsigned long BUSY_DEBOUNCE_MS = 30UL;
constexpr unsigned long BUSY_START_TIMEOUT_MS = 1500UL;
constexpr unsigned long INPUT_DEBOUNCE_MS = 30UL;
constexpr unsigned long SCHEDULER_INTERVAL_MS = 250UL;
constexpr unsigned long PC_SESSION_TIMEOUT_MS = 4000UL;

constexpr size_t COMMAND_CAPACITY = 80;
constexpr uint8_t QUEUE_CAPACITY = SOUND_COUNT;

constexpr uint8_t FLAG_PERMANENT = 0x01;
constexpr uint8_t FLAG_RANDOM = 0x02;
constexpr uint8_t FLAG_INTERVAL = 0x04;

enum class PlayerState : uint8_t {
  Ready,
  Starting,
  Playing,
  Resetting
};

enum class ControlMode : uint8_t {
  Software = 0,
  Inputs = 1
};

enum class Trigger : uint8_t {
  None = 0,
  Manual = 1,
  Permanent = 2,
  Random = 3,
  Interval = 4,
  Input = 5
};

struct SoundConfig {
  uint8_t flags;
  uint32_t intervalSeconds;
};

struct PersistedConfig {
  uint32_t magic;
  uint8_t version;
  uint8_t controlMode;
  uint8_t automationEnabled;
  uint32_t randomSecondsMin;
  uint32_t randomSecondsMax;
  uint8_t volume;
  SoundConfig sound[SOUND_COUNT];
  uint16_t crc;
};

struct QueueItem {
  uint8_t sound;
  Trigger trigger;
  uint8_t input;
};

SoftwareSerial jqSerial(JQ_RX_PIN, JQ_TX_PIN);
JQ6500_Serial mp3(jqSerial);

PersistedConfig config;
PlayerState playerState = PlayerState::Ready;

uint8_t selectedVolume = DEFAULT_VOLUME;
uint8_t currentSound = 0;
Trigger currentTrigger = Trigger::None;
uint8_t currentInput = 0;

bool busyStable = false;
bool busyCandidate = false;
bool busyWasSeen = false;
unsigned long busyCandidateSince = 0;
unsigned long lastBusySampleAt = 0;
unsigned long playCommandAt = 0;
int busyRaw = 0;

bool inputStable[INPUT_COUNT];
bool inputCandidate[INPUT_COUNT];
unsigned long inputCandidateSince[INPUT_COUNT];

QueueItem queueItems[QUEUE_CAPACITY];
uint8_t queueHead = 0;
uint8_t queueTail = 0;
uint8_t queueCount = 0;

unsigned long nextRandomAt[SOUND_COUNT];
unsigned long nextIntervalAt[SOUND_COUNT];
unsigned long lastSchedulerAt = 0;

bool pcSessionActive = false;
unsigned long lastPcActivityAt = 0;

char commandBuffer[COMMAND_CAPACITY];
size_t commandLength = 0;
bool commandOverflow = false;

bool timeReached(unsigned long now, unsigned long deadline) {
  return static_cast<long>(now - deadline) >= 0;
}

uint16_t crc16(const uint8_t* data, size_t length) {
  uint16_t crc = 0xFFFF;

  for (size_t index = 0; index < length; ++index) {
    crc ^= static_cast<uint16_t>(data[index]) << 8;

    for (uint8_t bit = 0; bit < 8; ++bit) {
      if ((crc & 0x8000U) != 0U) {
        crc = static_cast<uint16_t>((crc << 1) ^ 0x1021U);
      } else {
        crc = static_cast<uint16_t>(crc << 1);
      }
    }
  }

  return crc;
}

const __FlashStringHelper* stateText(PlayerState state) {
  switch (state) {
    case PlayerState::Ready:
      return F("READY");
    case PlayerState::Starting:
      return F("STARTING");
    case PlayerState::Playing:
      return F("PLAYING");
    case PlayerState::Resetting:
      return F("RESETTING");
  }

  return F("UNKNOWN");
}

const __FlashStringHelper* modeText(ControlMode mode) {
  return mode == ControlMode::Inputs ? F("INPUTS") : F("SOFTWARE");
}

const __FlashStringHelper* triggerText(Trigger trigger) {
  switch (trigger) {
    case Trigger::Manual:
      return F("MANUAL");
    case Trigger::Permanent:
      return F("PERMANENT");
    case Trigger::Random:
      return F("RANDOM");
    case Trigger::Interval:
      return F("INTERVAL");
    case Trigger::Input:
      return F("INPUT");
    case Trigger::None:
    default:
      return F("NONE");
  }
}

ControlMode configuredControlMode() {
  return config.controlMode == static_cast<uint8_t>(ControlMode::Inputs)
    ? ControlMode::Inputs
    : ControlMode::Software;
}

ControlMode controlMode() {
  if (!pcSessionActive) {
    return ControlMode::Inputs;
  }

  return configuredControlMode();
}

bool automationActive() {
  return pcSessionActive &&
    controlMode() == ControlMode::Software &&
    config.automationEnabled != 0U;
}

void setDefaults() {
  memset(&config, 0, sizeof(config));
  config.magic = CONFIG_MAGIC;
  config.version = CONFIG_VERSION;
  config.controlMode = static_cast<uint8_t>(ControlMode::Software);
  config.automationEnabled = 0;
  config.randomSecondsMin = DEFAULT_RANDOM_SECONDS_MIN;
  config.randomSecondsMax = DEFAULT_RANDOM_SECONDS_MAX;
  config.volume = DEFAULT_VOLUME;

  for (uint8_t index = 0; index < SOUND_COUNT; ++index) {
    config.sound[index].flags = 0;
    config.sound[index].intervalSeconds = DEFAULT_INTERVAL_SECONDS;
  }
}

bool configValid() {
  if (
    config.magic != CONFIG_MAGIC ||
    config.version != CONFIG_VERSION ||
    config.controlMode > static_cast<uint8_t>(ControlMode::Inputs) ||
    config.automationEnabled > 1U ||
    config.randomSecondsMin < MIN_DELAY_SECONDS ||
    config.randomSecondsMax < config.randomSecondsMin ||
    config.randomSecondsMax > MAX_DELAY_SECONDS ||
    config.volume > MAX_VOLUME
  ) {
    return false;
  }

  for (uint8_t index = 0; index < SOUND_COUNT; ++index) {
    if (
      config.sound[index].intervalSeconds < MIN_DELAY_SECONDS ||
      config.sound[index].intervalSeconds > MAX_DELAY_SECONDS
    ) {
      return false;
    }
  }

  const uint16_t expected = crc16(
    reinterpret_cast<const uint8_t*>(&config),
    offsetof(PersistedConfig, crc)
  );

  return expected == config.crc;
}

void saveConfig() {
  config.magic = CONFIG_MAGIC;
  config.version = CONFIG_VERSION;
  config.crc = crc16(
    reinterpret_cast<const uint8_t*>(&config),
    offsetof(PersistedConfig, crc)
  );

  const uint8_t* source = reinterpret_cast<const uint8_t*>(&config);

  for (size_t index = 0; index < sizeof(config); ++index) {
    EEPROM.update(static_cast<int>(index), source[index]);
  }
}

void loadConfig() {
  EEPROM.get(0, config);

  if (!configValid()) {
    setDefaults();
    saveConfig();
  }

  selectedVolume = config.volume;
}
