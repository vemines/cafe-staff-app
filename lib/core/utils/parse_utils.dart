int intParse(dynamic value, {int fallbackValue = 0}) {
  return value is num ? value.toInt() : (int.tryParse(value.toString()) ?? fallbackValue);
}

double doubleParse(dynamic value, {double fallbackValue = 0}) {
  return value is num ? value.toDouble() : (double.tryParse(value.toString()) ?? fallbackValue);
}

DateTime dateParse(Object? date) => DateTime.tryParse(date.toString()) ?? DateTime(3000);

DateTime? dateParseNullAble(Object? date) => DateTime.tryParse(date.toString());

bool boolParse(dynamic value) => value is bool ? value : value.toString() == "true";
