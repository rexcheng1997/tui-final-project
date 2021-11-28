#include <CapacitiveSensor.h>
#include "custom_types.h"
#include "message.h"
#include "body_posture.h"

#define FSR1_PIN 0
#define FSR2_PIN 1

/* Capacitive Sensing */
// PIN 12 - Vin, sensor PIN 8, 7, 4, 2
CapacitiveSensor cap_sensors[NUM_STRIPS] = {
  CapacitiveSensor(12, 8),
  CapacitiveSensor(12, 7),
  CapacitiveSensor(12, 4),
  CapacitiveSensor(12, 2)
};

/* Program Global Variables */
BodyPosture posture = BodyPosture();

void setup() {
  Serial.begin(9600);

  // turn off auto calibration for all capacitive sensors
  for (auto& cap_sensor : cap_sensors) {
    cap_sensor.set_CS_AutocaL_Millis(0xFFFFFFFF);
  }
}

void loop() {
  reading_t cap_vals[NUM_STRIPS] = { 0 };

  for (uint8_t i = 0; i < NUM_STRIPS; i++) {
    // 30 samples (sensor cycles)
    cap_vals[i] = cap_sensors[i].capacitiveSensor(30);
  }
  
  posture.update_readings(cap_vals);
  
  // use the line below to print/plot the difference between two consecutive readings
//  posture.print_reading_changes();
  // use the line below to print/plot the state changes for the aluminum foil strips
//  posture.print_strip_states();
//  Serial.println(posture.get_body_posture());

  Message msg;
  msg.add_pair("bodyPosture", posture.get_body_posture());
  Serial.println(msg.to_json());

  delay(800);
}
