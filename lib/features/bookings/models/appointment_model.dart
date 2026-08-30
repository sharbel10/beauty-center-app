import 'package:equatable/equatable.dart';

enum AppointmentStatus {
  pendingPayment,
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
    required this.depositPaid,
    required this.depositDue,
    required this.paymentStatus,
    this.paymentExpiresAt,
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
      imageUrl: center['cover_url']?.toString().trim() ?? '',
      startsAt: startsAt,
      endsAt: endsAt,
      total: (json['total'] as num?)?.toDouble() ?? 0,
      depositRequired: (json['deposit_required'] as num?)?.toDouble() ?? 0,
      depositPaid: (json['deposit_paid'] as num?)?.toDouble() ?? 0,
      depositDue: (json['deposit_due'] as num?)?.toDouble() ?? 0,
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      paymentExpiresAt: _parsePaymentExpiry(json),
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
  final double depositPaid;
  final double depositDue;
  final String paymentStatus;
  final DateTime? paymentExpiresAt;
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

  bool get isPaymentExpired {
    final DateTime? expiresAt = paymentExpiresAt;
    return expiresAt != null && !expiresAt.isAfter(DateTime.now());
  }

  bool get canRetryPayment =>
      status == AppointmentStatus.pendingPayment && !isPaymentExpired;

  bool get canReschedule =>
      canCancel && !startsAtIsPast && centerId != null && serviceId != null;

  String get totalLabel => '\$${_formatPrice(total)}';

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
    depositPaid,
    depositDue,
    paymentStatus,
    paymentExpiresAt,
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
    'pending_payment' => AppointmentStatus.pendingPayment,
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
    AppointmentStatus.pendingPayment => 'Pending payment',
    AppointmentStatus.pending => 'Pending',
    AppointmentStatus.confirmed => 'Confirmed',
    AppointmentStatus.completed => 'Completed',
    AppointmentStatus.cancelled => 'Cancelled',
    AppointmentStatus.rejected => 'Rejected',
    AppointmentStatus.unknown => rawStatus ?? 'Unknown',
  };
}

DateTime? _parsePaymentExpiry(Map<String, dynamic> json) {
  final dynamic raw =
      json['payment_expires_at'] ??
      json['pending_payment_expires_at'] ??
      json['payment_due_at'] ??
      json['payment_deadline_at'] ??
      json['payment_deadline'] ??
      json['hold_expires_at'] ??
      json['expires_at'];
  return DateTime.tryParse(raw?.toString() ?? '')?.toLocal();
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
