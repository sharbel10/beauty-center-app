import 'package:equatable/equatable.dart';

class AvailableSlotsResponse extends Equatable {
  const AvailableSlotsResponse({required this.success, required this.slots});

  factory AvailableSlotsResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> slotsList =
        data['slots'] as List<dynamic>? ?? <dynamic>[];

    return AvailableSlotsResponse(
      success: json['success'] as bool? ?? true,
      slots: slotsList
          .map(
            (dynamic item) =>
                AvailableSlot.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final bool success;
  final List<AvailableSlot> slots;

  @override
  List<Object?> get props => <Object?>[success, slots];
}

class AvailableSlot extends Equatable {
  const AvailableSlot({
    required this.startsAt,
    required this.endsAt,
    required this.availableEmployeeIds,
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) {
    return AvailableSlot(
      startsAt: json['starts_at'] as String? ?? '',
      endsAt: json['ends_at'] as String? ?? '',
      availableEmployeeIds:
          (json['available_employee_ids'] as List<dynamic>? ?? <dynamic>[])
              .map((dynamic item) => (item as num).toInt())
              .toList(),
    );
  }

  final String startsAt;
  final String endsAt;
  final List<int> availableEmployeeIds;

  DateTime? get startsAtDate => DateTime.tryParse(startsAt)?.toLocal();
  DateTime? get endsAtDate => DateTime.tryParse(endsAt)?.toLocal();

  String get timeLabel {
    final DateTime? date = startsAtDate;
    if (date == null) {
      return '';
    }
    return _formatTime(date);
  }

  bool get isMorning {
    final DateTime? date = startsAtDate;
    return date == null || date.hour < 12;
  }

  @override
  List<Object?> get props => <Object?>[startsAt, endsAt, availableEmployeeIds];
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
