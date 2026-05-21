// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:beauty_center_app/core/di/injection.dart' as _i606;
import 'package:beauty_center_app/core/network/dio_client.dart' as _i1058;
import 'package:beauty_center_app/core/network/header_interceptor.dart'
    as _i719;
import 'package:beauty_center_app/core/router/app_router.dart' as _i329;
import 'package:beauty_center_app/core/storage/preference_manager.dart'
    as _i333;
import 'package:beauty_center_app/core/storage/secure_storage.dart' as _i925;
import 'package:beauty_center_app/features/auth/cubit/auth_cubit.dart' as _i196;
import 'package:beauty_center_app/features/auth/repository/auth_repository.dart'
    as _i609;
import 'package:beauty_center_app/features/explore/cubit/explore_cubit.dart'
    as _i901;
import 'package:beauty_center_app/features/explore/repository/explore_repository.dart'
    as _i902;
import 'package:beauty_center_app/features/home/cubit/home_cubit.dart' as _i701;
import 'package:beauty_center_app/features/home/repository/home_repository.dart'
    as _i702;
import 'package:beauty_center_app/features/onboarding/cubit/onboarding_cubit.dart'
    as _i328;
import 'package:beauty_center_app/features/splash/cubit/splash_cubit.dart'
    as _i420;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => registerModule.sharedPreferences,
      preResolve: true,
    );
    gh.singleton<_i925.SecureStorage>(() => _i925.SecureStorage());
    gh.singleton<_i333.PreferenceManager>(
      () => _i333.PreferenceManager(gh<_i460.SharedPreferences>()),
    );
    gh.singleton<_i719.HeaderInterceptor>(
      () => _i719.HeaderInterceptor(gh<_i925.SecureStorage>()),
    );
    gh.singleton<_i1058.DioClient>(
      () => _i1058.DioClient(gh<_i719.HeaderInterceptor>()),
    );
    gh.factory<_i328.OnboardingCubit>(
      () => _i328.OnboardingCubit(gh<_i333.PreferenceManager>()),
    );
    gh.factory<_i609.AuthRepository>(
      () => _i609.AuthRepository(gh<_i1058.DioClient>()),
    );
    gh.factory<_i702.HomeRepository>(
      () => _i702.HomeRepository(gh<_i1058.DioClient>()),
    );
    gh.factory<_i902.ExploreRepository>(
      () => _i902.ExploreRepository(gh<_i1058.DioClient>()),
    );
    gh.factory<_i701.HomeCubit>(
      () => _i701.HomeCubit(gh<_i702.HomeRepository>()),
    );
    gh.factory<_i901.ExploreCubit>(
      () => _i901.ExploreCubit(gh<_i902.ExploreRepository>()),
    );
    gh.singleton<_i196.AuthCubit>(
      () => _i196.AuthCubit(
        gh<_i609.AuthRepository>(),
        gh<_i925.SecureStorage>(),
        gh<_i333.PreferenceManager>(),
      ),
    );
    gh.factory<_i420.SplashCubit>(
      () => _i420.SplashCubit(
        gh<_i196.AuthCubit>(),
        gh<_i333.PreferenceManager>(),
      ),
    );
    gh.singleton<_i329.AppRouter>(
      () => _i329.AppRouter(
        gh<_i420.SplashCubit>(),
        gh<_i328.OnboardingCubit>(),
        gh<_i196.AuthCubit>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i606.RegisterModule {}
