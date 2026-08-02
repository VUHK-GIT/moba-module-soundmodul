// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Sven Häber

#pragma once
#include "Arduino.h"
#include "SoftwareSerial.h"
#define MP3_SRC_BUILTIN 4
#define MP3_LOOP_ONE_STOP 4
class JQ6500_Serial {
public:
  explicit JQ6500_Serial(SoftwareSerial&) {}
  void reset() {}
  void setSource(uint8_t) {}
  void setLoopMode(uint8_t) {}
  void setVolume(uint8_t) {}
  void playFileByIndexNumber(unsigned int) {}
  unsigned int countFiles(uint8_t) { return 7; }
};
