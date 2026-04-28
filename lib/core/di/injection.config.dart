// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint

import 'package:beauty_center_app/core/network/dio_client.dart';
import 'package:beauty_center_app/core/network/header_interceptor.dart';
import 'package:beauty_center_app/core/router/app_router.dart';
import 'package:beauty_center_app/core/storage/preference_manager.dart';
import 'package:beauty_center_app/core/storage/secure_storage.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_cubit.dart';
import 'package:beauty_center_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:beauty_center_app/features/splash/cubit/splash_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'injection.dart' as i1;

extension GetItInjectableX on GetIt {
  Future<GetIt> init({
    String? environment,
    EnvironmentFilter? environmentFilter,
  }) async {
    final gh = GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    final sharedPreferences = await registerModule.sharedPreferences;
    gh.singleton<SharedPreferences>(() => sharedPreferences);
    gh.singleton<SecureStorage>(() => SecureStorage());
    gh.singleton<HeaderInterceptor>(
      () => HeaderInterceptor(gh<SecureStorage>()),
    );
    gh.singleton<DioClient>(() => DioClient(gh<HeaderInterceptor>()));
    gh.singleton<PreferenceManager>(
      () => PreferenceManager(gh<SharedPreferences>()),
    );
    gh.factory<AuthCubit>(() => AuthCubit(gh<PreferenceManager>()));
    gh.factory<OnboardingCubit>(() => OnboardingCubit());
    gh.factory<SplashCubit>(() => SplashCubit(gh<PreferenceManager>()));
    gh.singleton<AppRouter>(
      () => AppRouter(
        gh<PreferenceManager>(),
        () => gh<SplashCubit>(),
        () => gh<OnboardingCubit>(),
        () => gh<AuthCubit>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends i1.RegisterModule {}
