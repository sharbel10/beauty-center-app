import 'package:beauty_center_app/core/storage/preference_manager.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._preferenceManager)
      : super(AuthState(isAuthenticated: _preferenceManager.isLoggedIn()));

  final PreferenceManager _preferenceManager;

  Future<void> login() async {
    emit(state.copyWith(isSubmitting: true));
    await _preferenceManager.setLoggedIn(true);
    emit(
      state.copyWith(
        isSubmitting: false,
        isAuthenticated: true,
      ),
    );
  }

  Future<void> logout() async {
    emit(state.copyWith(isSubmitting: true));
    await _preferenceManager.setLoggedIn(false);
    emit(
      state.copyWith(
        isSubmitting: false,
        isAuthenticated: false,
      ),
    );
  }
}
