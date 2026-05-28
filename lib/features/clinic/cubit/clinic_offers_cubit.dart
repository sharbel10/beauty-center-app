import 'package:beauty_center_app/features/clinic/cubit/clinic_offers_state.dart';
import 'package:beauty_center_app/features/clinic/repository/clinic_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:injectable/injectable.dart';

@injectable
class ClinicOffersCubit extends Cubit<ClinicOffersState> {
  final ClinicsRepository _repository;

  ClinicOffersCubit(this._repository) : super(ClinicOffersInitial());

  Future<void> fetchClinicOffersIfNeeded(int centerId) async {
    if (state is ClinicOffersLoading || state is ClinicOffersSuccess) {
      return;
    }
    await fetchClinicOffers(centerId);
  }

  Future<void> fetchClinicOffers(int centerId) async {
    emit(ClinicOffersLoading());

    final result = await _repository.getClinicOffers(centerId: centerId);
    if (isClosed) return;
    result.fold(
      (failure) {
        emit(ClinicOffersFailure(failure.message));
      },
      (response) {
        emit(ClinicOffersSuccess(response.offers));
      },
    );
  }
}
