import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_details_response.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'clinic_network_image.dart';

class ClinicDetailsTopBar extends StatelessWidget {
  const ClinicDetailsTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 58,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.primary,
            ),
            Expanded(
              child: Text(
                l10n.clinicDetailsTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.link.copyWith(fontSize: 18),
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.share_rounded),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class ClinicDetailsHero extends StatelessWidget {
  const ClinicDetailsHero({required this.clinic, super.key});

  final ClinicCenterDetail clinic;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 260,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClinicNetworkImage(
            imageUrl: _mediaUrl(clinic.coverPath),
            placeholderIcon: Icons.storefront_outlined,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x11000000),
                  Color(0x22000000),
                  Color(0xCC000000),
                ],
              ),
            ),
          ),
          Positioned(
            top: 22,
            right: 22,
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                color: Color(0xCCFFFFFF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: AppColors.danger,
                size: 25,
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 22,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (clinic.isFeatured) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD996),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      l10n.clinicTopRated,
                      style: AppTextStyles.smallCaps.copyWith(
                        color: const Color(0xFF5C4218),
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  clinic.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headline.copyWith(
                    color: AppColors.surface,
                    fontSize: 28,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _HeroMeta(
                      icon: Icons.star_rounded,
                      text: l10n.clinicHeroRatingReviews(
                        clinic.averageRating.toStringAsFixed(1),
                        l10n.reviewsCount(clinic.ratingsCount),
                      ),
                      iconColor: AppColors.gold,
                    ),
                    const Text('|', style: TextStyle(color: AppColors.surface)),
                    _HeroMeta(
                      icon: Icons.location_on_rounded,
                      text: "${clinic.city},${clinic.area}",
                      iconColor: AppColors.surface,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _mediaUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    if (path.startsWith('http')) {
      return path;
    }
    return ApiEndpoints.mediaUrl(path);
  }
}

class _HeroMeta extends StatelessWidget {
  const _HeroMeta({
    required this.icon,
    required this.text,
    required this.iconColor,
  });

  final IconData icon;
  final String text;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 17),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.surface,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
