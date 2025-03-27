import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme.dart';

List<String> themeOptions = [ThemeCubit.lightThemeKey, ThemeCubit.darkThemeKey];

class ThemeCubit extends Cubit<ThemeData> {
  ThemeCubit() : super(AppTheme.lightTheme) {
    _loadInitialTheme();
  }

  static const String _themeKey = 'themeMode';
  static const String lightThemeKey = 'Light';
  static const String darkThemeKey = 'Dark';

  static String currentTheme = 'Light Theme';

  Future<void> _loadInitialTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);
    if (savedTheme != null) currentTheme = savedTheme;
    if (savedTheme == darkThemeKey) {
      emit(AppTheme.darkTheme);
    } else {
      emit(AppTheme.lightTheme);
    }
  }

  Future<void> toggleTheme(String themeKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeKey);

    currentTheme = themeKey;

    switch (themeKey) {
      case lightThemeKey:
        emit(AppTheme.lightTheme);
        break;
      case darkThemeKey:
        emit(AppTheme.darkTheme);
        break;
    }
  }

  static String themeToString(ThemeData theme) {
    if (theme == AppTheme.lightTheme) return lightThemeKey;
    if (theme == AppTheme.darkTheme) return darkThemeKey;
    return 'Undefined Theme';
  }
}
