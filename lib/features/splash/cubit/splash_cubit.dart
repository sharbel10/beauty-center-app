import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/storage/preference_manager.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_cubit.dart';
import 'package:beauty_center_app/features/splash/cubit/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class SplashCubit extends Cubit<SplashState> {
  SplashCubit(this._authCubit, this._preferenceManager)
    : super(const SplashState());

  final AuthCubit _authCubit;
  final PreferenceManager _preferenceManager;

  Future<void> resolveStartupRoute() async {
    emit(state.copyWith(isLoading: true));
    await Future.wait<void>(<Future<void>>[
      _authCubit.checkAuthStatus(),
      Future<void>.delayed(const Duration(milliseconds: 2000)),
    ]);

    String nextRoute;
    if (_authCubit.state.isAuthenticated || _preferenceManager.isLoggedIn()) {
      nextRoute = RouteNames.home;
    } else if (_preferenceManager.isFirstLaunch()) {
      nextRoute = RouteNames.onboarding;
    } else {
      nextRoute = RouteNames.login;
    }

    emit(state.copyWith(isLoading: false, nextRouteName: nextRoute));
  }
}
