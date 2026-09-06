import 'package:beauty_center_app/features/clinic/models/clinics_details_response.dart';
import 'package:equatable/equatable.dart';

enum ClinicDetailsStatus { initial, loading, success, failure }

class ClinicDetailsState extends Equatable {
  const ClinicDetailsState({
    this.status = ClinicDetailsStatus.initial,
    this.center,
    this.message,
  });

  final ClinicDetailsStatus status;
  final ClinicCenterDetail? center;
  final String? message;

  bool get isLoading => status == ClinicDetailsStatus.loading;
  bool get isSuccess => status == ClinicDetailsStatus.success;
  bool get hasData => center != null;

  ClinicDetailsState copyWith({
    ClinicDetailsStatus? status,
    ClinicCenterDetail? center,
    String? message,
    bool clearMessage = false,
  }) {
    return ClinicDetailsState(
      status: status ?? this.status,
      center: center ?? this.center,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, center, message];
}
