import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:equatable/equatable.dart';

enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  rejected,
  unknown,
}

class AppointmentModel extends Equatable {
  const AppointmentModel({
    required this.id,
    required this.clinicName,
    required this.serviceName,
    required this.date,
    required this.time,
    required this.status,
    required this.statusLabel,
    required this.imageUrl,
    required this.startsAt,
    required this.endsAt,
    required this.total,
    required this.depositRequired,
    this.centerId,
    this.serviceId,
    this.employeeId,
    this.employeeName,
    this.customerNotes,
    this.cancellationReason,
  });

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> center =
        json['center'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> items = json['items'] as List<dynamic>? ?? <dynamic>[];
    final Map<String, dynamic> firstItem = items.isNotEmpty
        ? items.first as Map<String, dynamic>
        : <String, dynamic>{};
    final Map<String, dynamic> employee =
        firstItem['employee'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final DateTime? startsAt = DateTime.tryParse(
      json['starts_at'] as String? ?? '',
    )?.toLocal();
    final DateTime? endsAt = DateTime.tryParse(
      json['ends_at'] as String? ?? '',
    )?.toLocal();
    final AppointmentStatus status = _statusFromString(
      json['status'] as String?,
    );

    return AppointmentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      clinicName: center['name'] as String? ?? 'Clinic',
      serviceName: firstItem['service_name'] as String? ?? 'Service',
      date: startsAt == null ? '' : _formatDate(startsAt),
      time: startsAt == null ? '' : _formatTime(startsAt),
      status: status,
      statusLabel: _statusLabel(status, json['status'] as String?),
      imageUrl: ApiEndpoints.mediaUrl(center['cover_path'] as String? ?? ''),
      startsAt: startsAt,
      endsAt: endsAt,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      depositRequired: (json['deposit_required'] as num?)?.toDouble() ?? 0,
      centerId: (center['id'] as num?)?.toInt(),
      serviceId: (firstItem['service_id'] as num?)?.toInt(),
      employeeId: (firstItem['employee_id'] as num?)?.toInt(),
      employeeName: employee['name'] as String?,
      customerNotes: json['customer_notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
    );
  }

  final int id;
  final String clinicName;
  final String serviceName;
  final String date;
  final String time;
  final AppointmentStatus status;
  final String statusLabel;
  final String imageUrl;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final double total;
  final double depositRequired;
  final int? centerId;
  final int? serviceId;
  final int? employeeId;
  final String? employeeName;
  final String? customerNotes;
  final String? cancellationReason;

  bool get isPast => status == AppointmentStatus.completed || startsAtIsPast;

  bool get startsAtIsPast {
    final DateTime? date = startsAt;
    return date != null && date.isBefore(DateTime.now());
  }

  bool get canCancel =>
      status == AppointmentStatus.pending ||
      status == AppointmentStatus.confirmed;

  bool get canReschedule => canCancel && centerId != null && serviceId != null;

  String get totalLabel => '${_formatPrice(total)} SP';

  @override
  List<Object?> get props => <Object?>[
    id,
    clinicName,
    serviceName,
    date,
    time,
    status,
    statusLabel,
    imageUrl,
    startsAt,
    endsAt,
    total,
    depositRequired,
    centerId,
    serviceId,
    employeeId,
    employeeName,
    customerNotes,
    cancellationReason,
  ];
}

AppointmentStatus _statusFromString(String? status) {
  return switch (status) {
    'pending' => AppointmentStatus.pending,
    'confirmed' => AppointmentStatus.confirmed,
    'completed' => AppointmentStatus.completed,
    'cancelled' => AppointmentStatus.cancelled,
    'rejected' => AppointmentStatus.rejected,
    _ => AppointmentStatus.unknown,
  };
}

String _statusLabel(AppointmentStatus status, String? rawStatus) {
  return switch (status) {
    AppointmentStatus.pending => 'Pending',
    AppointmentStatus.confirmed => 'Confirmed',
    AppointmentStatus.completed => 'Completed',
    AppointmentStatus.cancelled => 'Cancelled',
    AppointmentStatus.rejected => 'Rejected',
    AppointmentStatus.unknown => rawStatus ?? 'Unknown',
  };
}

String _formatDate(DateTime date) {
  const List<String> weekdays = <String>[
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
}

String _formatTime(DateTime date) {
  final int hour = date.hour == 0
      ? 12
      : date.hour > 12
      ? date.hour - 12
      : date.hour;
  final String minute = date.minute.toString().padLeft(2, '0');
  final String period = date.hour >= 12 ? 'PM' : 'AM';
  return '$hour:$minute $period';
}

String _formatPrice(double price) {
  final String value = price.toStringAsFixed(0);
  final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  return value.replaceAllMapped(reg, (Match match) => '${match[1]},');
}
