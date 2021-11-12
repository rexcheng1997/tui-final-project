#ifndef BODY_POSTURE_H
#define BODY_POSTURE_H

#include "custom_types.h"

class BodyPosture {
  public:
    BodyPosture() {};

    // update the states of strips from the readings
    void update_readings(const reading_t* readings);

    // get the current body posture inferred from strip states
    const Posture get_body_posture() const;

  private:
    strip_state_t strips[NUM_STRIPS];
    static const reading_t threshold = 100; // threshold to determine if there is a significant difference between two consecutive readings
};

#endif
