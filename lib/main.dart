import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/localization/app_locale_controller.dart';
import 'package:beauty_center_app/core/router/app_router.dart';
import 'package:beauty_center_app/core/storage/preference_manager.dart';
import 'package:beauty_center_app/core/theme/app_theme.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  await AppLocaleController.instance.load(getIt<PreferenceManager>());
  runApp(const BeautyCenterApp());
}

class BeautyCenterApp extends StatelessWidget {
  const BeautyCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRouter appRouter = getIt<AppRouter>();
    final AppLocaleController localeController = AppLocaleController.instance;

    return ValueListenableBuilder<Locale?>(
      valueListenable: localeController.locale,
      builder: (BuildContext context, Locale? locale, _) {
        return MaterialApp.router(
          locale: locale,
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: appRouter.router,
        );
      },
    );
  }
}
