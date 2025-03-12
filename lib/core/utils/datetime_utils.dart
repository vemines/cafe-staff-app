String timeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays}d ago';
  } else if (difference.inDays < 365) {
    return '${_padLeft2(dateTime.day)} ${_monthName[dateTime.month]}';
  } else {
    return '${_padLeft2(dateTime.day)} ${_monthName[dateTime.month]} ${dateTime.year}';
  }
}

String _padLeft2(int day) => day.toString().padLeft(2, '0');

Map<int, String> _monthName = {
  1: 'Jan',
  2: 'Feb',
  3: 'Mar',
  4: 'Apr',
  5: 'May',
  6: 'Jun',
  7: 'Jul',
  8: 'Aug',
  9: 'Sep',
  10: 'Oct',
  11: 'Nov',
  12: 'Dec',
};

String toTimerString(DateTime datetime) {
  Duration difference = datetime.difference(DateTime.now());

  if (difference.isNegative) return '00:00';

  int hours = difference.inHours;
  int minutes = difference.inMinutes % 60;
  int seconds = difference.inSeconds % 60;

  String hourString = hours > 0 ? '${_padLeft2(hours)}: ' : '';

  return '$hourString${_padLeft2(minutes)}:${_padLeft2(seconds)}';
}
