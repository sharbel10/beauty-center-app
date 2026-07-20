import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/services/location_service.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_cubit.dart';
import 'package:beauty_center_app/features/auth/models/customer.dart';
import 'package:beauty_center_app/features/profile/cubit/profile_state.dart';
import 'package:beauty_center_app/features/profile/models/profile_response.dart';
import 'package:beauty_center_app/features/profile/repository/profile_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(
    this._profileRepository,
    this._locationService,
    this._authCubit,
  ) : super(const ProfileState());

  final ProfileRepository _profileRepository;
  final LocationService _locationService;
  final AuthCubit _authCubit;

  Future<void> loadProfile() async {
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        locationStatus: LocationStatus.loading,
        clearMessage: true,
        clearLocationFailure: true,
      ),
    );

    final Future<Either<Failure, ProfileResponse>> profileFuture =
        _profileRepository.getProfile();
    final Future<LocationResult> locationFuture = _locationService
        .getCurrentLocation();

    final Either<Failure, ProfileResponse> profileResult = await profileFuture;
    if (isClosed) {
      return;
    }

    await profileResult.fold(
      (Failure failure) async {
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            message: failure.message,
          ),
        );
      },
      (ProfileResponse response) async {
        final Customer? customer = response.customer;
        if (customer != null) {
          await _authCubit.syncCustomer(customer);
        }
        emit(
          state.copyWith(
            status: ProfileStatus.success,
            customer: customer,
          ),
        );
      },
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
