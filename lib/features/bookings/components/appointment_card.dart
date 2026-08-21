import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/features/bookings/models/appointment_model.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_network_image.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    required this.appointment,
    this.isPast = false,
    this.onViewDetails,
    this.onMorePressed,
    this.onRebookPressed,
    this.onPayPressed,
    super.key,
  });

  final AppointmentModel appointment;
  final bool isPast;
  final VoidCallback? onViewDetails;
  final VoidCallback? onMorePressed;
  final VoidCallback? onRebookPressed;
  final VoidCallback? onPayPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPast
              ? AppColors.divider.withValues(alpha: 0.9)
              : AppColors.divider,
        ),
        boxShadow: isPast
            ? null
            : const <BoxShadow>[
                BoxShadow(
                  color: Color(0x080A2A55),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
      ),
      child: isPast
          ? _PastContent(
              appointment: appointment,
              onViewDetails: onViewDetails,
              onRebookPressed: onRebookPressed,
            )
          : _UpcomingContent(
              appointment: appointment,
              onViewDetails: onViewDetails,
              onMorePressed: onMorePressed,
              onPayPressed: onPayPressed,
            ),
    );
  }
}

class _UpcomingContent extends StatelessWidget {
  const _UpcomingContent({
    required this.appointment,
    this.onViewDetails,
    this.onMorePressed,
    this.onPayPressed,
  });

  final AppointmentModel appointment;
  final VoidCallback? onViewDetails;
  final VoidCallback? onMorePressed;
  final VoidCallback? onPayPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AppointmentStatusBadge(status: appointment.status),
                  const SizedBox(height: 12),
                  Text(
                    appointment.clinicName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.serviceName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: ClinicNetworkImage(imageUrl: appointment.imageUrl),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Divider(height: 1, color: AppColors.divider),
        const SizedBox(height: 14),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: <Widget>[
            _MetaItem(
              icon: Icons.calendar_month_rounded,
              text: appointment.date,
            ),
            _MetaItem(icon: Icons.schedule_rounded, text: appointment.time),
          ],
        ),
        if (appointment.status == AppointmentStatus.pendingPayment) ...<Widget>[
          const SizedBox(height: 12),
          _PendingPaymentNotice(appointment: appointment),
        ],
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: appointment.canRetryPayment
                      ? onPayPressed
                      : onViewDetails,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    appointment.canRetryPayment
                        ? l10n.completePayment
                        : l10n.viewDetails,
                    style: AppTextStyles.button.copyWith(fontSize: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 44,
              height: 44,
              child: IconButton(
                onPressed:
                    appointment.status == AppointmentStatus.pendingPayment
                    ? onViewDetails
                    : onMorePressed,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceMuted,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  appointment.status == AppointmentStatus.pendingPayment
                      ? Icons.info_outline_rounded
                      : Icons.more_horiz_rounded,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PastContent extends StatelessWidget {
  const _PastContent({
    required this.appointment,
    this.onViewDetails,
    this.onRebookPressed,
  });

  final AppointmentModel appointment;
  final VoidCallback? onViewDetails;
  final VoidCallback? onRebookPressed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AppointmentStatusBadge(status: appointment.status),
                  const SizedBox(height: 12),
                  Text(
                    appointment.clinicName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appointment.serviceName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    ClinicNetworkImage(imageUrl: appointment.imageUrl),
                    const ColoredBox(color: Color(0x33F7F9FB)),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            children: <Widget>[
              _MetaItem(
                icon: Icons.calendar_month_rounded,
                text: appointment.date,
                muted: true,
              ),
              _MetaItem(
                icon: Icons.schedule_rounded,
                text: appointment.time,
                muted: true,
              ),
              if (appointment.total > 0)
                _MetaItem(
                  icon: Icons.payments_outlined,
                  text: appointment.totalLabel,
                  muted: true,
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: 44,
                child: OutlinedButton(
                  onPressed: onViewDetails,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.inputBorder),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.viewDetails,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onRebookPressed,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    l10n.rebook,
                    style: AppTextStyles.button.copyWith(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class AppointmentStatusBadge extends StatelessWidget {
  const AppointmentStatusBadge({required this.status, super.key});

  final AppointmentStatus status;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final _StatusStyle style = _statusStyle(status, l10n);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: style.dot, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            style.label,
            style: AppTextStyles.bodySmall.copyWith(
              color: style.foreground,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _statusStyle(AppointmentStatus status, AppLocalizations l10n) {
    return switch (status) {
      AppointmentStatus.pending => const _StatusStyle(
        background: Color(0xFFFFF4D6),
        foreground: Color(0xFF8A5A00),
        dot: Color(0xFFE0A800),
        label: '',
      ).copyWith(label: l10n.statusPending),
      AppointmentStatus.pendingPayment => const _StatusStyle(
        background: Color(0xFFFFF4D6),
        foreground: Color(0xFF8A5A00),
        dot: Color(0xFFE0A800),
        label: '',
      ).copyWith(label: l10n.statusPendingPayment),
      AppointmentStatus.confirmed => const _StatusStyle(
        background: Color(0xFFC8F6DE),
        foreground: Color(0xFF05694A),
        dot: Color(0xFF18C786),
        label: '',
      ).copyWith(label: l10n.statusConfirmed),
      AppointmentStatus.completed => const _StatusStyle(
        background: Color(0xFFE8EDF3),
        foreground: Color(0xFF3A4A5F),
        dot: Color(0xFF7B8BA3),
        label: '',
      ).copyWith(label: l10n.statusCompleted),
      AppointmentStatus.cancelled => const _StatusStyle(
        background: Color(0xFFFDECEC),
        foreground: Color(0xFFB42318),
        dot: Color(0xFFD84040),
        label: '',
      ).copyWith(label: l10n.statusCancelled),
      AppointmentStatus.rejected => const _StatusStyle(
        background: Color(0xFFFFF0E6),
        foreground: Color(0xFFB54708),
        dot: Color(0xFFE65100),
        label: '',
      ).copyWith(label: l10n.statusRejected),
      AppointmentStatus.unknown => _StatusStyle(
        background: AppColors.inputBorder,
        foreground: AppColors.textSecondary,
        dot: AppColors.textMuted,
        label: l10n.statusPending,
      ),
    };
  }
}

class _PendingPaymentNotice extends StatelessWidget {
  const _PendingPaymentNotice({required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DateTime? expiresAt = appointment.paymentExpiresAt;
    final MaterialLocalizations material = MaterialLocalizations.of(context);
    final String message = expiresAt == null
        ? l10n.pendingPaymentNotice
        : l10n.pendingPaymentDeadline(
            '${material.formatMediumDate(expiresAt)} · '
            '${material.formatTimeOfDay(TimeOfDay.fromDateTime(expiresAt))}',
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD978)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.schedule_rounded,
            size: 18,
            color: Color(0xFF8A5A00),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF8A5A00),
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.background,
    required this.foreground,
    required this.dot,
    required this.label,
  });

  final Color background;
  final Color foreground;
  final Color dot;
  final String label;

  _StatusStyle copyWith({String? label}) {
    return _StatusStyle(
      background: background,
      foreground: foreground,
      dot: dot,
      label: label ?? this.label,
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text, this.muted = false});

  final IconData icon;
  final String text;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          icon,
          color: muted ? AppColors.textMuted : AppColors.primary,
          size: 16,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTextStyles.subtitle.copyWith(
            color: muted ? AppColors.textMuted : AppColors.textPrimary,
            fontSize: 13,
            fontWeight: muted ? FontWeight.w500 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
