import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class BookingsHeader extends StatelessWidget {
  const BookingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 10),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          l10n.myAppointments,
          style: AppTextStyles.headline.copyWith(fontSize: 26),
        ),
      ),
    );
  }
}
