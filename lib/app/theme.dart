import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: _appTextTheme(ThemeData.light().textTheme),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    textTheme: _appTextTheme(ThemeData.dark().textTheme),
  );

  static TextTheme _appTextTheme(TextTheme base) {
    return GoogleFonts.robotoTextTheme(base);
  }
}
