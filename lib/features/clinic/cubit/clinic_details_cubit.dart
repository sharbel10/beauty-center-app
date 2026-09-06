import 'package:beauty_center_app/features/clinic/repository/clinic_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'clinic_details_state.dart';

@injectable
class ClinicDetailsCubit extends Cubit<ClinicDetailsState> {
  ClinicDetailsCubit(this._repository) : super(const ClinicDetailsState());

  final ClinicsRepository _repository;

  Future<void> loadClinicDetails(int centerId) async {
    emit(
      state.copyWith(status: ClinicDetailsStatus.loading, clearMessage: true),
    );

    final result = await _repository.getClinicDetails(centerId: centerId);
    if (isClosed) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ClinicDetailsStatus.failure,
          message: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          status: ClinicDetailsStatus.success,
          center: response.center,
        ),
      ),
    );
  }
}
