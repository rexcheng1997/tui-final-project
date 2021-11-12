#ifndef PACKAGE_H
#define PACKAGE_H

#include <ArxContainer.h>
#include "custom_types.h"

class Package {
  public:
    Package() {};

    // add a key-value pair to Package
    void add_pair(const String key, const reading_t val);

    // serialize Package to a JSON string
    const String to_json() const;

  private:
    arx::map<String, reading_t> pairs;
};

#endif
