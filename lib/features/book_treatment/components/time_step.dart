import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/features/book_treatment/components/booking_step_title.dart';
import 'package:beauty_center_app/features/book_treatment/cubit/book_treatment_state.dart';
import 'package:beauty_center_app/features/book_treatment/models/available_slots_response.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Step 3: pick a time slot and review the booking summary.
class TimeStep extends StatelessWidget {
  const TimeStep({
    required this.slots,
    required this.slotsStatus,
    required this.slotsMessage,
    required this.selectedStartsAt,
    required this.dateLabel,
    required this.serviceName,
    required this.specialistName,
    required this.hasSpecificSpecialist,
    required this.totalLabel,
    required this.onSlotSelected,
    required this.onRetry,
    required this.onChangeDate,
    required this.onTryAnySpecialist,
    super.key,
  });

  final List<AvailableSlot> slots;
  final SlotsStatus slotsStatus;
  final String? slotsMessage;
  final String? selectedStartsAt;
  final String dateLabel;
  final String serviceName;
  final String specialistName;
  final bool hasSpecificSpecialist;
  final String totalLabel;
  final ValueChanged<String> onSlotSelected;
  final VoidCallback onRetry;
  final VoidCallback onChangeDate;
  final VoidCallback onTryAnySpecialist;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: <Widget>[
        BookingStepTitle(
          title: l10n.selectTime,
          subtitle: dateLabel,
          trailing: TextButton(
            onPressed: onChangeDate,
            child: Text(
              l10n.changeDate,
              style: AppTextStyles.link.copyWith(fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._buildSlotsArea(l10n),
        const SizedBox(height: 24),
        _SummaryCard(
          serviceName: serviceName,
          specialistName: specialistName,
          dateLabel: dateLabel,
          totalLabel: totalLabel,
        ),
      ],
    );
  }

  List<Widget> _buildSlotsArea(AppLocalizations l10n) {
    if (slotsStatus == SlotsStatus.loading) {
      return const <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }

    if (slotsStatus == SlotsStatus.failure) {
      return <Widget>[
        _EmptyState(
          icon: Icons.wifi_off_rounded,
          message: slotsMessage ?? l10n.couldNotLoadAvailableTimes,
          actionLabel: l10n.retry,
          onAction: onRetry,
        ),
      ];
    }

    if (slots.isEmpty) {
      // With a specific specialist selected, an empty day usually means
      // that person is off, not that the clinic is fully booked — offer
      // to widen the search instead of only changing the date.
      if (hasSpecificSpecialist) {
        return <Widget>[
          _EmptyState(
            icon: Icons.event_busy_rounded,
            message: l10n.specialistNoAvailability(specialistName),
            actionLabel: l10n.tryAnySpecialist,
            onAction: onTryAnySpecialist,
            secondaryActionLabel: l10n.pickAnotherDate,
            onSecondaryAction: onChangeDate,
          ),
        ];
      }
      return <Widget>[
        _EmptyState(
          icon: Icons.event_busy_rounded,
          message: l10n.noAvailableTimesOnDate,
          actionLabel: l10n.pickAnotherDate,
          onAction: onChangeDate,
        ),
      ];
    }

    final List<AvailableSlot> morning = slots
        .where((AvailableSlot slot) => slot.isMorning)
        .toList();
    final List<AvailableSlot> afternoon = slots
        .where((AvailableSlot slot) => !slot.isMorning)
        .toList();

    return <Widget>[
      if (morning.isNotEmpty) ...<Widget>[
        _PeriodLabel(l10n.morningPeriod),
        const SizedBox(height: 10),
        _SlotGrid(
          slots: morning,
          selectedStartsAt: selectedStartsAt,
          onSelected: onSlotSelected,
        ),
        if (afternoon.isNotEmpty) const SizedBox(height: 18),
      ],
      if (afternoon.isNotEmpty) ...<Widget>[
        _PeriodLabel(l10n.afternoonPeriod),
        const SizedBox(height: 10),
        _SlotGrid(
          slots: afternoon,
          selectedStartsAt: selectedStartsAt,
          onSelected: onSlotSelected,
        ),
      ],
    ];
  }
}

class _SlotGrid extends StatelessWidget {
  const _SlotGrid({
    required this.slots,
    required this.selectedStartsAt,
    required this.onSelected,
  });

  final List<AvailableSlot> slots;
  final String? selectedStartsAt;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: slots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 44,
      ),
      itemBuilder: (BuildContext context, int index) {
        final AvailableSlot slot = slots[index];
        final bool isSelected = slot.startsAt == selectedStartsAt;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onSelected(slot.startsAt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.inputBorder,
              ),
            ),
            child: Text(
              slot.timeLabel,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.surface : AppColors.textPrimary,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PeriodLabel extends StatelessWidget {
  const _PeriodLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.smallCaps.copyWith(fontSize: 12));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final IconData icon;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, size: 32, color: AppColors.textMuted),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle.copyWith(fontSize: 14),
          ),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(actionLabel),
          ),
          if (secondaryActionLabel != null) ...<Widget>[
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: onSecondaryAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.inputBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(secondaryActionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.serviceName,
    required this.specialistName,
    required this.dateLabel,
    required this.totalLabel,
  });

  final String serviceName;
  final String specialistName;
  final String dateLabel;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.bookingSummary,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _SummaryRow(label: l10n.serviceLabel, value: serviceName),
          _SummaryRow(label: l10n.specialistLabel, value: specialistName),
          _SummaryRow(label: l10n.dateLabel, value: dateLabel),
          const Divider(color: AppColors.divider, height: 20),
          _SummaryRow(
            label: l10n.estimatedTotal,
            value: totalLabel,
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.subtitle.copyWith(fontSize: 13),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
              color: bold ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
