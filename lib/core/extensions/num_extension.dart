import 'package:flutter/material.dart';

extension IntExt on int {
  // usage: 20.toShortString
  String get toShortString {
    if (this >= 1000000000) {
      return '${(this / 1000000000).toStringAsFixed(1)} B';
    } else if (this >= 1000000) {
      return '${(this / 1000000).toStringAsFixed(1)} M';
    } else if (this >= 1000) {
      return '${(this / 1000).toStringAsFixed(1)} K';
    }
    return toString();
  }

  EdgeInsets get eiAll => EdgeInsets.all(toDouble());
  EdgeInsets get eiHori => EdgeInsets.symmetric(horizontal: toDouble());
  EdgeInsets get eiVert => EdgeInsets.symmetric(vertical: toDouble());

  BorderRadius get radius => BorderRadius.circular(toDouble());
}
