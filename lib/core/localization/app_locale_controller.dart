import 'package:beauty_center_app/core/storage/preference_manager.dart';
import 'package:flutter/material.dart';

class AppLocaleController {
  AppLocaleController._();

  static final AppLocaleController instance = AppLocaleController._();

  final ValueNotifier<Locale?> locale = ValueNotifier<Locale?>(null);

  Future<void> load(PreferenceManager preferenceManager) async {
    final String? languageCode = preferenceManager.getLanguage();
    if (languageCode == null || languageCode.isEmpty) {
      return;
    }

    locale.value = Locale(languageCode);
  }

  Future<void> setLocale(
    PreferenceManager preferenceManager,
    Locale newLocale,
  ) async {
    await preferenceManager.setLanguage(newLocale.languageCode);
    locale.value = newLocale;
  }
}
