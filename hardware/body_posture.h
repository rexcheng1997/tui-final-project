#ifndef BODY_POSTURE_H
#define BODY_POSTURE_H

#include "custom_types.h"

class BodyPosture {
  public:
    BodyPosture();

    // update the states of strips from the readings
    void update_readings(const reading_t* readings);

    // get the current body posture inferred from strip states
    const Posture get_body_posture() const;

    // functions for debugging
    void print_reading_changes() const;
    void print_strip_states() const;

  private:
    strip_state_t strips[NUM_STRIPS];
    uint8_t prev_state_mask, curr_state_mask;
    static const reading_t threshold = 300; // threshold to determine if there is a significant difference between two consecutive readings
};

const uint8_t count_one_bits(const uint8_t mask);

#endif
