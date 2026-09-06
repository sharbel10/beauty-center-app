import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/features/bookings/models/appointment_model.dart';
import 'package:beauty_center_app/features/reviews/cubit/report_cubit.dart';
import 'package:beauty_center_app/features/reviews/cubit/report_state.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReportSubmitSheet extends StatefulWidget {
  const ReportSubmitSheet({required this.appointment, super.key});

  final AppointmentModel appointment;

  @override
  State<ReportSubmitSheet> createState() => _ReportSubmitSheetState();
}

class _ReportSubmitSheetState extends State<ReportSubmitSheet> {
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedReason;
  String? _reasonError;

  static List<String> _getReportReasons(AppLocalizations l10n) {
    return <String>[
      l10n.reportReasonWrongSchedule,
      l10n.reportReasonPoorService,
      l10n.reportReasonUnhygienic,
      l10n.reportReasonRudeStaff,
      l10n.reportReasonOvercharging,
      l10n.reportReasonNoShow,
      l10n.reportReasonOther,
    ];
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double bottomInset = mediaQuery.viewInsets.bottom > 0
        ? mediaQuery.viewInsets.bottom
        : mediaQuery.viewPadding.bottom;
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ReportCubit cubit = context.read<ReportCubit>();

    return BlocConsumer<ReportCubit, ReportState>(
      bloc: cubit,
      listenWhen: (ReportState previous, ReportState current) =>
          previous.status != current.status &&
          (current.status == SubmitReportStatus.success ||
              current.status == SubmitReportStatus.failure),
      listener: (BuildContext context, ReportState state) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        if (state.status == SubmitReportStatus.success) {
          context.showSnackbar(state.message ?? l10n.reportSubmitted);
          Navigator.of(context).pop(true);
        } else if (state.status == SubmitReportStatus.failure) {
          context.showSnackbar(
            state.message ?? l10n.reportSubmitFailed,
            isError: true,
          );
        }
      },
      builder: (BuildContext context, ReportState state) {
        final bool isSubmitting = state.isAppointmentReporting(
          widget.appointment.id,
        );

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.88,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 18, 20, 16 + bottomInset),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.report_gmailerrorred_rounded,
                              size: 22,
                              color: AppColors.danger,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  l10n.reportIssue,
                                  style: AppTextStyles.title.copyWith(
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${l10n.clinicLabel}: ${widget.appointment.clinicName}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.subtitle.copyWith(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.reportReasonQuestion,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _getReportReasons(l10n)
                            .map(
                              (String reason) => _ReasonChip(
                                label: reason,
                                isSelected: _selectedReason == reason,
                                onTap: () {
                                  setState(() {
                                    _selectedReason = reason;
                                    _reasonError = null;
                                  });
                                },
                              ),
                            )
                            .toList(),
                      ),
                      if (_reasonError != null) ...<Widget>[
                        const SizedBox(height: 8),
                        Text(
                          _reasonError!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _DescriptionField(
                        controller: _descriptionController,
                        l10n: l10n,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: (_selectedReason != null && !isSubmitting)
                              ? () => _submitReport(cubit)
                              : null,
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Icon(Icons.flag_rounded, size: 18),
                          label: Text(
                            isSubmitting ? l10n.submitting : l10n.submitReport,
                            style: AppTextStyles.button.copyWith(fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.danger,
                            foregroundColor: AppColors.surface,
                            disabledBackgroundColor: AppColors.tertiary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitReport(ReportCubit cubit) async {
    final int? centerId = widget.appointment.centerId;
    final String? reason = _selectedReason;
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (reason == null || reason.trim().isEmpty) {
      setState(() => _reasonError = l10n.selectReasonError);
      return;
    }
    if (centerId == null) {
      if (mounted) {
        context.showSnackbar(l10n.missingCenterDetails, isError: true);
      }
      return;
    }

    try {
      await cubit.submitReport(
        appointmentId: widget.appointment.id,
        reportedCenterId: centerId,
        reason: reason,
        description: _descriptionController.text,
      );
    } catch (_) {
      // Listener handles UX via snackbar; no double handling needed.
    }
  }
}

class _ReasonChip extends StatelessWidget {
  const _ReasonChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.danger.withValues(alpha: 0.10)
              : AppColors.scaffold,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected ? AppColors.danger : AppColors.divider,
            width: isSelected ? 1.3 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.danger : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _DescriptionField extends StatelessWidget {
  const _DescriptionField({required this.controller, required this.l10n});

  final TextEditingController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.reportAdditionalDetails,
          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: 5,
          maxLength: 500,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            counterText: '',
            hintText: l10n.reportProvideDetails,
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textLight,
            ),
            filled: true,
            fillColor: AppColors.white,
          ),
        ),
      ],
    );
  }
}
