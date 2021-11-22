#include "body_posture.h"

BodyPosture::BodyPosture() {
  for (uint8_t i = 0; i < NUM_STRIPS; i++) {
    this->strips[i].prev = 0;
    this->strips[i].curr = 0;
    this->strips[i].triggered = false;
  }

  this->prev_state_mask = 0;
  this->curr_state_mask = 0;
}

void BodyPosture::update_readings(const reading_t* readings) {
  uint8_t state_mask = 0;
  
  /*** ensure readings is of type `reading_t[NUM_STRIPS]` ***/
  for (uint8_t i = 0; i < NUM_STRIPS; i++) {
    this->strips[i].prev = this->strips[i].curr;
    this->strips[i].curr = readings[i];

    const reading_t diff = this->strips[i].curr - this->strips[i].prev;

    if (this->strips[i].triggered && diff < -threshold)
      this->strips[i].triggered = false;
    else if (!this->strips[i].triggered && diff > threshold)
      this->strips[i].triggered = true;

    state_mask += (this->strips[i].triggered << i);
  }

  this->prev_state_mask = this->curr_state_mask;
  this->curr_state_mask = state_mask;
}

const Posture BodyPosture::get_body_posture() const {
  if (this->curr_state_mask == 0) return Posture::OFF;
  if (this->curr_state_mask == 0xF) return Posture::LYING;

  const auto one_bits_in_prev = count_one_bits(this->prev_state_mask),
             one_bits_in_curr = count_one_bits(this->curr_state_mask);
  const uint8_t mask_xor = this->prev_state_mask ^ this->curr_state_mask;

  if (mask_xor == 0) { // touches remain the same
    return one_bits_in_curr == 1 ? Posture::STANDING : Posture::SITTING;
  } else { // touches change
    if (one_bits_in_curr < 3) return Posture::WALKING;
    return Posture::SITTING;
  }
}

void BodyPosture::print_reading_changes() const {
  for (uint8_t i = 0; i < NUM_STRIPS; i++) {
    Serial.print("diff" + String(i) + ":");
    Serial.print(threshold * 2 * i + this->strips[i].curr - this->strips[i].prev);
    if (i != NUM_STRIPS - 1) Serial.print("\t");
  }
  Serial.println();
}

void BodyPosture::print_strip_states() const {
  for (uint8_t i = 0; i < NUM_STRIPS; i++) {
    Serial.print("cap" + String(i) + ":");
    Serial.print((NUM_STRIPS - i) * 2 + this->strips[i].triggered);
    if (i != NUM_STRIPS - 1) Serial.print("\t");
  }
  Serial.println();
}

const uint8_t count_one_bits(const uint8_t mask) {
  uint8_t count = 0;
  for (uint8_t i = 0; i < NUM_STRIPS; i++) {
    count += (mask >> i) & 1;
  }
  return count;
}
