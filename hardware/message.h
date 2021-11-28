#ifndef MESSAGE_H
#define MESSAGE_H

#include "custom_types.h"
#include <ArxContainer.h>

class Message {
  public:
    Message() {};

    // add a key-value pair to Package
    void add_pair(const String key, const reading_t val);

    // serialize Package to a JSON string
    const String to_json() const;

  private:
    arx::map<String, reading_t> pairs;
};

#endif
