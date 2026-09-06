import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/features/book_treatment/models/book_treatment_args.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_employees_cubit.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_employees_state.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_offers_cubit.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_offers_state.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_details_response.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_map_card.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_network_image.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_offer_card.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_section_title.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ClinicOverviewView extends StatelessWidget {
  const ClinicOverviewView({required this.clinic, super.key});

  final ClinicCenterDetail clinic;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String description = clinic.description?.trim().isNotEmpty == true
        ? clinic.description!.trim()
        : l10n.clinicCenter;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<ClinicOffersCubit>()..fetchClinicOffers(clinic.id),
        ),
        BlocProvider(
          create: (context) =>
              getIt<ClinicEmployeesCubit>()..fetchClinicEmployees(clinic.id),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClinicSectionTitle(l10n.clinicAbout),
          const SizedBox(height: 18),
          Text(
            description,
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.textSecondary,
              fontSize: 17,
              height: 1.48,
            ),
          ),
          const SizedBox(height: 44),
          ClinicSectionTitle(l10n.clinicLocation),
          const SizedBox(height: 18),
          ClinicMapCard(clinic: clinic),
          const SizedBox(height: 44),
          BlocBuilder<ClinicOffersCubit, ClinicOffersState>(
            builder: (context, state) {
              return Row(
                children: [
                  Expanded(child: ClinicSectionTitle(l10n.clinicSpecialOffers)),
                ],
              );
            },
          ),
          const SizedBox(height: 18),

          _OffersList(centerId: clinic.id),
          const SizedBox(height: 44),
          ClinicSectionTitle(l10n.clinicOurSpecialists),
          const SizedBox(height: 18),
          const _SpecialistsList(),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}

class _OffersList extends StatelessWidget {
  const _OffersList({required this.centerId});

  final int centerId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClinicOffersCubit, ClinicOffersState>(
      builder: (context, state) {
        if (state is ClinicOffersLoading) {
          return const _OffersShimmerLoading();
        }

        if (state is ClinicOffersFailure) {
          return const SizedBox.shrink();
        }

        if (state is ClinicOffersSuccess) {
          final offers = state.offers;

          if (offers.isEmpty) {
            return const _EmptyOffersCard();
          }

          return SizedBox(
            height: 170,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: offers.length,
              itemBuilder: (context, index) {
                final offer = offers[index];
                final bool isDark = index % 2 == 0;

                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: ClinicOfferCard(
                    title: offer.title,
                    description: offer.description,
                    discountValue: offer.discountValue,
                    discountType: offer.discountType,
                    endsAt: offer.endsAt,
                    isDark: isDark,
                    onTap: () {
                      context.pushNamed(
                        RouteNames.bookTreatment,
                        extra: BookTreatmentArgs(
                          centerId: offer.centerId == 0
                              ? centerId
                              : offer.centerId,
                          initialServiceId: offer.serviceId,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _EmptyOffersCard extends StatelessWidget {
  const _EmptyOffersCard();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_offer_outlined,
            color: Color(0xFF9CA3AF),
            size: 36,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.clinicNoOffersTitle,
            style: AppTextStyles.subtitle.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4B5563),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.clinicNoOffersSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.smallCaps.copyWith(
              fontSize: 12,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class _OffersShimmerLoading extends StatelessWidget {
  const _OffersShimmerLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 2,
        itemBuilder: (context, index) => Container(
          width: 240,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class _SpecialistsList extends StatelessWidget {
  const _SpecialistsList();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return BlocBuilder<ClinicEmployeesCubit, ClinicEmployeesState>(
      builder: (context, state) {
        if (state is ClinicEmployeesLoading) {
          return const SizedBox(
            height: 70,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          );
        }

        if (state is ClinicEmployeesFailure) {
          return const SizedBox.shrink();
        }

        if (state is ClinicEmployeesSuccess) {
          final specialists = state.employees;

          if (specialists.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.clinicNoSpecialists,
                style: AppTextStyles.subtitle.copyWith(fontSize: 13),
              ),
            );
          }

          return SizedBox(
            height: 70,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: specialists.length,
              separatorBuilder: (context, index) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final employee = specialists[index];
                return _SpecialistCard(
                  name: employee.name,
                  specialization: employee.specialization,
                  avatarUrl: employee.avatarUrl,
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _SpecialistCard extends StatelessWidget {
  const _SpecialistCard({
    required this.name,
    required this.specialization,
    required this.avatarUrl,
  });

  final String name;
  final String specialization;
  final String avatarUrl;

  _AvatarTheme _getAvatarTheme(String employeeName) {
    final List<_AvatarTheme> luxuryPalettes = [
      const _AvatarTheme(Color(0xFFFFF0F5), Color(0xFFD81B60)),
      const _AvatarTheme(Color(0xFFE8F8F5), Color(0xFF117A65)),
      const _AvatarTheme(Color(0xFFFEF9E7), Color(0xFFB7950B)),
      const _AvatarTheme(Color(0xFFF4ECF7), Color(0xFF6C3483)),
      const _AvatarTheme(Color(0xFFEAF2F8), Color(0xFF2471A3)),
      const _AvatarTheme(Color(0xFFFBEEE6), Color(0xFFA04000)),
    ];

    final int index = employeeName.hashCode.abs() % luxuryPalettes.length;
    return luxuryPalettes[index];
  }

  @override
  Widget build(BuildContext context) {
    final avatarTheme = _getAvatarTheme(name);

    final Widget coloredPersonIcon = Center(
      child: Icon(Icons.person_rounded, color: avatarTheme.iconColor, size: 26),
    );

    return Container(
      width: 190,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFEFEF), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: avatarTheme.background,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: ClinicNetworkImage(
                imageUrl: avatarUrl,
                errorWidget: coloredPersonIcon,
                placeholderIcon: Icons.person_rounded,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.link.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  specialization,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarTheme {
  final Color background;
  final Color iconColor;
  const _AvatarTheme(this.background, this.iconColor);
}
