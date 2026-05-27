import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/core/utils/map_launcher.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_details_response.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_network_image.dart';
import 'package:flutter/material.dart';

class ClinicMapCard extends StatelessWidget {
  const ClinicMapCard({required this.clinic, super.key});

  final ClinicCenterDetail clinic;

  String? get _dynamicMapImageUrl {
    if (!clinic.hasCoordinates ||
        clinic.latitude == null ||
        clinic.longitude == null) {
      return null;
    }

    const String apiKey = '433522dad3cf4998902d8ffb2d18e985';

    return 'https://maps.geoapify.com/v1/staticmap'
        '?style=osm-bright'
        '&width=700'
        '&height=360'
        '&center=lonlat:${clinic.longitude},${clinic.latitude}'
        '&zoom=15'
        '&lang=en'
        '&marker=lonlat:${clinic.longitude},${clinic.latitude};color:%23be9b46;size:medium'
        '&apiKey=$apiKey';
  }

  Future<void> _openInOpenStreetMap(
    double latitude,
    double longitude,
    BuildContext context,
  ) async {
    try {
      final bool launched = await MapLauncher.openOpenStreetMap(
        latitude: latitude,
        longitude: longitude,
      );

      if (!launched && context.mounted) {
        context.showSnackbar(
          'Could not open maps for this location.',
          isError: true,
        );
      }
    } catch (_) {
      if (context.mounted) {
        context.showSnackbar(
          'Could not open maps for this location.',
          isError: true,
        );
      }
    }
  }

  Future<void> _onNavigationPressed(BuildContext context) async {
    if (!clinic.hasCoordinates) {
      context.showSnackbar(
        'Location is not available for this clinic.',
        isError: true,
      );
      return;
    }

    await _openInOpenStreetMap(clinic.latitude!, clinic.longitude!, context);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: SizedBox(
        height: 192,
        child: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              onTap: () => _onNavigationPressed(context),
              child: ClinicNetworkImage(
                headers: const {
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                },
                imageUrl: _dynamicMapImageUrl ?? '',
                placeholderIcon: Icons.map_outlined,
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clinic.area,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.link.copyWith(fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            clinic.distance != null
                                ? '${clinic.distance} | ${clinic.address}'
                                : clinic.address,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    GestureDetector(
                      onTap: () => _onNavigationPressed(context),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.near_me_rounded,
                          color: AppColors.surface,
                          size: 19,
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
