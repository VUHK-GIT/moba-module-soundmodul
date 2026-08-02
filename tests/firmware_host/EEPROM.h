// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Sven Häber

#pragma once
#include "Arduino.h"
class EEPROMClass {
public:
  template<typename T> void get(int,T&) {}
  void update(int,uint8_t) {}
};
extern EEPROMClass EEPROM;
