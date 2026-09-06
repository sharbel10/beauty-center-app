import 'package:beauty_center_app/features/notifications/models/notification_payload.dart';
import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.payload,
    required this.isRead,
    this.sentAt,
    this.readAt,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: _toInt(json['id']) ?? 0,
      type: json['type']?.toString() ?? 'general',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      payload: NotificationPayload.fromJson(
        json['data'] as Map<String, dynamic>?,
      ),
      isRead: json['is_read'] as bool? ?? false,
      sentAt: _toDate(json['sent_at']),
      readAt: _toDate(json['read_at']),
      createdAt: _toDate(json['created_at']),
    );
  }

  final int id;
  final String type;
  final String title;
  final String body;
  final NotificationPayload payload;
  final bool isRead;
  final DateTime? sentAt;
  final DateTime? readAt;
  final DateTime? createdAt;

  DateTime? get displayAt => sentAt ?? createdAt;

  bool get isAppointment => type == 'appointment' || type == 'booking';

  AppNotification copyWith({bool? isRead, DateTime? readAt}) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      body: body,
      payload: payload,
      isRead: isRead ?? this.isRead,
      sentAt: sentAt,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt,
    );
  }

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

  static DateTime? _toDate(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    type,
    title,
    body,
    payload,
    isRead,
    sentAt,
    readAt,
    createdAt,
  ];
}
