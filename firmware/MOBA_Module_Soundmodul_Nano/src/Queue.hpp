// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Sven Häber

uint16_t inputMask() {
  uint16_t mask = 0;

  for (uint8_t index = 0; index < INPUT_COUNT; ++index) {
    if (inputStable[index]) {
      mask |= static_cast<uint16_t>(1U << index);
    }
  }

  return mask;
}

void clearQueue() {
  queueHead = 0;
  queueTail = 0;
  queueCount = 0;
}

bool queueContains(uint8_t sound) {
  for (uint8_t offset = 0; offset < queueCount; ++offset) {
    const uint8_t position = static_cast<uint8_t>(
      (queueHead + offset) % QUEUE_CAPACITY
    );

    if (queueItems[position].sound == sound) {
      return true;
    }
  }

  return false;
}

bool soundPending(uint8_t sound) {
  if (
    (playerState == PlayerState::Starting ||
     playerState == PlayerState::Playing) &&
    currentSound == sound
  ) {
    return true;
  }

  return queueContains(sound);
}

void emitQueue() {
  Serial.print(F("QUEUE COUNT="));
  Serial.print(queueCount);
  Serial.print(F(" ITEMS="));

  if (queueCount == 0U) {
    Serial.println(F("-"));
    return;
  }

  for (uint8_t offset = 0; offset < queueCount; ++offset) {
    if (offset > 0U) {
      Serial.print(',');
    }

    const uint8_t position = static_cast<uint8_t>(
      (queueHead + offset) % QUEUE_CAPACITY
    );
    const QueueItem& item = queueItems[position];

    Serial.print(item.sound);
    Serial.print(':');
    Serial.print(triggerText(item.trigger));

    if (item.input > 0U) {
      Serial.print(':');
      Serial.print(item.input);
    }
  }

  Serial.println();
}

void removeQueuedSound(uint8_t sound) {
  QueueItem retained[QUEUE_CAPACITY];
  uint8_t retainedCount = 0;

  while (queueCount > 0U) {
    const QueueItem item = queueItems[queueHead];
    queueHead = static_cast<uint8_t>((queueHead + 1U) % QUEUE_CAPACITY);
    --queueCount;

    if (item.sound != sound && retainedCount < QUEUE_CAPACITY) {
      retained[retainedCount++] = item;
    }
  }

  clearQueue();

  for (uint8_t index = 0; index < retainedCount; ++index) {
    queueItems[queueTail] = retained[index];
    queueTail = static_cast<uint8_t>((queueTail + 1U) % QUEUE_CAPACITY);
    ++queueCount;
  }
}

bool enqueueSound(uint8_t sound, Trigger trigger, uint8_t input = 0) {
  if (sound < 1U || sound > SOUND_COUNT) {
    return false;
  }

  if (soundPending(sound)) {
    Serial.print(F("EVENT QUEUE_SKIPPED INDEX="));
    Serial.print(sound);
    Serial.print(F(" TRIGGER="));
    Serial.print(triggerText(trigger));
    Serial.println(F(" REASON=DUPLICATE"));
    return false;
  }

  if (queueCount >= QUEUE_CAPACITY) {
    Serial.print(F("ERR QUEUE_FULL INDEX="));
    Serial.println(sound);
    return false;
  }

  QueueItem& item = queueItems[queueTail];
  item.sound = sound;
  item.trigger = trigger;
  item.input = input;

  queueTail = static_cast<uint8_t>((queueTail + 1U) % QUEUE_CAPACITY);
  ++queueCount;

  Serial.print(F("EVENT QUEUED INDEX="));
  Serial.print(sound);
  Serial.print(F(" TRIGGER="));
  Serial.print(triggerText(trigger));
  Serial.print(F(" INPUT="));
  Serial.print(input);
  Serial.print(F(" QUEUE_COUNT="));
  Serial.println(queueCount);
  emitQueue();

  return true;
}

bool dequeueSound(QueueItem& item) {
  if (queueCount == 0U) {
    return false;
  }

  item = queueItems[queueHead];
  queueHead = static_cast<uint8_t>((queueHead + 1U) % QUEUE_CAPACITY);
  --queueCount;
  return true;
}
