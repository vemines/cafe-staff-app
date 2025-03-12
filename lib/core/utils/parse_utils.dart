int intParse(dynamic value, {int fallbackValue = 0}) {
  return value is num ? value.toInt() : (int.tryParse(value.toString()) ?? fallbackValue);
}

double doubleParse(dynamic value, {double fallbackValue = 0}) {
  return value is num ? value.toDouble() : (double.tryParse(value.toString()) ?? fallbackValue);
}

DateTime dateParse(String date) => DateTime.tryParse(date) ?? DateTime(3035);
