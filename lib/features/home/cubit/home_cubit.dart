import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/services/location_service.dart';
import 'package:beauty_center_app/features/home/cubit/home_state.dart';
import 'package:beauty_center_app/features/home/models/home_response.dart';
import 'package:beauty_center_app/features/home/repository/home_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._homeRepository, this._locationService)
    : super(const HomeState());

  final HomeRepository _homeRepository;
  final LocationService _locationService;

  Future<void> loadHome() async {
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        locationStatus: LocationStatus.loading,
        clearMessage: true,
        clearLocationFailure: true,
      ),
    );

    // Start both in parallel; apply emits sequentially to avoid races.
    final Future<Either<Failure, HomeResponse>> homeFuture = _homeRepository
        .getHome();
    final Future<LocationResult> locationFuture = _locationService
        .getCurrentLocation();

    final Either<Failure, HomeResponse> homeResult = await homeFuture;
    if (isClosed) {
      return;
    }

    homeResult.fold(
      (Failure failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          message: failure.message,
        ),
      ),
      (HomeResponse response) => emit(
        state.copyWith(
          status: HomeStatus.success,
          data: response.data,
        ),
      ),
    );

    final LocationResult locationResult = await locationFuture;
    if (isClosed) {
      return;
    }
    _emitLocation(locationResult);
  }

  Future<void> refreshLocation() async {
    emit(
      state.copyWith(
        locationStatus: LocationStatus.loading,
        clearLocationFailure: true,
      ),
    );

    final LocationResult result = await _locationService.getCurrentLocation();
    if (isClosed) {
      return;
    }
    _emitLocation(result);
  }

  void _emitLocation(LocationResult result) {
    if (result.isSuccess) {
      emit(
        state.copyWith(
          locationStatus: LocationStatus.success,
          userLocation: result.location,
          clearLocationFailure: true,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        locationStatus: LocationStatus.failure,
        locationFailureReason: result.failureReason,
        clearLocation: true,
      ),
    );
  }
}
