import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String toFormatTime() => DateFormat('dd/MM/yyyy HH:mm').format(this);
}
