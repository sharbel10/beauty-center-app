import 'package:beauty_center_app/features/explore/models/pagination_meta.dart';
import 'package:beauty_center_app/features/notifications/models/app_notification.dart';
import 'package:equatable/equatable.dart';

class NotificationsListResponse extends Equatable {
  const NotificationsListResponse({
    required this.success,
    required this.notifications,
    required this.unreadCount,
    required this.meta,
  });

  factory NotificationsListResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? data = json['data'] as Map<String, dynamic>?;

    return NotificationsListResponse(
      success: json['success'] as bool? ?? true,
      notifications: (data?['notifications'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList(),
      unreadCount: _toInt(data?['unread_count']) ?? 0,
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>?),
    );
  }

  final bool success;
  final List<AppNotification> notifications;
  final int unreadCount;
  final PaginationMeta meta;

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
  List<Object?> get props => <Object?>[success, notifications, unreadCount, meta];
}
