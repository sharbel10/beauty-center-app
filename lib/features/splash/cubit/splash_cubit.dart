import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/features/splash/cubit/splash_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class SplashCubit extends Cubit<SplashState> {
  SplashCubit() : super(const SplashState());

  Future<void> resolveStartupRoute() async {
    emit(state.copyWith(isLoading: true));
    await Future<void>.delayed(const Duration(seconds: 2));

    emit(
      state.copyWith(isLoading: false, nextRouteName: RouteNames.onboarding),
    );
  }
}
