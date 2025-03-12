import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    textTheme: _poppinsTextTheme(ThemeData.light().textTheme),
    // ... other theme data
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    textTheme: _poppinsTextTheme(ThemeData.dark().textTheme),
    // ... other theme data
  );

  static final ThemeData customTheme = ThemeData(
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.green,
    textTheme: _poppinsTextTheme(ThemeData.dark().textTheme),
    // ... other theme data
  );

  static TextTheme _poppinsTextTheme(TextTheme base) {
    return GoogleFonts.poppinsTextTheme(base);
  }
}
