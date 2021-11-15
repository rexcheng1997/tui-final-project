#include "body_posture.h"

BodyPosture::BodyPosture() {
  for (uint8_t i = 0; i < NUM_STRIPS; i++) {
    this->strips[i].prev = 0;
    this->strips[i].curr = 0;
    this->strips[i].triggered = false;
  }
}

void BodyPosture::update_readings(const reading_t* readings) {
  /*** ensure readings is of type `reading_t[NUM_STRIPS]` ***/
  for (uint8_t i = 0; i < NUM_STRIPS; i++) {
    this->strips[i].prev = this->strips[i].curr;
    this->strips[i].curr = readings[i];
    const reading_t diff_ratio = (
      this->strips[i].curr - this->strips[i].prev
      ) / (1 + min(
        this->strips[i].prev, this->strips[i].curr
      ));
    if (this->strips[i].triggered && diff_ratio < -threshold_ratio)
      this->strips[i].triggered = false;
    else if (!this->strips[i].triggered && diff_ratio > threshold_ratio)
      this->strips[i].triggered = true;
  }
}

const Posture BodyPosture::get_body_posture() const {
  return this->strips[0].triggered ? Posture::standing : Posture::off;
}
