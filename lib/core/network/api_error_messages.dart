import 'package:beauty_center_app/core/localization/app_locale_controller.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations_ar.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations_en.dart';
import 'package:flutter/material.dart';

/// Localized API fallback messages for layers without [BuildContext]
/// (e.g. [BaseRepository]). Uses [AppLocaleController] for the active language.
class ApiErrorMessages {
  ApiErrorMessages._();

  static AppLocalizations get _l10n {
    final Locale? locale = AppLocaleController.instance.locale.value;
    if (locale?.languageCode == 'ar') {
      return AppLocalizationsAr();
    }
    return AppLocalizationsEn();
  }

  static String get noInternet => _l10n.errorNoInternet;

  static String get serverUnavailable => _l10n.errorServerUnavailable;

  static String get unexpected => _l10n.errorUnexpected;
}
