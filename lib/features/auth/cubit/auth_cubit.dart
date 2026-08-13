import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/services/device_registration_service.dart';
import 'package:beauty_center_app/core/storage/preference_manager.dart';
import 'package:beauty_center_app/core/storage/secure_storage.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_state.dart';
import 'package:beauty_center_app/features/auth/models/customer.dart';
import 'package:beauty_center_app/features/auth/repository/auth_repository.dart';
import 'package:beauty_center_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@singleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._authRepository,
    this._secureStorage,
    this._preferenceManager,
    this._deviceRegistration,
    this._notificationsCubit,
  ) : super(const AuthState(isAuthenticated: false));

  final AuthRepository _authRepository;
  final SecureStorage _secureStorage;
  final PreferenceManager _preferenceManager;
  final DeviceRegistrationService _deviceRegistration;
  final NotificationsCubit _notificationsCubit;

  Future<void> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(
      state.copyWith(
        status: AuthStatus.submitting,
        clearMessage: true,
        clearErrors: true,
      ),
    );
    final result = await _authRepository.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          emit(
            state.copyWith(
              status: AuthStatus.failure,
              message: failure.message,
              errors: failure.errors,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.failure,
              message: failure.message,
            ),
          );
        }
      },
      (response) {
        emit(
          state.copyWith(
            status: AuthStatus.success,
            message: response.message,
            customer: response.customer,
          ),
        );
      },
    );
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    emit(
      state.copyWith(
        status: AuthStatus.submitting,
        clearMessage: true,
        clearErrors: true,
      ),
    );
    final result = await _authRepository.verifyOtp(email: email, otp: otp);
    await result.fold<Future<void>>(
      (failure) async {
        if (failure is ValidationFailure) {
          emit(
            state.copyWith(
              status: AuthStatus.failure,
              message: failure.message,
              errors: failure.errors,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.failure,
              message: failure.message,
            ),
          );
        }
      },
      (response) async {
        if (response.token != null) {
          await _secureStorage.saveToken(
            response.token!.accessToken,
            expiry: response.token!.expiresAt,
          );
          await _preferenceManager.setLoggedIn(true);
          if (response.customer != null) {
            await _preferenceManager.saveCustomer(response.customer!);
          }
          emit(
            state.copyWith(
              status: AuthStatus.success,
              isAuthenticated: true,
              message: response.message,
              customer: response.customer,
              token: response.token!.accessToken,
            ),
          );
          await _startNotificationSession();
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.success,
              message: response.message,
              customer: response.customer,
            ),
          );
        }
      },
    );
  }

  Future<void> resendOtp({required String email}) async {
    emit(
      state.copyWith(
        status: AuthStatus.submitting,
        clearMessage: true,
        clearErrors: true,
      ),
    );
    final result = await _authRepository.resendOtp(email: email);
    result.fold(
      (failure) {
        emit(
          state.copyWith(status: AuthStatus.failure, message: failure.message),
        );
      },
      (response) {
        emit(
          state.copyWith(status: AuthStatus.success, message: response.message),
        );
      },
    );
  }

  Future<void> login({required String login, required String password}) async {
    emit(
      state.copyWith(
        status: AuthStatus.submitting,
        clearMessage: true,
        clearErrors: true,
      ),
    );
    final result = await _authRepository.login(
      login: login,
      password: password,
    );
    await result.fold<Future<void>>(
      (failure) async {
        if (failure is ValidationFailure) {
          emit(
            state.copyWith(
              status: AuthStatus.failure,
              message: failure.message,
              errors: failure.errors,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.failure,
              message: failure.message,
            ),
          );
        }
      },
      (response) async {
        if (response.token != null) {
          await _secureStorage.saveToken(
            response.token!.accessToken,
            expiry: response.token!.expiresAt,
          );
          await _preferenceManager.setLoggedIn(true);
          if (response.customer != null) {
            await _preferenceManager.saveCustomer(response.customer!);
          }
          emit(
            state.copyWith(
              status: AuthStatus.success,
              isAuthenticated: true,
              message: response.message,
              customer: response.customer,
              token: response.token!.accessToken,
            ),
          );
          await _startNotificationSession();
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.success,
              message: response.message,
            ),
          );
        }
      },
    );
  }

  String userDisplayName({String guestLabel = 'Guest'}) =>
      state.customer?.name ??
      _preferenceManager.getCustomerName() ??
      guestLabel;

  Future<void> syncCustomer(Customer customer) async {
    await _preferenceManager.saveCustomer(customer);
    emit(state.copyWith(customer: customer));
  }

  Future<void> logout() async {
    emit(
      state.copyWith(
        status: AuthStatus.submitting,
        clearMessage: true,
        clearErrors: true,
      ),
    );

    // Unregister the device while the access token is still valid.
    // Logout revokes the token on the server, so DELETE /devices must run first.
    await _deviceRegistration.unregisterDeviceToken();

    final result = await _authRepository.logout();
    await result.fold<Future<void>>(
      (failure) async {
        emit(
          state.copyWith(status: AuthStatus.failure, message: failure.message),
        );
      },
      (response) async {
        _notificationsCubit.reset();
        await _secureStorage.clearAll();
        await _preferenceManager.setLoggedIn(false);
        await _preferenceManager.clearCustomer();
        emit(
          state.copyWith(
            status: AuthStatus.success,
            isAuthenticated: false,
            message: response.message,
            clearCustomer: true,
            clearToken: true,
          ),
        );
      },
    );
  }

  Future<void> checkAuthStatus() async {
    final token = await _secureStorage.getToken();
    final expiry = await _secureStorage.getExpiry();
    final bool isLoggedIn = _preferenceManager.isLoggedIn();

    if (token != null && token.isNotEmpty) {
      bool isExpired = false;
      if (expiry != null) {
        final expiryDate = DateTime.tryParse(expiry);
        if (expiryDate != null && expiryDate.isBefore(DateTime.now())) {
          isExpired = true;
        }
      }

      if (isExpired) {
        await _secureStorage.clearToken();
        await _preferenceManager.setLoggedIn(false);
        await _preferenceManager.clearCustomer();
        emit(
          state.copyWith(
            isAuthenticated: false,
            clearToken: true,
            clearCustomer: true,
          ),
        );
      } else {
        if (!isLoggedIn) {
          await _preferenceManager.setLoggedIn(true);
        }
        emit(
          state.copyWith(
            isAuthenticated: true,
            token: token,
            customer: state.customer ?? _preferenceManager.getCustomer(),
          ),
        );
      }
    } else {
      if (isLoggedIn) {
        await _preferenceManager.setLoggedIn(false);
      }
      emit(state.copyWith(isAuthenticated: false, clearToken: true));
    }
  }

  Future<void> forgotPassword({required String login}) async {
    emit(
      state.copyWith(
        status: AuthStatus.submitting,
        clearMessage: true,
        clearErrors: true,
      ),
    );
    final result = await _authRepository.forgotPassword(login: login);
    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          emit(
            state.copyWith(
              status: AuthStatus.failure,
              message: failure.message,
              errors: failure.errors,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.failure,
              message: failure.message,
            ),
          );
        }
      },
      (response) {
        emit(
          state.copyWith(status: AuthStatus.success, message: response.message),
        );
      },
    );
  }

  Future<void> resetPassword({
    required String login,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    emit(
      state.copyWith(
        status: AuthStatus.submitting,
        clearMessage: true,
        clearErrors: true,
      ),
    );
    final result = await _authRepository.resetPassword(
      login: login,
      otp: otp,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    result.fold(
      (failure) {
        if (failure is ValidationFailure) {
          emit(
            state.copyWith(
              status: AuthStatus.failure,
              message: failure.message,
              errors: failure.errors,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: AuthStatus.failure,
              message: failure.message,
            ),
          );
        }
      },
      (response) {
        emit(
          state.copyWith(status: AuthStatus.success, message: response.message),
        );
      },
    );
  }

  Future<void> _startNotificationSession() async {
    _deviceRegistration.attachTokenRefreshListener();
    await _deviceRegistration.syncDeviceToken();
    await _notificationsCubit.loadCounts();
  }
}
