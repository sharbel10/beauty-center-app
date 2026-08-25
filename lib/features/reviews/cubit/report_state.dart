import 'package:equatable/equatable.dart';

enum SubmitReportStatus { initial, loading, success, failure }

class ReportState extends Equatable {
  const ReportState({
    this.status = SubmitReportStatus.initial,
    this.message,
    this.isMessageError = false,
    this.reportingAppointmentId,
  });

  final SubmitReportStatus status;
  final String? message;
  final bool isMessageError;
  final int? reportingAppointmentId;

  bool get isLoading => status == SubmitReportStatus.loading;

  bool isAppointmentReporting(int appointmentId) =>
      reportingAppointmentId == appointmentId;

  ReportState copyWith({
    SubmitReportStatus? status,
    String? message,
    bool? isMessageError,
    bool clearMessage = false,
    int? reportingAppointmentId,
    bool clearReportingAppointment = false,
  }) {
    return ReportState(
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
      isMessageError:
          clearMessage ? false : (isMessageError ?? this.isMessageError),
      reportingAppointmentId: clearReportingAppointment
          ? null
          : (reportingAppointmentId ?? this.reportingAppointmentId),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    message,
    isMessageError,
    reportingAppointmentId,
  ];
}
