import 'package:equatable/equatable.dart';

import 'appointment_model.dart';

class AppointmentsResponse extends Equatable {
  const AppointmentsResponse({
    required this.success,
    required this.appointments,
  });

  factory AppointmentsResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> appointmentsList =
        data['appointments'] as List<dynamic>? ?? <dynamic>[];

    return AppointmentsResponse(
      success: json['success'] as bool? ?? true,
      appointments: appointmentsList
          .map(
            (dynamic item) =>
                AppointmentModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final bool success;
  final List<AppointmentModel> appointments;

  @override
  List<Object?> get props => <Object?>[success, appointments];
}

class AppointmentResponse extends Equatable {
  const AppointmentResponse({
    required this.success,
    required this.message,
    required this.appointment,
  });

  factory AppointmentResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return AppointmentResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      appointment: AppointmentModel.fromJson(
        data['appointment'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }

  final bool success;
  final String message;
  final AppointmentModel appointment;

  @override
  List<Object?> get props => <Object?>[success, message, appointment];
}
