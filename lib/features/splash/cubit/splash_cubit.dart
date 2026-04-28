import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/storage/preference_manager.dart';
import 'package:beauty_center_app/features/splash/cubit/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._preferenceManager) : super(const SplashState());

  final PreferenceManager _preferenceManager;

  Future<void> resolveStartupRoute() async {
    emit(state.copyWith(isLoading: true));
    await Future<void>.delayed(const Duration(seconds: 2));

    final bool isFirstLaunch = _preferenceManager.isFirstLaunch();
    if (isFirstLaunch) {
      await _preferenceManager.markFirstLaunchCompleted();
      emit(
        state.copyWith(
          isLoading: false,
          nextRouteName: RouteNames.onboarding,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoading: false,
        nextRouteName: _preferenceManager.isLoggedIn()
            ? RouteNames.home
            : RouteNames.login,
      ),
    );
  }
}
