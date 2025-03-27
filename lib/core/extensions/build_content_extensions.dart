import 'package:flutter/material.dart';

extension BuildContextExt on BuildContext {
  // usage: context.textTheme
  TextTheme get textTheme => Theme.of(this).textTheme;
  // usage: context.width
  double get width => MediaQuery.of(this).size.width;
  // usage: context.isMobile
  bool get isMobile => width < 768;

  // usage: context.colorScheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  // usage: context.snakebar("text")
  void snakebar(String text) =>
      ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(text)));

  TextStyle get titleMediumBold => textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold);
  TextStyle get titleLargeBold => textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold);
  TextStyle get bodyLargeBold => textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold);
  TextStyle get bodyMediumBold => textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold);
}
