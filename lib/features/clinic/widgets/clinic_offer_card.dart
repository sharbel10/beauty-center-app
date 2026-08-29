import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ClinicOfferCard extends StatelessWidget {
  const ClinicOfferCard({
    required this.title,
    required this.description,
    required this.discountValue,
    required this.discountType,
    required this.endsAt,
    required this.isDark,
    required this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final int discountValue;
  final String discountType;
  final String endsAt;
  final bool isDark;
  final VoidCallback onTap;

  String _formatExpiryDate(BuildContext context, String dateStr) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (dateStr.isEmpty) return l10n.limitedTime;

    try {
      final String onlyDate = dateStr.split('T').first;
      final DateTime date = DateTime.parse(onlyDate);
      final String formatted = DateFormat.yMMMd(
        Localizations.localeOf(context),
      ).format(date);
      return l10n.offerUntilDate(formatted);
    } catch (_) {
      return l10n.limitedTimeLower;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Color background = isDark ? AppColors.primary : AppColors.surface;
    final Color foreground = isDark ? AppColors.surface : AppColors.primary;
    final Color subText = isDark
        ? AppColors.surface.withOpacity(0.65)
        : AppColors.primarySoft.withOpacity(0.7);

    final String discountBadgeText = discountType == 'percentage'
        ? l10n.offerDiscountPercent(discountValue)
        : l10n.offerDiscountAmount(discountValue);

    return Container(
      width: 290,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(24),
        border: isDark
            ? null
            : Border.all(color: AppColors.divider.withOpacity(0.6)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.gold : AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        discountBadgeText,
                        style: AppTextStyles.smallCaps.copyWith(
                          color: isDark ? AppColors.primary : AppColors.surface,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      isDark ? l10n.exclusive : l10n.hotDeal,
                      style: AppTextStyles.smallCaps.copyWith(
                        color: isDark
                            ? AppColors.gold.withOpacity(0.8)
                            : AppColors.gold,
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(
                    color: foreground,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(
                      color: subText,
                      fontSize: 12,
                      height: 1.3,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.history_toggle_off_rounded,
                            size: 14,
                            color: isDark
                                ? AppColors.gold.withOpacity(0.7)
                                : AppColors.gold,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _formatExpiryDate(context, endsAt),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.subtitle.copyWith(
                                color: isDark
                                    ? AppColors.surface.withOpacity(0.8)
                                    : AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surface : AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        l10n.clinicOfferClaim,
                        style: AppTextStyles.link.copyWith(
                          color: isDark ? AppColors.primary : AppColors.surface,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
