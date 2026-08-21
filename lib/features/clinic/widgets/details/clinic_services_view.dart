// ignore_for_file: unused_local_variable

import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_services_cubit.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_services_state.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_details_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_services_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinic_service_filters.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_service_card.dart';
import 'package:beauty_center_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:beauty_center_app/features/favorites/cubit/favorites_state.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClinicServicesView extends StatelessWidget {
  const ClinicServicesView({required this.clinic, super.key});

  final ClinicCenterDetail clinic;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (BuildContext context) =>
          getIt<ClinicServicesCubit>()..fetchClinicServices(clinic.id),
      child: BlocProvider<FavoritesCubit>(
        create: (_) => getIt<FavoritesCubit>(),
        child: BlocListener<FavoritesCubit, FavoritesState>(
          listenWhen: (FavoritesState previous, FavoritesState current) {
            return previous.message != current.message &&
                current.message != null;
          },
          listener: (BuildContext context, FavoritesState state) {
            if (state.message != null) {
              context.showSnackbar(
                state.message!,
                isError: state.isMessageError,
              );
              context.read<FavoritesCubit>().clearMessage();
            }
          },
          child: BlocBuilder<ClinicServicesCubit, ClinicServicesState>(
            builder: (BuildContext context, ClinicServicesState state) {
              if (state.isLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: AppColors.gold),
                  ),
                );
              }

              if (state.status == ClinicServicesStatus.failure) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          state.message ?? l10n.clinicDetailsLoadFailed,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.red,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context
                              .read<ClinicServicesCubit>()
                              .fetchClinicServices(clinic.id),
                          child: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state.status == ClinicServicesStatus.success) {
                final Map<ServiceCategory, List<ClinicServiceItem>> grouped =
                    state.services.groupByCategory;

                if (grouped.isEmpty) {
                  return Column(
                    children: <Widget>[
                      _ClinicServiceFiltersBar(
                        state: state,
                        onSearchChanged: context
                            .read<ClinicServicesCubit>()
                            .onSearchChanged,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(l10n.clinicNoServices),
                      ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _ClinicServiceFiltersBar(
                      state: state,
                      onSearchChanged: context
                          .read<ClinicServicesCubit>()
                          .onSearchChanged,
                    ),
                    const SizedBox(height: 20),
                    ...grouped.entries.map((
                      MapEntry<ServiceCategory, List<ClinicServiceItem>> entry,
                    ) {
                      final ServiceCategory category = entry.key;
                      final List<ClinicServiceItem> servicesList = entry.value;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _ServicesSectionHeader(
                              title: category.name,
                              count: l10n.clinicServicesCount(
                                servicesList.length,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: servicesList.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 14),
                              itemBuilder: (BuildContext context, int index) {
                                final ClinicServiceItem service =
                                    servicesList[index];

                                return ClinicServiceCard(
                                  title: service.name,
                                  description: service.description,
                                  durationMinutes: service.durationMinutes,
                                  preparationMinutes:
                                      service.preparationMinutes,
                                  originalPrice: service.price.toDouble(),
                                  finalPrice: service.finalPrice.toDouble(),
                                  badge: service.salePrice != null
                                      ? l10n.clinicServiceBadgeOffer
                                      : (service.isFeatured
                                            ? l10n.clinicServiceBadgeFeatured
                                            : null),
                                  darkBadge: service.salePrice != null
                                      ? false
                                      : true,
                                  isFavorite: service.isFavorite,
                                  onFavoriteToggle:
                                      (bool isCurrentlyFavorite) async {
                                        await context
                                            .read<FavoritesCubit>()
                                            .toggleServiceFavorite(
                                              serviceId: service.id,
                                              isCurrentlyFavorite:
                                                  isCurrentlyFavorite,
                                            );
                                      },
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
        ),
      ),
    );
  }
}

class _ClinicServiceFiltersBar extends StatelessWidget {
  const _ClinicServiceFiltersBar({
    required this.state,
    required this.onSearchChanged,
  });
  final ClinicServicesState state;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Map<int, ServiceCategory> categories = <int, ServiceCategory>{
      for (final ClinicServiceItem service in state.services)
        service.category.id: service.category,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                key: ValueKey<String>(state.filters.query),
                initialValue: state.filters.query,
                maxLength: 255,
                onChanged: onSearchChanged,
                decoration: InputDecoration(
                  hintText: l10n.searchClinicsOrTreatments,
                  counterText: '',
                  prefixIcon: const Icon(Icons.search_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filledTonal(
              onPressed: () {
                final ClinicServicesCubit cubit = context
                    .read<ClinicServicesCubit>();
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => BlocProvider<ClinicServicesCubit>.value(
                    value: cubit,
                    child: _ClinicServiceFilterSheet(
                      initial: state.filters,
                      categories: categories.values.toList(),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.tune_rounded),
            ),
          ],
        ),
        if (state.filters.isActive) ...<Widget>[
          const SizedBox(height: 8),
          ActionChip(
            avatar: const Icon(Icons.close_rounded, size: 16),
            label: Text(l10n.clearFilters),
            onPressed: context.read<ClinicServicesCubit>().resetFilters,
          ),
        ],
      ],
    );
  }
}

class _ClinicServiceFilterSheet extends StatefulWidget {
  const _ClinicServiceFilterSheet({
    required this.initial,
    required this.categories,
  });
  final ClinicServiceFilters initial;
  final List<ServiceCategory> categories;
  @override
  State<_ClinicServiceFilterSheet> createState() =>
      _ClinicServiceFilterSheetState();
}

class _ClinicServiceFilterSheetState extends State<_ClinicServiceFilterSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _minPrice;
  late TextEditingController _maxPrice;
  late TextEditingController _maxDuration;
  int? _categoryId;
  bool? _isFeatured;
  String? _sortBy;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initial.categoryId;
    _isFeatured = widget.initial.isFeatured;
    _sortBy = widget.initial.sortBy;
    _minPrice = TextEditingController(
      text: widget.initial.minPrice?.toString() ?? '',
    );
    _maxPrice = TextEditingController(
      text: widget.initial.maxPrice?.toString() ?? '',
    );
    _maxDuration = TextEditingController(
      text: widget.initial.maxDuration?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _minPrice.dispose();
    _maxPrice.dispose();
    _maxDuration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            22,
            16,
            22,
            22 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      l10n.filters,
                      style: AppTextStyles.title.copyWith(fontSize: 22),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              DropdownButtonFormField<int?>(
                initialValue: _categoryId,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: l10n.categories,
                  border: const OutlineInputBorder(),
                ),
                items: <DropdownMenuItem<int?>>[
                  DropdownMenuItem<int?>(value: null, child: Text(l10n.all)),
                  if (_categoryId != null &&
                      !widget.categories.any(
                        (ServiceCategory category) =>
                            category.id == _categoryId,
                      ))
                    DropdownMenuItem<int?>(
                      value: _categoryId,
                      child: Text('#$_categoryId'),
                    ),
                  ...widget.categories.map(
                    (category) => DropdownMenuItem<int?>(
                      value: category.id,
                      child: Text(category.name),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _categoryId = value),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<bool?>(
                initialValue: _isFeatured,
                decoration: InputDecoration(
                  labelText: l10n.featuredOnly,
                  border: const OutlineInputBorder(),
                ),
                items: <DropdownMenuItem<bool?>>[
                  DropdownMenuItem<bool?>(
                    value: null,
                    child: Text(l10n.anyOption),
                  ),
                  DropdownMenuItem<bool?>(
                    value: true,
                    child: Text(l10n.yesOption),
                  ),
                  DropdownMenuItem<bool?>(
                    value: false,
                    child: Text(l10n.noOption),
                  ),
                ],
                onChanged: (value) => setState(() => _isFeatured = value),
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _ServiceNumberField(
                      label: l10n.min,
                      controller: _minPrice,
                      min: 0,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ServiceNumberField(
                      label: l10n.max,
                      controller: _maxPrice,
                      min: 0,
                      validator: (_) => _priceError(l10n),
                    ),
                  ),
                ],
              ),
              _ServiceNumberField(
                label: l10n.maxDuration,
                controller: _maxDuration,
                min: 0,
                integerOnly: true,
              ),
              DropdownButtonFormField<String?>(
                initialValue: _sortBy,
                decoration: InputDecoration(
                  labelText: l10n.sortBy,
                  border: const OutlineInputBorder(),
                ),
                items: <DropdownMenuItem<String?>>[
                  DropdownMenuItem<String?>(
                    value: null,
                    child: Text(l10n.anyOption),
                  ),
                  ...clinicServiceSortOptions.map(
                    (value) => DropdownMenuItem<String?>(
                      value: value,
                      child: Text(_serviceSortLabel(l10n, value)),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _sortBy = value),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        final cubit = context.read<ClinicServicesCubit>();
                        Navigator.pop(context);
                        cubit.resetFilters();
                      },
                      child: Text(l10n.reset),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _apply,
                      child: Text(l10n.apply),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _priceError(AppLocalizations l10n) {
    final double? min = double.tryParse(_minPrice.text.trim());
    final double? max = double.tryParse(_maxPrice.text.trim());
    return min != null && max != null && max < min
        ? l10n.invalidPriceRange
        : null;
  }

  void _apply() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final cubit = context.read<ClinicServicesCubit>();
    final filters = ClinicServiceFilters(
      query: widget.initial.query,
      categoryId: _categoryId,
      isFeatured: _isFeatured,
      minPrice: double.tryParse(_minPrice.text.trim()),
      maxPrice: double.tryParse(_maxPrice.text.trim()),
      maxDuration: int.tryParse(_maxDuration.text.trim()),
      sortBy: _sortBy,
    );
    Navigator.pop(context);
    cubit.applyFilters(filters);
  }
}

class _ServiceNumberField extends StatelessWidget {
  const _ServiceNumberField({
    required this.label,
    required this.controller,
    required this.min,
    this.validator,
    this.integerOnly = false,
  });
  final String label;
  final TextEditingController controller;
  final double min;
  final FormFieldValidator<String>? validator;
  final bool integerOnly;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: !integerOnly),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final input = value?.trim() ?? '';
        if (input.isNotEmpty) {
          final number = integerOnly
              ? int.tryParse(input)?.toDouble()
              : double.tryParse(input);
          if (number == null || number < min) {
            return AppLocalizations.of(context).invalidFilterValue;
          }
        }
        return validator?.call(value);
      },
    ),
  );
}

String _serviceSortLabel(AppLocalizations l10n, String value) =>
    switch (value) {
      'price_asc' => l10n.sortPriceAsc,
      'price_desc' => l10n.sortPriceDesc,
      'duration' => l10n.sortDuration,
      'name' => l10n.sortName,
      _ => l10n.sortLatest,
    };

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
