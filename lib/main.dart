import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/router/app_router.dart';
import 'package:beauty_center_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const BeautyCenterApp());
}

class BeautyCenterApp extends StatelessWidget {
  const BeautyCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AppRouter appRouter = getIt<AppRouter>();

    return MaterialApp.router(
      title: 'Beauty Center App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter.router,
    );
  }
}
