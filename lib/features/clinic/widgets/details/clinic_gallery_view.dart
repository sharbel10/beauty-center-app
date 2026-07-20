import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_portfolio_cubit.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_portfolio_state.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_services_cubit.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_services_state.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_details_response.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_network_image.dart'
    show ClinicNetworkImage;
import 'package:beauty_center_app/features/clinic/widgets/clinic_section_title.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class ClinicGalleryView extends StatelessWidget {
  const ClinicGalleryView({required this.clinic, super.key});

  final ClinicCenterDetail clinic;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<ClinicPortfolioCubit>()..fetchClinicPortfolio(clinic.id),
        ),
        BlocProvider(
          create: (context) =>
              getIt<ClinicServicesCubit>()..fetchClinicServices(clinic.id),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _GalleryEyebrow('THE EXPERIENCE'),
          const SizedBox(height: 8),
          const ClinicSectionTitle('Clinic Interior'),
          const SizedBox(height: 18),

          _InteriorCollage(images: clinic.images),

          const SizedBox(height: 42),
          const _GalleryEyebrow('REAL RESULTS'),
          const SizedBox(height: 8),
          const ClinicSectionTitle('Transformations'),
          const SizedBox(height: 18),

          const _DynamicTransformationsList(),

          const SizedBox(height: 42),
          const _GalleryEyebrow('CLINICAL PRECISION'),
          const SizedBox(height: 8),
          const ClinicSectionTitle('Skin Procedures'),
          const SizedBox(height: 18),
          const _ProceduresGrid(),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class _DynamicTransformationsList extends StatelessWidget {
  const _DynamicTransformationsList();

  @override
  Widget build(BuildContext context) {
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
                    : 'Clinical Transformation Result',
                badge: 'RESULT',
                beforeImage: item.beforeImagePath,
                afterImage: item.afterImagePath,
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

    final String firstImage = images.isNotEmpty
        ? images[0].imagePath
        : fallbackReception;
    final String secondImage = images.length > 1
        ? images[1].imagePath
        : fallbackTreatment;
    final String thirdImage = images.length > 2
        ? images[2].imagePath
        : fallbackShelf;

    return SizedBox(
      height: 288,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 6,
            child: ClinicNetworkImage(
              imageUrl: firstImage,
              placeholderIcon: Icons.storefront_outlined,
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            flex: 4,
            child: Column(
              children: [
                Expanded(
                  child: ClinicNetworkImage(
                    imageUrl: secondImage,
                    placeholderIcon: Icons.storefront_outlined,
                  ),
                ),
                const SizedBox(height: 14),

                Expanded(
                  child: ClinicNetworkImage(
                    imageUrl: thirdImage,
                    placeholderIcon: Icons.storefront_outlined,
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
                  label: 'BEFORE',
                  isAfter: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TransformationImage(
                  imageUrl: afterImage,
                  label: 'AFTER',
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 0.78,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClinicNetworkImage(imageUrl: imageUrl),
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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

class _ProceduresGrid extends StatelessWidget {
  const _ProceduresGrid();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClinicServicesCubit, ClinicServicesState>(
      builder: (context, state) {
        if (state is ClinicServicesLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }

        if (state is ClinicServicesSuccess) {
          final items = state.services.take(4).toList();

          if (items.isEmpty) {
            return const _EmptyStateCard(title: 'No Procedures Available');
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.02,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _ProcedureTile(label: item.name, imageUrl: item.imagePath);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ProcedureTile extends StatelessWidget {
  const _ProcedureTile({required this.label, required this.imageUrl});
  final String label;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClinicNetworkImage(imageUrl: imageUrl),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0xAA000000)],
              ),
            ),
          ),
          Positioned(
            left: 10,
            bottom: 10,
            right: 10,
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.link.copyWith(
                color: AppColors.surface,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPortfolioCard extends StatelessWidget {
  const _EmptyPortfolioCard();

  @override
  Widget build(BuildContext context) {
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
            color: AppColors.primarySoft.withOpacity(0.4),
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            'No Transformations Logged Yet',
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
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
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
            color: AppColors.primarySoft.withOpacity(0.4),
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            title,
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
