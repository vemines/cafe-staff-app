String _padLeft2(int day) => day.toString().padLeft(2, '0');

String toTimerString(DateTime datetime) {
  Duration difference = datetime.difference(DateTime.now());

  if (difference.isNegative) return '00:00';

  int hours = difference.inHours;
  int minutes = difference.inMinutes % 60;
  int seconds = difference.inSeconds % 60;

  String hourString = hours > 0 ? '${_padLeft2(hours)}: ' : '';

  return '$hourString${_padLeft2(minutes)}:${_padLeft2(seconds)}';
}

bool isWithinDateRange({required DateTime date, required DateTime start, required DateTime end}) {
  return date.isAfter(start) && date.isBefore(end.add(const Duration(days: 1)));
}
