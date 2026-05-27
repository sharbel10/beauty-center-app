import 'package:flutter/material.dart';

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
    super.key,
  });

  final String title;
  final String description;
  final int discountValue;
  final String discountType;
  final String endsAt;
  final bool isDark;

  String _formatExpiryDate(String dateStr) {
    if (dateStr.isEmpty) return 'Limited Time';
    try {
      final onlyDate = dateStr.split('T')[0];
      final parts = onlyDate.split('-');
      if (parts.length < 3) return onlyDate;

      final year = parts[0];
      final monthNum = parts[1];
      final day = int.parse(parts[2]).toString();
      final String monthName;
      switch (monthNum) {
        case '01':
          monthName = 'Jan';
          break;
        case '02':
          monthName = 'Feb';
          break;
        case '03':
          monthName = 'Mar';
          break;
        case '04':
          monthName = 'Apr';
          break;
        case '05':
          monthName = 'May';
          break;
        case '06':
          monthName = 'Jun';
          break;
        case '07':
          monthName = 'Jul';
          break;
        case '08':
          monthName = 'Aug';
          break;
        case '09':
          monthName = 'Sep';
          break;
        case '10':
          monthName = 'Oct';
          break;
        case '11':
          monthName = 'Nov';
          break;
        case '12':
          monthName = 'Dec';
          break;
        default:
          monthName = 'Min';
      }

      return 'Until $monthName $day, $year';
    } catch (_) {
      return 'Limited time';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color background = isDark ? AppColors.primary : AppColors.surface;
    final Color foreground = isDark ? AppColors.surface : AppColors.primary;
    final Color subText = isDark
        ? AppColors.surface.withOpacity(0.65)
        : AppColors.primarySoft.withOpacity(0.7);

    final String discountBadgeText = discountType == 'percentage'
        ? '$discountValue% OFF'
        : 'SP$discountValue OFF';

    return Container(
      width: 290,
      padding: const EdgeInsets.all(18),
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
                isDark ? 'EXCLUSIVE' : 'HOT DEAL',
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
                        _formatExpiryDate(endsAt),
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
                  'Claim',
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
    );
  }
}
