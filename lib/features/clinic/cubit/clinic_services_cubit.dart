import 'package:beauty_center_app/features/clinic/cubit/clinic_services_state.dart';
import 'package:beauty_center_app/features/clinic/repository/clinic_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ClinicServicesCubit extends Cubit<ClinicServicesState> {
  final ClinicsRepository _repository;

  ClinicServicesCubit(this._repository) : super(ClinicServicesInitial());

  Future<void> fetchClinicServices(int centerId) async {
    emit(ClinicServicesLoading());

    final result = await _repository.getClinicServices(centerId: centerId);
    if (isClosed) return;
    result.fold(
      (failure) {
        emit(ClinicServicesFailure(failure.message));
      },
      (response) {
        emit(ClinicServicesSuccess(response.services));
      },
    );
  }
}
