import 'package:beauty_center_app/features/clinic/models/clinics_services_response.dart';
import 'package:equatable/equatable.dart';

abstract class ClinicServicesState extends Equatable {
  const ClinicServicesState();

  @override
  List<Object?> get props => [];
}

class ClinicServicesInitial extends ClinicServicesState {}

class ClinicServicesLoading extends ClinicServicesState {}

class ClinicServicesSuccess extends ClinicServicesState {
  final List<ClinicServiceItem> services;

  const ClinicServicesSuccess(this.services);

  @override
  List<Object?> get props => [services];
}

class ClinicServicesFailure extends ClinicServicesState {
  final String errorMessage;

  const ClinicServicesFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
