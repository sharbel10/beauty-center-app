import 'package:beauty_center_app/features/clinic/models/clinics_employees_response.dart';
import 'package:equatable/equatable.dart';

abstract class ClinicEmployeesState extends Equatable {
  const ClinicEmployeesState();

  @override
  List<Object?> get props => [];
}

class ClinicEmployeesInitial extends ClinicEmployeesState {}

class ClinicEmployeesLoading extends ClinicEmployeesState {}

class ClinicEmployeesSuccess extends ClinicEmployeesState {
  final List<ClinicEmployeeItem> employees;

  const ClinicEmployeesSuccess(this.employees);

  @override
  List<Object?> get props => [employees];
}

class ClinicEmployeesFailure extends ClinicEmployeesState {
  final String errorMessage;

  const ClinicEmployeesFailure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
