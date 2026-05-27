import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ClinicServiceCard extends StatelessWidget {
  const ClinicServiceCard({
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.preparationMinutes,
    required this.originalPrice,
    required this.finalPrice,
    this.badge,
    this.darkBadge = false,
    super.key,
  });

  final String title;
  final String description;
  final int durationMinutes;
  final int preparationMinutes;
  final double originalPrice;
  final double finalPrice;
  final String? badge;
  final bool darkBadge;

  @override
  Widget build(BuildContext context) {
    final bool hasDiscount = originalPrice > finalPrice;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100A2A55),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.link.copyWith(
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 12),
                _ServiceBadge(label: badge!, isDark: darkBadge),
              ],
            ],
          ),
          const SizedBox(height: 8),

          Text(
            description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.subtitle.copyWith(
              fontSize: 13,
              height: 1.45,
              color: const Color(0xFF4D5560),
            ),
          ),
          const SizedBox(height: 22),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 16,
                color: Color(0xFF806221),
              ),
              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$durationMinutes min',
                    style: AppTextStyles.subtitle.copyWith(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (preparationMinutes > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      '+ $preparationMinutes min prep',
                      style: AppTextStyles.subtitle.copyWith(
                        color: const Color(0xFF9EA6B0),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),

              const Spacer(),

              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  if (hasDiscount) ...[
                    Text(
                      '${_formatPriceWithCommas(originalPrice)} SP',
                      style: const TextStyle(
                        color: Color(0xFF9EA6B0),
                        fontSize: 12,
                        decoration: TextDecoration.lineThrough,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    '${_formatPriceWithCommas(finalPrice)} SP',
                    style: AppTextStyles.title.copyWith(
                      fontSize: 18,
                      color: hasDiscount
                          ? const Color(0xFFD32F2F)
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPriceWithCommas(double price) {
    String val = price.toStringAsFixed(0);
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return val.replaceAllMapped(reg, (Match match) => '${match[1]},');
  }
}

class _ServiceBadge extends StatelessWidget {
  const _ServiceBadge({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primarySoft : const Color(0xFFFFD996),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: AppTextStyles.smallCaps.copyWith(
          color: isDark ? AppColors.surface : const Color(0xFF6B4D17),
          fontSize: 8,
        ),
      ),
    );
  }
}
