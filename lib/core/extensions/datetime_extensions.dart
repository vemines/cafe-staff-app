import 'package:intl/intl.dart';

extension DateTimeExt on DateTime {
  String get toFormatTime => DateFormat('dd/MM/yyyy HH:mm').format(this);
  String get toFormatDate => DateFormat('dd/MM/yyyy').format(this);
}
