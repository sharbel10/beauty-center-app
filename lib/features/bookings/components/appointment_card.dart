import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/features/bookings/models/appointment_model.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_network_image.dart';
import 'package:flutter/material.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({
    required this.appointment,
    this.isPast = false,
    this.onViewDetails,
    this.onMorePressed,
    this.onRebookPressed,
    super.key,
  });

  final AppointmentModel appointment;
  final bool isPast;
  final VoidCallback? onViewDetails;
  final VoidCallback? onMorePressed;
  final VoidCallback? onRebookPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPast ? AppColors.background : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: isPast
          ? _PastContent(
              appointment: appointment,
              onRebookPressed: onRebookPressed,
            )
          : _UpcomingContent(
              appointment: appointment,
              onViewDetails: onViewDetails,
              onMorePressed: onMorePressed,
            ),
    );
  }
}

class _UpcomingContent extends StatelessWidget {
  const _UpcomingContent({
    required this.appointment,
    this.onViewDetails,
    this.onMorePressed,
  });

  final AppointmentModel appointment;
  final VoidCallback? onViewDetails;
  final VoidCallback? onMorePressed;

  @override
  Widget build(BuildContext context) {
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
                  _StatusBadge(
                    label: appointment.statusLabel,
                    isConfirmed:
                        appointment.status == AppointmentStatus.confirmed ||
                        appointment.status == AppointmentStatus.pending,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    appointment.clinicName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 15,
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
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 64,
                height: 64,
                child: ClinicNetworkImage(imageUrl: appointment.imageUrl),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(height: 1, color: AppColors.divider),
        const SizedBox(height: 12),
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
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Expanded(
              child: SizedBox(
                height: 42,
                child: ElevatedButton(
                  onPressed: onViewDetails,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'View Details',
                    style: AppTextStyles.button.copyWith(fontSize: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 42,
              height: 42,
              child: IconButton(
                onPressed: onMorePressed,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceMuted,
                  foregroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.more_horiz_rounded, size: 20),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _PastContent extends StatelessWidget {
  const _PastContent({required this.appointment, this.onRebookPressed});

  final AppointmentModel appointment;
  final VoidCallback? onRebookPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _StatusBadge(label: appointment.statusLabel),
        const SizedBox(height: 10),
        Text(
          appointment.clinicName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          appointment.serviceName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 12),
        _MetaItem(
          icon: Icons.calendar_month_rounded,
          text: appointment.date,
          muted: true,
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: OutlinedButton.icon(
            onPressed: onRebookPressed,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(
              'Rebook Service',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.inputBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, this.isConfirmed = false});

  final String label;
  final bool isConfirmed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isConfirmed ? const Color(0xFFC8F6DE) : AppColors.inputBorder,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (isConfirmed) ...<Widget>[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFF18C786),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isConfirmed
                  ? const Color(0xFF05694A)
                  : AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
          ),
        ),
      ],
    );
  }
}
