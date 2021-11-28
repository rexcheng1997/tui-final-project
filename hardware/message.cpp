#include "message.h"

void Message::add_pair(const String key, const reading_t val) {
  this->pairs.insert(key, val);
}

const String Message::to_json() const {
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
