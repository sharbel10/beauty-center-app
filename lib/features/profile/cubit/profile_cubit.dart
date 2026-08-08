import 'dart:io';

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
  ProfileCubit(this._profileRepository, this._locationService, this._authCubit)
    : super(const ProfileState());

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
            stats: response.stats,
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

  void toggleEditMode() {
    emit(state.copyWith(isEditMode: !state.isEditMode));
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    String? gender,
    String? birthDate,
    String? city,
    String? address,
    String? preferredLocale,
    bool? notificationsEnabled,
  }) async {
    emit(state.copyWith(status: ProfileStatus.updating, clearMessage: true));

    final Map<String, dynamic> data = <String, dynamic>{
      'name': name,
      'phone': phone,
    };

    if (gender != null && gender.isNotEmpty) {
      data['gender'] = gender;
    }
    if (birthDate != null && birthDate.isNotEmpty) {
      data['birth_date'] = birthDate;
    }
    if (city != null && city.isNotEmpty) {
      data['city'] = city;
    }
    if (address != null && address.isNotEmpty) {
      data['address'] = address;
    }
    if (preferredLocale != null && preferredLocale.isNotEmpty) {
      data['preferred_locale'] = preferredLocale;
    }
    if (notificationsEnabled != null) {
      data['notifications_enabled'] = notificationsEnabled;
    }

    final Either<Failure, ProfileResponse> result = await _profileRepository
        .updateProfile(data);

    if (isClosed) {
      return;
    }

    await result.fold(
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
            stats: response.stats,
            isEditMode: false,
            message: response.message ?? 'profileUpdatedSuccessfully',
          ),
        );
      },
    );
  }

  Future<void> uploadAvatar(File avatarFile) async {
    emit(state.copyWith(status: ProfileStatus.updating, clearMessage: true));

    final Either<Failure, ProfileResponse> result = await _profileRepository
        .uploadAvatar(avatarFile);

    if (isClosed) {
      return;
    }

    await result.fold(
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
            stats: response.stats,
            message: response.message ?? 'avatarUpdatedSuccessfully',
          ),
        );
      },
    );
  }

  Future<void> deleteAccount() async {
    emit(state.copyWith(status: ProfileStatus.updating, clearMessage: true));

    final Either<Failure, void> result = await _profileRepository
        .deleteAccount();

    if (isClosed) {
      return;
    }

    await result.fold(
      (Failure failure) async {
        emit(
          state.copyWith(
            status: ProfileStatus.failure,
            message: failure.message,
          ),
        );
      },
      (void _) async {
        await _authCubit.logout();
        emit(
          state.copyWith(
            status: ProfileStatus.success,
            message: 'accountDeletedSuccessfully',
          ),
        );
      },
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) async {
    emit(state.copyWith(status: ProfileStatus.updating, clearMessage: true));

    final Either<Failure, ProfileResponse> result = await _profileRepository
        .changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
          passwordConfirmation: passwordConfirmation,
        );

    if (isClosed) {
      return;
    }

    await result.fold(
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
        // Logout after password change for security
        await _authCubit.logout();
        emit(
          state.copyWith(
            status: ProfileStatus.success,
            customer: customer,
            stats: response.stats,
            message: 'passwordChangedReLogin',
          ),
        );
      },
    );
  }
}
