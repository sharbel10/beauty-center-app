import 'package:beauty_center_app/features/clinic/cubit/clinic_portfolio_state.dart';
import 'package:beauty_center_app/features/clinic/repository/clinic_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ClinicPortfolioCubit extends Cubit<ClinicPortfolioState> {
  final ClinicsRepository _repository;

  ClinicPortfolioCubit(this._repository) : super(ClinicPortfolioInitial());

  Future<void> fetchClinicPortfolio(int centerId) async {
    emit(ClinicPortfolioLoading());

    final result = await _repository.getClinicPortfolio(centerId: centerId);
    if (isClosed) return;
    result.fold(
      (failure) {
        emit(ClinicPortfolioFailure(failure.message));
      },
      (response) {
        emit(ClinicPortfolioSuccess(response.portfolio));
      },
    );
  }
}
