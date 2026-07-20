import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/core/utils/map_launcher.dart';
import 'package:beauty_center_app/features/home/models/home_clinic_ui.dart';
import 'package:beauty_center_app/features/home/widgets/clinic_network_image.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class NearbyClinicCard extends StatefulWidget {
  const NearbyClinicCard({
    required this.clinic,
    this.onBookPressed,
    this.onCardTap,
    super.key,
  });

  final HomeClinicUiModel clinic;
  final VoidCallback? onBookPressed;
  final VoidCallback? onCardTap;

  static const double cardHeight = 188;
  static const double imageWidth = 108;

  @override
  State<NearbyClinicCard> createState() => _NearbyClinicCardState();
}

class _NearbyClinicCardState extends State<NearbyClinicCard> {
  HomeClinicUiModel get clinic => widget.clinic;

  String? get _shortDescription {
    final String? text = clinic.description?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  Future<void> _openInOpenStreetMap(double latitude, double longitude) async {
    try {
      final bool launched = await MapLauncher.openOpenStreetMap(
        latitude: latitude,
        longitude: longitude,
      );

      if (!launched && mounted) {
        context.showSnackbar(
          AppLocalizations.of(context).couldNotOpenMapsForLocation,
          isError: true,
        );
      }
    } catch (_) {
      if (mounted) {
        context.showSnackbar(
          AppLocalizations.of(context).couldNotOpenMapsForLocation,
          isError: true,
        );
      }
    }
  }

  Future<void> _onNavigationPressed() async {
    if (!clinic.hasCoordinates) {
      context.showSnackbar(
        AppLocalizations.of(context).locationUnavailableForClinic,
        isError: true,
      );
      return;
    }

    await _openInOpenStreetMap(clinic.latitude!, clinic.longitude!);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? description = _shortDescription;
    final String? region = clinic.cityAreaLabel;

    return InkWell(
      onTap: widget.onCardTap ?? () {},
      child: Container(
        height: NearbyClinicCard.cardHeight,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x080A2A55),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: NearbyClinicCard.imageWidth,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ClinicNetworkImage(imageUrl: clinic.imageUrl),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _IconCircle(
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Color(0xFFFF4D4D),
                        size: 16,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: _RatingBadge(rating: clinic.rating),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      clinic.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 16,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (description != null) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 11,
                          height: 1.3,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      clinic.reviewsLabel(l10n),
                      style: AppTextStyles.smallCaps.copyWith(
                        fontSize: 9,
                        color: AppColors.textMuted,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (region != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          region,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.subtitle.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            clinic.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        _NavigationButton(
                          enabled: clinic.hasCoordinates,
                          onPressed: _onNavigationPressed,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          clinic.distance,
                          style: AppTextStyles.link.copyWith(
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 36,
                        width: 92,
                        child: ElevatedButton(
                          onPressed: widget.onBookPressed ?? () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.book,
                            style: AppTextStyles.button.copyWith(
                              fontSize: 12,
                              color: AppColors.surface,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  const _IconCircle({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: Color(0xF5FFFFFF),
        shape: BoxShape.circle,
      ),
      child: Center(child: child),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.link.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(
            Icons.navigation_rounded,
            size: 16,
            color: enabled
                ? AppColors.primary
                : AppColors.textMuted.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}
