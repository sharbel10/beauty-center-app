import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/features/home/models/promotion_ui.dart';
import 'package:flutter/material.dart';

class PromotionCard extends StatelessWidget {
  const PromotionCard({
    required this.promotion,
    this.height = 220,
    super.key,
  });

  final PromotionUiModel promotion;
  final double height;

  @override
  Widget build(BuildContext context) {
    final Color background = promotion.isDark
        ? AppColors.primarySoft
        : AppColors.surface;
    final Color foreground = promotion.isDark
        ? AppColors.surface
        : AppColors.primary;

    return SizedBox(
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x0D0A2A55),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: <Widget>[
              Positioned(
                right: 0,
                bottom: 12,
                child: Icon(
                  Icons.local_florist_rounded,
                  size: 64,
                  color: promotion.isDark
                      ? const Color(0x224B6E90)
                      : AppColors.surfaceMuted,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.gold),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        promotion.badge,
                        style: AppTextStyles.smallCaps.copyWith(
                          color: AppColors.gold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      promotion.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(
                        color: foreground,
                        fontSize: 16,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      promotion.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle.copyWith(
                        color: promotion.isDark
                            ? AppColors.surface
                            : AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      promotion.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle.copyWith(
                        color: promotion.isDark
                            ? AppColors.surface.withValues(alpha: 0.9)
                            : AppColors.textSecondary,
                        fontSize: 11,
                        height: 1.25,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      promotion.price,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(
                        color: foreground,
                        fontSize: 17,
                      ),
                    ),
                    if (promotion.oldPrice.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 2),
                      Text(
                        promotion.oldPrice,
                        style: AppTextStyles.subtitle.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: promotion.isDark
                              ? AppColors.gold
                              : AppColors.primary,
                          foregroundColor: promotion.isDark
                              ? AppColors.primary
                              : AppColors.surface,
                          disabledBackgroundColor: promotion.isDark
                              ? AppColors.gold
                              : AppColors.primary,
                          disabledForegroundColor: promotion.isDark
                              ? AppColors.primary
                              : AppColors.surface,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          promotion.cta,
                          style: AppTextStyles.button.copyWith(
                            fontSize: 12,
                            color: promotion.isDark
                                ? AppColors.primary
                                : AppColors.surface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
