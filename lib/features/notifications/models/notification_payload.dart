import 'package:equatable/equatable.dart';

class NotificationPayload extends Equatable {
  const NotificationPayload({
    this.appointmentId,
    this.centerId,
    this.status,
    this.event,
    this.raw = const <String, dynamic>{},
  });

  factory NotificationPayload.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) {
      return const NotificationPayload();
    }

    return NotificationPayload(
      appointmentId: _toInt(json['appointment_id']),
      centerId: _toInt(json['center_id']),
      status: json['status']?.toString(),
      event: json['event']?.toString(),
      raw: Map<String, dynamic>.from(json),
    );
  }

  factory NotificationPayload.fromFcmData(Map<String, dynamic> data) {
    final dynamic nested = data['data'];
    if (nested is Map<String, dynamic>) {
      return NotificationPayload.fromJson(nested);
    }
    return NotificationPayload.fromJson(data);
  }

  final int? appointmentId;
  final int? centerId;
  final String? status;
  final String? event;
  final Map<String, dynamic> raw;

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
  List<Object?> get props => <Object?>[appointmentId, centerId, status, event];
}
