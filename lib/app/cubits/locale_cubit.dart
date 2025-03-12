import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale> {
  static const _localeKey = 'Locale';

  LocaleCubit() : super(const Locale('en')) {
    _loadInitialLocale();
  }

  Future<void> _loadInitialLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocaleCode = prefs.getString(_localeKey);

    if (savedLocaleCode != null) {
      emit(Locale(savedLocaleCode));
    } else {
      emit(const Locale('en'));
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    if (state == newLocale) return;

    emit(newLocale);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, newLocale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }
}
