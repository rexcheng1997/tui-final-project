#ifndef CUSTOM_TYPES_H
#define CUSTOM_TYPES_H

#include <Arduino.h>

#define NUM_STRIPS 4 // four aluminium foil strips in total

// type of readings from the sensors
typedef long reading_t;

// enum type for body postures
enum Posture { OFF, STANDING, WALKING, SITTING, LYING };

// struct to record the state of a strip
// use prev and curr readings to determine if a strip is triggered
struct strip_state_t {
  reading_t prev;
  reading_t curr;
  bool triggered;
};

#endif
