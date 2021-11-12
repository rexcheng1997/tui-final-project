#include "package.h"

void Package::add_pair(const String key, const reading_t val) {
  this->pairs.insert(key, val);
}

const String Package::to_json() const {
  String result = "{";
  for (const auto& pair : this->pairs) {
    result += "\"" + pair.first + "\"";
    result += ":";
    result += String(pair.second);
    result += ",";
  }
  result.remove(result.length() - 1);
  result += "}";
  return result;
}
