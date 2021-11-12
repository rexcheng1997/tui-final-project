#include "body_posture.h"

void BodyPosture::update_readings(const reading_t* readings) {
  /*** ensure readings is of type `reading_t[4]` ***/
  for (uint8_t i = 0; i < NUM_STRIPS; i++) {
    this->strips[i].prev = this->strips[i].curr;
    this->strips[i].curr = readings[i];
    this->strips[i].triggered = abs(this->strips[i].curr - this->strips[i].prev) > threshold;
  }
}

const Posture BodyPosture::get_body_posture() const {
  
}
