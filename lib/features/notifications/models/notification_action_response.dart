import 'package:beauty_center_app/features/notifications/models/app_notification.dart';
import 'package:equatable/equatable.dart';

class NotificationActionResponse extends Equatable {
  const NotificationActionResponse({
    required this.success,
    required this.message,
    required this.unreadCount,
    this.notification,
    this.markedCount,
  });

  factory NotificationActionResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? data = json['data'] as Map<String, dynamic>?;
    final Map<String, dynamic>? notificationJson =
        data?['notification'] as Map<String, dynamic>?;

    return NotificationActionResponse(
      success: json['success'] as bool? ?? true,
      message: json['message']?.toString() ?? '',
      unreadCount: _toInt(data?['unread_count']) ?? 0,
      notification: notificationJson == null
          ? null
          : AppNotification.fromJson(notificationJson),
      markedCount: _toInt(data?['marked_count']),
    );
  }

  final bool success;
  final String message;
  final int unreadCount;
  final AppNotification? notification;
  final int? markedCount;

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  @override
  List<Object?> get props => <Object?>[
    success,
    message,
    unreadCount,
    notification,
    markedCount,
  ];
}
