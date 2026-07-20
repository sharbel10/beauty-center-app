// ignore_for_file: unused_local_variable

import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_services_cubit.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_services_state.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_details_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_services_response.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_service_card.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ClinicServicesView extends StatelessWidget {
  const ClinicServicesView({required this.clinic, super.key});

  final ClinicCenterDetail clinic;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (context) =>
          getIt<ClinicServicesCubit>()..fetchClinicServices(clinic.id),
      child: BlocBuilder<ClinicServicesCubit, ClinicServicesState>(
        builder: (context, state) {
          if (state is ClinicServicesLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            );
          }

          if (state is ClinicServicesFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  state.errorMessage,
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
                ),
              ),
            );
          }

          if (state is ClinicServicesSuccess) {
            final grouped = state.services.groupByCategory;

            if (grouped.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(l10n.clinicNoServices),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...grouped.entries.map((entry) {
                  final category = entry.key;
                  final servicesList = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ServicesSectionHeader(
                          title: category.name,
                          count: l10n.clinicServicesCount(servicesList.length),
                        ),
                        const SizedBox(height: 16),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: servicesList.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final service = servicesList[index];

                            String? badgeText;
                            bool isDarkBadge = false;
                            if (service.salePrice != null) {
                              badgeText = l10n.clinicServiceBadgeOffer;
                            } else if (service.isFeatured) {
                              badgeText = l10n.clinicServiceBadgeBestSeller;
                              isDarkBadge = true;
                            }

                            return ClinicServiceCard(
                              title: service.name,
                              description: service.description,
                              durationMinutes: service.durationMinutes,
                              preparationMinutes: service.preparationMinutes,
                              originalPrice: service.price.toDouble(),
                              finalPrice: service.finalPrice.toDouble(),
                              // توليد بادج العرض تلقائياً إذا كان هناك سعر تخفيض
                              badge: service.salePrice != null
                                  ? l10n.clinicServiceBadgeOffer
                                  : (service.isFeatured
                                      ? l10n.clinicServiceBadgeFeatured
                                      : null),
                              darkBadge: service.salePrice != null
                                  ? false
                                  : true,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 24),
                ClinicBookingPoliciesPanel(
                  confirmationType: clinic.bookingConfirmationType,
                  depositType: clinic.depositType,
                  depositValue: clinic.depositValue,
                ),
                const SizedBox(height: 24),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ServicesSectionHeader extends StatelessWidget {
  const _ServicesSectionHeader({required this.title, required this.count});

  final String title;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: AppTextStyles.title.copyWith(fontSize: 22)),
        ),
        Text(
          count,
          style: AppTextStyles.smallCaps.copyWith(
            color: const Color(0xFF7B5A21),
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

extension ClinicServiceGrouping on List<ClinicServiceItem> {
  Map<ServiceCategory, List<ClinicServiceItem>> get groupByCategory {
    final Map<ServiceCategory, List<ClinicServiceItem>> groups = {};
    for (var service in this) {
      final existingCategory = groups.keys.firstWhere(
        (cat) => cat.id == service.category.id,
        orElse: () => service.category,
      );
      groups.putIfAbsent(existingCategory, () => []).add(service);
    }
    return groups;
  }
}

class ClinicBookingPoliciesPanel extends StatelessWidget {
  const ClinicBookingPoliciesPanel({
    required this.confirmationType,
    required this.depositType,
    required this.depositValue,
    super.key,
  });

  final String confirmationType;
  final String depositType;
  final int depositValue;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String confirmationTitle;
    final IconData confirmationIcon;
    final Color confirmationIconColor;
    final Color confirmationBgColor;

    if (confirmationType.toLowerCase() == 'free' ||
        confirmationType.toLowerCase() == 'instant') {
      confirmationTitle = l10n.clinicInstantConfirmation;
      confirmationIcon = Icons.bolt_rounded;
      confirmationIconColor = const Color(0xFF2E7D32);
      confirmationBgColor = const Color(0xFFE8F5E9);
    } else {
      confirmationTitle = l10n.clinicRequiresApproval;
      confirmationIcon = Icons.hourglass_empty_rounded;
      confirmationIconColor = const Color(0xFFE65100);
      confirmationBgColor = const Color(0xFFFFF3E0);
    }

    final String depositTitle;
    final IconData depositIcon;
    final Color depositIconColor;
    final Color depositBgColor;

    if (depositType.toLowerCase() == 'none' || depositValue == 0) {
      depositTitle = l10n.clinicNoDepositRequired;
      depositIcon = Icons.verified_user_rounded;
      depositIconColor = AppColors.gold;
      depositBgColor = const Color(0xFFFFFDE7);
    } else if (depositType.toLowerCase() == 'percentage') {
      depositTitle = l10n.clinicDepositPercentage(depositValue);
      depositIcon = Icons.pie_chart_rounded;
      depositIconColor = AppColors.gold;
      depositBgColor = const Color(0xFFFFFDE7);
    } else {
      depositTitle = l10n.clinicDepositAmount(depositValue);
      depositIcon = Icons.credit_card_rounded;
      depositIconColor = AppColors.gold;
      depositBgColor = const Color(0xFFFFFDE7);
    }

    return Row(
      children: [
        Expanded(
          child: _PolicyBadge(
            icon: confirmationIcon,
            title: confirmationTitle,
            iconColor: confirmationIconColor,
            backgroundColor: confirmationBgColor,
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: _PolicyBadge(
            icon: depositIcon,
            title: depositTitle,
            iconColor: depositIconColor,
            backgroundColor: depositBgColor,
          ),
        ),
      ],
    );
  }
}

class _PolicyBadge extends StatelessWidget {
  const _PolicyBadge({
    required this.icon,
    required this.title,
    required this.iconColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final String title;
  final Color iconColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      height: 65,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEFEFEF), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.link.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2A2F38),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
