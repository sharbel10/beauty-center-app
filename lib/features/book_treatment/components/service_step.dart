import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/features/book_treatment/components/booking_step_title.dart';
import 'package:beauty_center_app/features/book_treatment/utils/booking_formats.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_employees_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_services_response.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Step 1: choose a service (required) and optionally a specialist.
///
/// Built for real clinic menus (e.g. Laser with 10+ variants): services are
/// grouped into collapsible category sections showing a count, so long
/// lists stay scannable. Expansion state is local UI state and never
/// touches the cubit.
class ServiceStep extends StatefulWidget {
  const ServiceStep({
    required this.services,
    required this.selectedServiceId,
    required this.onServiceSelected,
    required this.employees,
    required this.selectedEmployeeId,
    required this.onEmployeeSelected,
    super.key,
  });

  final List<ClinicServiceItem> services;
  final int? selectedServiceId;
  final ValueChanged<int> onServiceSelected;
  final List<ClinicEmployeeItem> employees;
  final int? selectedEmployeeId;
  final ValueChanged<int?> onEmployeeSelected;

  @override
  State<ServiceStep> createState() => _ServiceStepState();
}

class _CategoryGroup {
  const _CategoryGroup({required this.name, required this.services});

  final String name;
  final List<ClinicServiceItem> services;
}

class _ServiceStepState extends State<ServiceStep> {
  final Set<int> _expandedCategoryIds = <int>{};

  @override
  void initState() {
    super.initState();
    // Start with the selected service's category open (or the first one)
    // so the user always lands on something actionable.
    _expandedCategoryIds.add(_initialExpandedCategoryId());
  }

  int _initialExpandedCategoryId() {
    for (final ClinicServiceItem service in widget.services) {
      if (service.id == widget.selectedServiceId) {
        return service.category.id;
      }
    }
    return widget.services.isEmpty
        ? 0
        : widget.services.first.category.id;
  }

  Map<int, _CategoryGroup> _groups(AppLocalizations l10n) {
    final Map<int, _CategoryGroup> groups = <int, _CategoryGroup>{};
    for (final ClinicServiceItem service in widget.services) {
      final String name = service.category.name.isEmpty
          ? l10n.otherCategory
          : service.category.name;
      groups
          .putIfAbsent(
            service.category.id,
            () => _CategoryGroup(name: name, services: <ClinicServiceItem>[]),
          )
          .services
          .add(service);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final Map<int, _CategoryGroup> groups = _groups(l10n);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: <Widget>[
        BookingStepTitle(
          title: l10n.selectService,
          subtitle: l10n.selectServiceSubtitle,
        ),
        const SizedBox(height: 14),
        for (final MapEntry<int, _CategoryGroup> entry in groups.entries) ...<Widget>[
          _CategorySection(
            group: entry.value,
            isExpanded: _expandedCategoryIds.contains(entry.key),
            selectedServiceId: widget.selectedServiceId,
            onToggle: () {
              setState(() {
                if (!_expandedCategoryIds.remove(entry.key)) {
                  _expandedCategoryIds.add(entry.key);
                }
              });
            },
            onServiceSelected: widget.onServiceSelected,
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 14),
        BookingStepTitle(
          title: l10n.chooseSpecialist,
          subtitle: l10n.chooseSpecialistSubtitle,
        ),
        const SizedBox(height: 16),
        _SpecialistRow(
          employees: widget.employees,
          selectedEmployeeId: widget.selectedEmployeeId,
          onChanged: widget.onEmployeeSelected,
        ),
      ],
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection({
    required this.group,
    required this.isExpanded,
    required this.selectedServiceId,
    required this.onToggle,
    required this.onServiceSelected,
  });

  final _CategoryGroup group;
  final bool isExpanded;
  final int? selectedServiceId;
  final VoidCallback onToggle;
  final ValueChanged<int> onServiceSelected;

  bool get _containsSelection => group.services
      .any((ClinicServiceItem service) => service.id == selectedServiceId);

  @override
  Widget build(BuildContext context) {
    final bool highlight = _containsSelection && !isExpanded;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _containsSelection ? AppColors.primary : AppColors.inputBorder,
          width: _containsSelection ? 1.4 : 1,
        ),
      ),
      child: Column(
        children: <Widget>[
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      group.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (highlight) ...<Widget>[
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${group.services.length}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Column(
                    children: <Widget>[
                      const Divider(
                        height: 1,
                        color: AppColors.divider,
                      ),
                      for (final ClinicServiceItem service
                          in group.services)
                        _ServiceRow(
                          service: service,
                          isSelected: service.id == selectedServiceId,
                          onTap: () => onServiceSelected(service.id),
                        ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  const _ServiceRow({
    required this.service,
    required this.isSelected,
    required this.onTap,
  });

  final ClinicServiceItem service;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.06)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    service.name.isEmpty
                        ? service.category.name
                        : service.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${l10n.clinicDurationMinutes(service.durationMinutes)} • '
                    '${BookingFormats.price(service.finalPrice)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.textFaint,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: AppColors.surface,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecialistRow extends StatelessWidget {
  const _SpecialistRow({
    required this.employees,
    required this.selectedEmployeeId,
    required this.onChanged,
  });

  final List<ClinicEmployeeItem> employees;
  final int? selectedEmployeeId;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 92,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          _SpecialistOption(
            label: l10n.anySpecialist,
            isSelected: selectedEmployeeId == null,
            onTap: () => onChanged(null),
            child: const Icon(
              Icons.groups_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          for (final ClinicEmployeeItem employee in employees)
            _SpecialistOption(
              label: employee.name,
              isSelected: selectedEmployeeId == employee.id,
              onTap: () => onChanged(employee.id),
              child: ClipOval(
                child: Image.network(
                  ApiEndpoints.mediaUrl(employee.avatarPath),
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) => const Icon(
                        Icons.person_rounded,
                        color: AppColors.textMuted,
                      ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SpecialistOption extends StatelessWidget {
  const _SpecialistOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
              child: child,
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 64,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
