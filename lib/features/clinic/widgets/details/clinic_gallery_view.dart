import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_portfolio_cubit.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_portfolio_state.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_details_response.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_image_preview.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_network_image.dart'
    show ClinicNetworkImage;
import 'package:beauty_center_app/features/clinic/widgets/clinic_section_title.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ClinicGalleryView extends StatelessWidget {
  const ClinicGalleryView({required this.clinic, super.key});

  final ClinicCenterDetail clinic;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) =>
          getIt<ClinicPortfolioCubit>()..fetchClinicPortfolio(clinic.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GalleryEyebrow(l10n.clinicGalleryExperienceEyebrow),
          const SizedBox(height: 8),
          ClinicSectionTitle(l10n.clinicGalleryInteriorTitle),
          const SizedBox(height: 18),
          _InteriorCollage(images: clinic.images),
          const SizedBox(height: 42),
          _GalleryEyebrow(l10n.clinicGalleryResultsEyebrow),
          const SizedBox(height: 8),
          ClinicSectionTitle(l10n.clinicGalleryTransformationsTitle),
          const SizedBox(height: 18),
          const _DynamicTransformationsList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _DynamicTransformationsList extends StatelessWidget {
  const _DynamicTransformationsList();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return BlocBuilder<ClinicPortfolioCubit, ClinicPortfolioState>(
      builder: (context, state) {
        if (state is ClinicPortfolioLoading) {
          return const _TransformationsShimmer();
        }

        if (state is ClinicPortfolioFailure) {
          return const SizedBox.shrink();
        }

        if (state is ClinicPortfolioSuccess) {
          final portfolioList = state.portfolio;

          if (portfolioList.isEmpty) {
            return const _EmptyPortfolioCard();
          }

          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: portfolioList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 18),
            itemBuilder: (context, index) {
              final item = portfolioList[index];

              return _TransformationCard(
                title: item.caption.isNotEmpty
                    ? item.caption
                    : l10n.clinicGalleryDefaultTransformationCaption,
                badge: l10n.clinicGalleryResultBadge,
                beforeImage: item.beforeImageUrl,
                afterImage: item.afterImageUrl,
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _GalleryEyebrow extends StatelessWidget {
  const _GalleryEyebrow(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.smallCaps.copyWith(
        color: AppColors.gold,
        fontSize: 9,
      ),
    );
  }
}

class _InteriorCollage extends StatelessWidget {
  const _InteriorCollage({required this.images});

  final List<CenterImage> images;

  @override
  Widget build(BuildContext context) {
    const String fallbackReception =
        'https://images.pexels.com/photos/16571736/pexels-photo-16571736.jpeg?auto=compress&cs=tinysrgb&w=900';
    const String fallbackTreatment =
        'https://images.pexels.com/photos/7789602/pexels-photo-7789602.jpeg?auto=compress&cs=tinysrgb&w=700';
    const String fallbackShelf =
        'https://images.pexels.com/photos/16571739/pexels-photo-16571739.jpeg?auto=compress&cs=tinysrgb&w=700';

    final List<String> availableImages = images
        .map((CenterImage image) => image.imageUrl.trim())
        .where((String path) => path.isNotEmpty)
        .toList();

    final String? firstImage = availableImages.firstOrNull;
    final String? secondImage = availableImages.length > 1
        ? availableImages[1]
        : null;
    final String? thirdImage = availableImages.length > 2
        ? availableImages[2]
        : null;

    return SizedBox(
      height: 288,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 6,
            child: _GalleryImage(
              imageUrl: firstImage,
              fallbackUrl: fallbackReception,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: _GalleryImage(
                    imageUrl: secondImage,
                    fallbackUrl: fallbackTreatment,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: _GalleryImage(
                    imageUrl: thirdImage,
                    fallbackUrl: fallbackShelf,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GalleryImage extends StatelessWidget {
  const _GalleryImage({required this.imageUrl, required this.fallbackUrl});

  final String? imageUrl;
  final String fallbackUrl;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = hasClinicImageUrl(imageUrl);

    if (!hasImage) {
      return ClinicNetworkImage(
        imageUrl: fallbackUrl,
        placeholderIcon: Icons.storefront_outlined,
      );
    }

    final String loadedImageUrl = imageUrl!;
    return ClinicPreviewableImage(
      imageUrl: loadedImageUrl,
      builder: (VoidCallback onLoaded, VoidCallback onError) =>
          ClinicNetworkImage(
            imageUrl: loadedImageUrl,
            placeholderIcon: Icons.storefront_outlined,
            onLoaded: onLoaded,
            onError: onError,
          ),
    );
  }
}

class _TransformationCard extends StatelessWidget {
  const _TransformationCard({
    required this.title,
    required this.badge,
    required this.beforeImage,
    required this.afterImage,
  });

  final String title;
  final String badge;
  final String beforeImage;
  final String afterImage;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
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
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.link.copyWith(
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ),
              _SoftBadge(label: badge),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _TransformationImage(
                  imageUrl: beforeImage,
                  label: l10n.clinicGalleryBeforeLabel,
                  isAfter: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TransformationImage(
                  imageUrl: afterImage,
                  label: l10n.clinicGalleryAfterLabel,
                  isAfter: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransformationImage extends StatelessWidget {
  const _TransformationImage({
    required this.imageUrl,
    required this.label,
    required this.isAfter,
  });

  final String imageUrl;
  final String label;
  final bool isAfter;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = hasClinicImageUrl(imageUrl);
    Widget buildImage({VoidCallback? onLoaded, VoidCallback? onError}) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 0.78,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClinicNetworkImage(
                imageUrl: imageUrl,
                onLoaded: onLoaded,
                onError: onError,
              ),
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isAfter
                        ? const Color(0xFFC9AD72)
                        : const Color(0xFF29475B),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    label,
                    style: AppTextStyles.smallCaps.copyWith(
                      color: AppColors.surface,
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!hasImage) {
      return buildImage();
    }

    return ClinicPreviewableImage(
      imageUrl: imageUrl,
      builder: (VoidCallback onLoaded, VoidCallback onError) =>
          buildImage(onLoaded: onLoaded, onError: onError),
    );
  }
}

class _SoftBadge extends StatelessWidget {
  const _SoftBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        label,
        style: AppTextStyles.smallCaps.copyWith(
          color: const Color(0xFF6B4D17),
          fontSize: 8,
        ),
      ),
    );
  }
}

class _EmptyPortfolioCard extends StatelessWidget {
  const _EmptyPortfolioCard();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            color: AppColors.primarySoft.withValues(alpha: 0.4),
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.clinicGalleryNoTransformations,
            style: AppTextStyles.subtitle.copyWith(
              fontSize: 13,
              color: AppColors.primarySoft,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransformationsShimmer extends StatelessWidget {
  const _TransformationsShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
