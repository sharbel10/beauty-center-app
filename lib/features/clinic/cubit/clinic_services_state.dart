import 'package:beauty_center_app/features/clinic/models/clinic_service_filters.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_services_response.dart';
import 'package:equatable/equatable.dart';

enum ClinicServicesStatus { initial, loading, success, failure }

class ClinicServicesState extends Equatable {
  const ClinicServicesState({
    this.status = ClinicServicesStatus.initial,
    this.services = const <ClinicServiceItem>[],
    this.filters = const ClinicServiceFilters(),
    this.message,
  });

  final ClinicServicesStatus status;
  final List<ClinicServiceItem> services;
  final ClinicServiceFilters filters;
  final String? message;

  bool get isLoading => status == ClinicServicesStatus.loading;

  ClinicServicesState copyWith({
    ClinicServicesStatus? status,
    List<ClinicServiceItem>? services,
    ClinicServiceFilters? filters,
    String? message,
    bool clearServices = false,
    bool clearMessage = false,
  }) => ClinicServicesState(
    status: status ?? this.status,
    services: clearServices
        ? const <ClinicServiceItem>[]
        : services ?? this.services,
    filters: filters ?? this.filters,
    message: clearMessage ? null : message ?? this.message,
  );

  @override
  List<Object?> get props => <Object?>[status, services, filters, message];
}
