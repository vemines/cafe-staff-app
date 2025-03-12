import 'package:flutter/material.dart';

extension DoubleWidgetExt on num {
  // usage: 20.sb()
  Widget sbW() => SizedBox(width: toDouble());
  Widget sbH() => SizedBox(height: toDouble());
  Widget sb() => SizedBox(width: toDouble(), height: toDouble());
}
