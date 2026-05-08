import 'package:beauty_center_app/features/auth/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(const AuthState(isAuthenticated: false));

  Future<void> login() async {
    await _completeFormStep();
  }

  Future<void> register() async {
    await _completeFormStep();
  }

  Future<void> resendRegistrationCode() async {
    await _completeFormStep();
  }

  Future<void> verifyRegistrationOtp() async {
    await _completeFormStep();
  }

  Future<void> sendPasswordResetCode() async {
    await _completeFormStep();
  }

  Future<void> verifyOtp() async {
    await _completeFormStep();
  }

  Future<void> resetPassword() async {
    await _completeFormStep();
  }

  Future<void> logout() async {
    emit(state.copyWith(isSubmitting: true));
    await Future<void>.value();
    emit(state.copyWith(isSubmitting: false, isAuthenticated: false));
  }

  Future<void> _completeFormStep() async {
    emit(state.copyWith(isSubmitting: true));
    await Future<void>.value();
    emit(state.copyWith(isSubmitting: false));
  }
}
