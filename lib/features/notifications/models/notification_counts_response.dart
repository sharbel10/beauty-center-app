import 'package:equatable/equatable.dart';

class NotificationCountsResponse extends Equatable {
  const NotificationCountsResponse({
    required this.success,
    required this.unreadCount,
    required this.totalCount,
  });

  factory NotificationCountsResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? data = json['data'] as Map<String, dynamic>?;

    return NotificationCountsResponse(
      success: json['success'] as bool? ?? true,
      unreadCount: _toInt(data?['unread_count']) ?? 0,
      totalCount: _toInt(data?['total_count']) ?? 0,
    );
  }

  final bool success;
  final int unreadCount;
  final int totalCount;

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
  List<Object?> get props => <Object?>[success, unreadCount, totalCount];
}
