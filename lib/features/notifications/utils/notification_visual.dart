import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/features/notifications/models/app_notification.dart';
import 'package:flutter/material.dart';

class NotificationVisual {
  const NotificationVisual({
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;
}

NotificationVisual resolveNotificationVisual(
  AppNotification notification, {
  required bool isRead,
}) {
  final IconData icon = notification.isAppointment
      ? _resolveAppointmentIcon(
          event: notification.payload.event,
          status: notification.payload.status,
        )
      : _resolveGenericIcon(notification.type);

  return NotificationVisual(
    icon: icon,
    backgroundColor: Color.alphaBlend(
      AppColors.primary.withValues(alpha: isRead ? 0.035 : 0.07),
      AppColors.surface,
    ),
    iconColor: AppColors.primary.withValues(alpha: isRead ? 0.68 : 0.92),
  );
}

IconData _resolveGenericIcon(String type) {
  return switch (_normalize(type)) {
    'offer' || 'promotion' => Icons.local_offer_rounded,
    'center' || 'explore' => Icons.storefront_rounded,
    'payment' => Icons.payments_rounded,
    'reminder' => Icons.alarm_rounded,
    _ => Icons.notifications_rounded,
  };
}

IconData _resolveAppointmentIcon({
  required String? event,
  required String? status,
}) {
  final String normalizedEvent = _normalize(event);
  final String normalizedStatus = _normalize(status);

  if (normalizedEvent.contains('cancelled') ||
      normalizedStatus == 'cancelled') {
    return Icons.event_busy_rounded;
  }

  if (normalizedEvent.contains('rejected') || normalizedStatus == 'rejected') {
    return Icons.block_rounded;
  }

  if (normalizedEvent.contains('completed') ||
      normalizedStatus == 'completed') {
    return Icons.task_alt_rounded;
  }

  if (normalizedEvent.contains('confirmed') ||
      normalizedStatus == 'confirmed') {
    return Icons.check_circle_rounded;
  }

  if (normalizedEvent.contains('rescheduled') ||
      normalizedEvent.contains('reschedule')) {
    return Icons.event_repeat_rounded;
  }

  if (normalizedEvent.contains('pending') || normalizedStatus == 'pending') {
    return Icons.hourglass_top_rounded;
  }

  if (normalizedEvent.contains('created') ||
      normalizedEvent.contains('booked') ||
      normalizedEvent.contains('new')) {
    return Icons.event_available_rounded;
  }

  return Icons.calendar_month_rounded;
}

String _normalize(String? value) =>
    value?.trim().toLowerCase().replaceAll('-', '_') ?? '';
