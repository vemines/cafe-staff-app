import 'dart:math' show pow;

import 'package:flutter/material.dart';

extension IntExt on int {
  BorderRadius get borderRadius => BorderRadius.circular(toDouble());
  Radius get radius => Radius.circular(toDouble());
}

extension DoubleExt on double {
  String get shortMoneyString {
    if (this >= pow(10, 11)) return "${(this / 1000000000).toStringAsFixed(0)} B";
    if (this >= pow(10, 10)) return "${(this / 1000000000).toStringAsFixed(1)} B";
    if (this >= pow(10, 9)) return "${(this / 1000000000).toStringAsFixed(2)} B";
    if (this >= pow(10, 8)) return "${(this / 1000000).toStringAsFixed(0)} M";
    if (this >= pow(10, 7)) return "${(this / 1000000).toStringAsFixed(1)} M";
    if (this >= pow(10, 6)) return "${(this / 1000000).toStringAsFixed(2)} M";
    if (this >= pow(10, 5)) return "${(this / 1000).toStringAsFixed(0)} K";
    if (this >= pow(10, 4)) return "${(this / 1000).toStringAsFixed(1)} K";
    if (this >= pow(10, 3)) return "${(this / 1000).toStringAsFixed(2)} K";
    return toStringAsFixed(2);
  }
}
