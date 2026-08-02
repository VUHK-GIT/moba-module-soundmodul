// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Sven Häber

void resetSchedules() {
  for (uint8_t index = 0; index < SOUND_COUNT; ++index) {
    nextRandomAt[index] = 0;
    nextIntervalAt[index] = 0;
  }
}

unsigned long secondDelay(uint32_t seconds) {
  return static_cast<unsigned long>(seconds * 1000UL);
}

void scheduleRandom(uint8_t index, unsigned long now) {
  if ((config.sound[index].flags & FLAG_RANDOM) == 0U) {
    nextRandomAt[index] = 0;
    return;
  }

  const long minimum = static_cast<long>(config.randomSecondsMin);
  const long maximumExclusive =
    static_cast<long>(config.randomSecondsMax) + 1L;
  const uint32_t seconds = static_cast<uint32_t>(
    random(minimum, maximumExclusive)
  );

  nextRandomAt[index] = now + secondDelay(seconds);
}

void scheduleInterval(uint8_t index, unsigned long now) {
  if ((config.sound[index].flags & FLAG_INTERVAL) == 0U) {
    nextIntervalAt[index] = 0;
    return;
  }

  nextIntervalAt[index] =
    now + secondDelay(config.sound[index].intervalSeconds);
}

void initializeSoundSchedule(uint8_t index, unsigned long now) {
  scheduleRandom(index, now);
  scheduleInterval(index, now);

  if ((config.sound[index].flags & FLAG_PERMANENT) != 0U) {
    enqueueSound(
      static_cast<uint8_t>(index + 1U),
      Trigger::Permanent
    );
  }
}

void initializeAutomation(unsigned long now) {
  clearQueue();
  resetSchedules();

  if (!automationActive()) {
    emitQueue();
    return;
  }

  for (uint8_t index = 0; index < SOUND_COUNT; ++index) {
    initializeSoundSchedule(index, now);
  }
}
