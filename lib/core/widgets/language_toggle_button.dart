import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/localization/app_locale_controller.dart';
import 'package:beauty_center_app/core/storage/preference_manager.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  static const Locale _english = Locale('en');
  static const Locale _arabic = Locale('ar');

  @override
  Widget build(BuildContext context) {
    final AppLocaleController controller = AppLocaleController.instance;

    return ValueListenableBuilder<Locale?>(
      valueListenable: controller.locale,
      builder: (BuildContext context, Locale? locale, _) {
        final Locale activeLocale = locale ?? Localizations.localeOf(context);
        final bool isArabic = activeLocale.languageCode == _arabic.languageCode;

        return TextButton.icon(
          onPressed: () async {
            final Locale nextLocale = isArabic ? _english : _arabic;
            await controller.setLocale(getIt<PreferenceManager>(), nextLocale);
          },
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            backgroundColor: AppColors.surfaceMuted,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          icon: const Icon(Icons.language_rounded, size: 16),
          label: Text(
            isArabic ? 'EN' : 'AR',
            style: AppTextStyles.link.copyWith(fontSize: 12),
          ),
        );
      },
    );
  }
}
