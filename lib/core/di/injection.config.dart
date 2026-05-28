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
import 'package:beauty_center_app/core/services/device_registration_service.dart'
    as _i501;
import 'package:beauty_center_app/core/services/firebase_messaging_service.dart'
    as _i502;
import 'package:beauty_center_app/core/storage/preference_manager.dart'
    as _i333;
import 'package:beauty_center_app/core/storage/secure_storage.dart' as _i925;
import 'package:beauty_center_app/features/device/repository/device_repository.dart'
    as _i503;
import 'package:beauty_center_app/features/auth/cubit/auth_cubit.dart' as _i196;
import 'package:beauty_center_app/features/auth/repository/auth_repository.dart'
    as _i609;
import 'package:beauty_center_app/features/clinic/cubit/clinic_details_cubit.dart'
    as _i784;
import 'package:beauty_center_app/features/clinic/cubit/clinic_employees_cubit.dart'
    as _i1028;
import 'package:beauty_center_app/features/clinic/cubit/clinic_offers_cubit.dart'
    as _i864;
import 'package:beauty_center_app/features/clinic/cubit/clinic_portfolio_cubit.dart'
    as _i408;
import 'package:beauty_center_app/features/clinic/cubit/clinic_services_cubit.dart'
    as _i875;
import 'package:beauty_center_app/features/clinic/repository/clinic_repository.dart'
    as _i983;
import 'package:beauty_center_app/features/explore/cubit/explore_cubit.dart'
    as _i562;
import 'package:beauty_center_app/features/explore/repository/explore_repository.dart'
    as _i187;
import 'package:beauty_center_app/features/home/cubit/home_cubit.dart' as _i92;
import 'package:beauty_center_app/features/home/repository/home_repository.dart'
    as _i668;
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
    gh.singleton<_i502.FirebaseMessagingService>(
      () => _i502.FirebaseMessagingService(),
    );
    gh.factory<_i503.DeviceRepository>(
      () => _i503.DeviceRepository(gh<_i1058.DioClient>()),
    );
    gh.singleton<_i501.DeviceRegistrationService>(
      () => _i501.DeviceRegistrationService(
        gh<_i502.FirebaseMessagingService>(),
        gh<_i503.DeviceRepository>(),
        gh<_i925.SecureStorage>(),
      ),
    );
    gh.factory<_i328.OnboardingCubit>(
      () => _i328.OnboardingCubit(gh<_i333.PreferenceManager>()),
    );
    gh.factory<_i609.AuthRepository>(
      () => _i609.AuthRepository(gh<_i1058.DioClient>()),
    );
    gh.factory<_i983.ClinicsRepository>(
      () => _i983.ClinicsRepository(gh<_i1058.DioClient>()),
    );
    gh.factory<_i187.ExploreRepository>(
      () => _i187.ExploreRepository(gh<_i1058.DioClient>()),
    );
    gh.factory<_i668.HomeRepository>(
      () => _i668.HomeRepository(gh<_i1058.DioClient>()),
    );
    gh.factory<_i784.ClinicDetailsCubit>(
      () => _i784.ClinicDetailsCubit(gh<_i983.ClinicsRepository>()),
    );
    gh.factory<_i1028.ClinicEmployeesCubit>(
      () => _i1028.ClinicEmployeesCubit(gh<_i983.ClinicsRepository>()),
    );
    gh.factory<_i864.ClinicOffersCubit>(
      () => _i864.ClinicOffersCubit(gh<_i983.ClinicsRepository>()),
    );
    gh.factory<_i408.ClinicPortfolioCubit>(
      () => _i408.ClinicPortfolioCubit(gh<_i983.ClinicsRepository>()),
    );
    gh.factory<_i875.ClinicServicesCubit>(
      () => _i875.ClinicServicesCubit(gh<_i983.ClinicsRepository>()),
    );
    gh.singleton<_i196.AuthCubit>(
      () => _i196.AuthCubit(
        gh<_i609.AuthRepository>(),
        gh<_i925.SecureStorage>(),
        gh<_i333.PreferenceManager>(),
        gh<_i501.DeviceRegistrationService>(),
      ),
    );
    gh.factory<_i92.HomeCubit>(
      () => _i92.HomeCubit(gh<_i668.HomeRepository>()),
    );
    gh.factory<_i562.ExploreCubit>(
      () => _i562.ExploreCubit(gh<_i187.ExploreRepository>()),
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
