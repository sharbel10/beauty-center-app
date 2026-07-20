import 'package:beauty_center_app/features/clinic/cubit/clinic_employees_state.dart';
import 'package:beauty_center_app/features/clinic/repository/clinic_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ClinicEmployeesCubit extends Cubit<ClinicEmployeesState> {
  final ClinicsRepository _repository;

  ClinicEmployeesCubit(this._repository) : super(ClinicEmployeesInitial());

  Future<void> fetchClinicEmployees(int centerId, {int? serviceId}) async {
    emit(ClinicEmployeesLoading());

    final result = await _repository.getClinicEmployees(
      centerId: centerId,
      serviceId: serviceId,
    );
    if (isClosed) return;
    result.fold(
      (failure) {
        emit(ClinicEmployeesFailure(failure.message));
      },
      (response) {
        emit(ClinicEmployeesSuccess(response.employees));
      },
    );
  }
}
