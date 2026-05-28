import 'package:beauty_center_app/features/clinic/cubit/clinic_services_cubit.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_services_state.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_details_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_services_response.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_service_card.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class ClinicServicesView extends StatelessWidget {
  const ClinicServicesView({required this.clinic, super.key});

  final ClinicCenterDetail clinic;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClinicServicesCubit, ClinicServicesState>(
      builder: (context, state) {
        final AppLocalizations l10n = AppLocalizations.of(context);

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

                            return ClinicServiceCard(
                              title: service.name,
                              description: service.description,
                              durationMinutes: service.durationMinutes,
                              preparationMinutes: service.preparationMinutes,
                              originalPrice: service.price.toDouble(),
                              finalPrice: service.finalPrice.toDouble(),
                              badge: service.salePrice != null
                                  ? l10n.clinicServiceBadgeOffer
                                  : (service.isFeatured
                                        ? l10n.clinicServiceBadgeFeatured
                                        : null),
                              darkBadge: service.salePrice == null &&
                                  service.isFeatured,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          }

          return const SizedBox.shrink();
        },
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
