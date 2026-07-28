import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global app locale state. `value == null` means "follow system locale".
/// Persisted to shared_preferences so the choice survives app restarts.
class LocaleController extends ValueNotifier<Locale?> {
  LocaleController() : super(null);

  static const _prefsKey = 'app_locale';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey);
    if (code == null || code.isEmpty) {
      value = null;
    } else {
      value = Locale(code);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    value = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}

final localeController = LocaleController();
