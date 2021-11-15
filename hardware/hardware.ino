#include <CapacitiveSensor.h>
#include "custom_types.h"
#include "package.h"
#include "body_posture.h"

CapacitiveSensor cs42 = CapacitiveSensor(4, 2);

void setup() {
  Serial.begin(9600);
  cs42.set_CS_AutocaL_Millis(0xFFFFFFFF);
}

void loop() {
  reading_t values[] = { cs42.capacitiveSensor(30) };
//  Serial.print(values[0]);
//  Serial.print("\t");
  BodyPosture posture = BodyPosture();
  posture.update_readings(values);
  Serial.println(posture.get_body_posture());
  delay(100);
}
