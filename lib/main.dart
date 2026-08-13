import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/localization/app_locale_controller.dart';
import 'package:beauty_center_app/core/router/app_router.dart';
import 'package:beauty_center_app/core/services/device_registration_service.dart';
import 'package:beauty_center_app/core/services/firebase_messaging_service.dart';
import 'package:beauty_center_app/core/storage/preference_manager.dart';
import 'package:beauty_center_app/core/theme/app_theme.dart';
import 'package:beauty_center_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:beauty_center_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:toastification/toastification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  getIt<AppRouter>();
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await getIt<FirebaseMessagingService>().initialize();
  getIt<DeviceRegistrationService>().attachTokenRefreshListener();
  await AppLocaleController.instance.load(getIt<PreferenceManager>());
  runApp(const BeautyCenterApp());
}

class BeautyCenterApp extends StatelessWidget {
  const BeautyCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRouter appRouter = getIt<AppRouter>();

    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<FavoritesCubit>(
          create: (_) => getIt<FavoritesCubit>(),
        ),
        BlocProvider<NotificationsCubit>.value(
          value: getIt<NotificationsCubit>(),
        ),
      ],
      child: ToastificationWrapper(
        child: ValueListenableBuilder<Locale?>(
          valueListenable: AppLocaleController.instance.locale,
          builder: (BuildContext context, Locale? locale, _) {
            return MaterialApp.router(
              title: 'Lumina App',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: appRouter.router,
            );
          },
        ),
      ),
    );
  }
}
