// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Sven Häber

#pragma once
#include "Arduino.h"
class SoftwareSerial {
public:
  SoftwareSerial(uint8_t,uint8_t) {}
  void begin(unsigned long) {}
  void listen() {}
};
