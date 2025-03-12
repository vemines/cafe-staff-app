import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  // usage: context.textTheme
  TextTheme get textTheme => Theme.of(this).textTheme;
  // usage: context.width
  double get width => MediaQuery.of(this).size.width;
  // usage: context.height
  double get height => MediaQuery.of(this).size.height;
  // usage: context.widthF(0.2)
  double widthF(double factor) => width * factor;
  // usage: context.heightF(0.2)
  double heightF(double factor) => height * factor;
  // usage: context.isMobile
  bool get isMobile => width < 768;

  // Safe area
  EdgeInsets get paddingOf => MediaQuery.paddingOf(this);
  // use at home page, get height after substract safe area, appbar height, bottom nav height
  // usage : context.safeHeight. (-n because still left scroll, if need scroll more add + n)
  double get homeSafeHeight =>
      height -
      paddingOf.top -
      paddingOf.bottom -
      AppBar().preferredSize.height -
      kBottomNavigationBarHeight -
      5;
  // safe height without bottom nav height
  double get safeHeightNoBottom => homeSafeHeight + kBottomNavigationBarHeight;

  // usage: context.colorScheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // usage: context.snakebar("text")
  void snakebar(String text) =>
      ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(text)));
}
