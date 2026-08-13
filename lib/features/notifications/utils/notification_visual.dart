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
  if (notification.isAppointment) {
    return _appointmentVisual(
      event: notification.payload.event,
      status: notification.payload.status,
      isRead: isRead,
    );
  }

  return _genericVisual(notification.type, isRead);
}

NotificationVisual _appointmentVisual({
  required String? event,
  required String? status,
  required bool isRead,
}) {
  final _AppointmentStatusStyle style = _resolveAppointmentStyle(
    event: event,
    status: status,
  );

  if (isRead) {
    return NotificationVisual(
      icon: style.icon,
      backgroundColor: AppColors.surfaceMuted,
      iconColor: style.foreground.withValues(alpha: 0.72),
    );
  }

  return NotificationVisual(
    icon: style.icon,
    backgroundColor: style.background,
    iconColor: style.foreground,
  );
}

NotificationVisual _genericVisual(String type, bool isRead) {
  final IconData icon = switch (type) {
    'offer' || 'promotion' => Icons.local_offer_rounded,
    'center' || 'explore' => Icons.storefront_rounded,
    _ => Icons.notifications_rounded,
  };

  if (isRead) {
    return NotificationVisual(
      icon: icon,
      backgroundColor: AppColors.surfaceMuted,
      iconColor: AppColors.primary.withValues(alpha: 0.72),
    );
  }

  return NotificationVisual(
    icon: icon,
    backgroundColor: AppColors.primary,
    iconColor: AppColors.surface,
  );
}

class _AppointmentStatusStyle {
  const _AppointmentStatusStyle({
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
}

_AppointmentStatusStyle _resolveAppointmentStyle({
  required String? event,
  required String? status,
}) {
  final String normalizedEvent = _normalize(event);
  final String normalizedStatus = _normalize(status);

  if (normalizedEvent.contains('cancelled') ||
      normalizedStatus == 'cancelled') {
    return const _AppointmentStatusStyle(
      icon: Icons.event_busy_rounded,
      background: Color(0xFFFDECEC),
      foreground: Color(0xFFB42318),
    );
  }

  if (normalizedEvent.contains('rejected') || normalizedStatus == 'rejected') {
    return const _AppointmentStatusStyle(
      icon: Icons.block_rounded,
      background: Color(0xFFFFF0E6),
      foreground: Color(0xFFB54708),
    );
  }

  if (normalizedEvent.contains('completed') ||
      normalizedStatus == 'completed') {
    return const _AppointmentStatusStyle(
      icon: Icons.task_alt_rounded,
      background: Color(0xFFE8EDF3),
      foreground: Color(0xFF3A4A5F),
    );
  }

  if (normalizedEvent.contains('confirmed') ||
      normalizedStatus == 'confirmed') {
    return const _AppointmentStatusStyle(
      icon: Icons.check_circle_rounded,
      background: Color(0xFFC8F6DE),
      foreground: Color(0xFF05694A),
    );
  }

  if (normalizedEvent.contains('rescheduled') ||
      normalizedEvent.contains('reschedule')) {
    return const _AppointmentStatusStyle(
      icon: Icons.event_repeat_rounded,
      background: Color(0xFFEAF2FF),
      foreground: AppColors.primary,
    );
  }

  if (normalizedEvent.contains('pending') || normalizedStatus == 'pending') {
    return const _AppointmentStatusStyle(
      icon: Icons.hourglass_top_rounded,
      background: Color(0xFFFFF4D6),
      foreground: Color(0xFF8A5A00),
    );
  }

  if (normalizedEvent.contains('created') ||
      normalizedEvent.contains('booked') ||
      normalizedEvent.contains('new')) {
    return const _AppointmentStatusStyle(
      icon: Icons.event_available_rounded,
      background: Color(0xFFEAF2FF),
      foreground: AppColors.primary,
    );
  }

  return const _AppointmentStatusStyle(
    icon: Icons.calendar_month_rounded,
    background: Color(0xFFEAF2FF),
    foreground: AppColors.primary,
  );
}

String _normalize(String? value) =>
    value?.trim().toLowerCase().replaceAll('-', '_') ?? '';
