import 'package:beauty_center_app/features/clinic/models/clinics_details_response.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

class ClinicInfoView extends StatelessWidget {
  const ClinicInfoView({required this.clinic, super.key});

  final ClinicCenterDetail clinic;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HoursCard(workingHours: clinic.workingHours),
        const SizedBox(height: 30),
        _ContactCard(clinic: clinic),
        const SizedBox(height: 30),
        _CancellationCard(policy: clinic.cancellationPolicy),
      ],
    );
  }
}

class _HoursCard extends StatelessWidget {
  const _HoursCard({required this.workingHours});

  final List<WorkingHour> workingHours;

  String _getDayName(AppLocalizations l10n, int dayOfWeek, bool isToday) {
    final String dayName = switch (dayOfWeek) {
      1 => l10n.dayMonday,
      2 => l10n.dayTuesday,
      3 => l10n.dayWednesday,
      4 => l10n.dayThursday,
      5 => l10n.dayFriday,
      6 => l10n.daySaturday,
      0 => l10n.daySunday,
      _ => l10n.dayUnknown,
    };
    return isToday ? '$dayName\n${l10n.dayTodayMarker}' : dayName;
  }

  String _formatTime(String time) {
    if (time.isEmpty) return '';
    final parts = time.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return time;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int currentWeekday = DateTime.now().weekday;

    final todayHours = workingHours.firstWhere(
      (h) => h.dayOfWeek == currentWeekday,
      orElse: () => const WorkingHour(
        dayOfWeek: 0,
        opensAt: '',
        closesAt: '',
        isClosed: true,
      ),
    );

    final String statusText = todayHours.isClosed
        ? l10n.clinicClosedToday
        : l10n.clinicOpenTodayUntil(_formatTime(todayHours.closesAt));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(30, 34, 30, 26),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.clinicHours,
                  style: AppTextStyles.title.copyWith(fontSize: 22),
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.schedule_rounded,
                  color: AppColors.surface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            statusText,
            style: AppTextStyles.subtitle.copyWith(
              color: const Color(0xFF74551C),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          if (workingHours.isNotEmpty)
            ...workingHours.map((hour) {
              final bool isToday = hour.dayOfWeek == currentWeekday;
              final String timeDisplay = hour.isClosed
                  ? l10n.clinicClosed
                  : '${_formatTime(hour.opensAt)} - ${_formatTime(hour.closesAt)}';

              return _HoursRow(
                day: _getDayName(l10n, hour.dayOfWeek, isToday),
                hours: timeDisplay,
                isToday: isToday,
                isClosed: hour.isClosed,
              );
            })
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                l10n.clinicNoWorkingHours,
                style: AppTextStyles.subtitle.copyWith(fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}

class _HoursRow extends StatelessWidget {
  const _HoursRow({
    required this.day,
    required this.hours,
    required this.isToday,
    required this.isClosed,
  });

  final String day;
  final String hours;
  final bool isToday;
  final bool isClosed;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFFE9EDF2) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              day,
              style: AppTextStyles.subtitle.copyWith(
                color: isClosed ? AppColors.danger : AppColors.primarySoft,
                fontSize: 14,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            hours,
            textAlign: TextAlign.right,
            style: AppTextStyles.subtitle.copyWith(
              color: isClosed ? AppColors.danger : AppColors.primary,
              fontSize: 14,
              fontWeight: isClosed || isToday
                  ? FontWeight.w800
                  : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.clinic});

  final ClinicCenterDetail clinic;

  Future<void> _makeCall() async {
    if (clinic.phone.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: clinic.phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String unavailable = l10n.notAvailable;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF4DB),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: Color(0xFF8D671E),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  l10n.clinicContact,
                  style: AppTextStyles.title.copyWith(fontSize: 19),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          _ContactRow(
            label: l10n.clinicPhone,
            value: clinic.phone.isNotEmpty ? clinic.phone : unavailable,
          ),
          const SizedBox(height: 14),
          _ContactRow(
            label: l10n.clinicEmail,
            value: clinic.email.isNotEmpty ? clinic.email : unavailable,
          ),
          const SizedBox(height: 14),
          _ContactRow(
            label: l10n.clinicWebsite,
            value: clinic.website.isNotEmpty ? clinic.website : unavailable,
          ),
          const SizedBox(height: 24),
          AppButton(
            text: l10n.clinicCallNow,
            onPressed: clinic.phone.isNotEmpty ? _makeCall : null,
            height: 54,
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: AppTextStyles.subtitle.copyWith(
              color: const Color(0xFF4C525C),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.primary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _CancellationCard extends StatelessWidget {
  const _CancellationCard({required this.policy});

  final CancellationPolicy policy;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final String policyTypeFormatted = policy.type.isNotEmpty
        ? policy.type.toUpperCase()
        : l10n.clinicPolicyStandard;

    final String mainContent = l10n.clinicCancellationIntro(policyTypeFormatted);

    final String dynamicSubContent;
    if (policy.feePercentage == 0 || policy.type.toLowerCase() == 'free') {
      dynamicSubContent = l10n.clinicCancellationFree(policy.deadlineHours);
    } else {
      dynamicSubContent = l10n.clinicCancellationFee(
        policy.deadlineHours,
        policy.feePercentage,
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.gavel_rounded, color: AppColors.gold),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  l10n.clinicCancellationPolicy,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.surface,
                    fontSize: 21,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.only(left: 62),
            child: Text(
              mainContent,
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.surface,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            margin: const EdgeInsets.only(left: 62),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0x1AFFFFFF),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0x22FFFFFF)),
            ),
            child: Text(
              dynamicSubContent,
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.textLight,
                fontSize: 10,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
