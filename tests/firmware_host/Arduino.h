// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Sven Häber

#pragma once
#include <cstdint>
#include <cstddef>
#include <cstring>
#include <cstdlib>
using std::size_t;
class __FlashStringHelper {};
#define F(value) reinterpret_cast<const __FlashStringHelper*>(value)
#define A0 14
#define A1 15
#define A2 16
#define A3 17
#define INPUT 0
#define INPUT_PULLUP 2
#define LOW 0
inline void delay(unsigned long) {}
inline unsigned long millis() { static unsigned long v=0; return v+=5; }
inline unsigned long micros() { static unsigned long v=100; return v+=17; }
inline int analogRead(uint8_t) { return 2; }
inline int digitalRead(uint8_t) { return 1; }
inline void pinMode(uint8_t,uint8_t) {}
inline void randomSeed(unsigned long) {}
inline long random(long minValue,long maxValue) { return minValue < maxValue ? minValue : maxValue; }
class HardwareSerial {
public:
  void begin(unsigned long) {}
  int available() { return 0; }
  int read() { return -1; }
  void print(char) {}
  void print(const char*) {}
  void print(const __FlashStringHelper*) {}
  void print(unsigned long) {}
  void print(unsigned int) {}
  void print(int) {}
  void println() {}
  void println(const char*) {}
  void println(const __FlashStringHelper*) {}
  void println(unsigned long) {}
  void println(unsigned int) {}
  void println(int) {}
};
extern HardwareSerial Serial;
