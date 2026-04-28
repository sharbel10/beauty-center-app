import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/storage/preference_manager.dart';
import 'package:beauty_center_app/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:beauty_center_app/features/auth/presentation/views/login_view.dart';
import 'package:beauty_center_app/features/home/presentation/views/home_view.dart';
import 'package:beauty_center_app/features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:beauty_center_app/features/onboarding/presentation/views/onboarding_view.dart';
import 'package:beauty_center_app/features/splash/presentation/bloc/splash_cubit.dart';
import 'package:beauty_center_app/features/splash/presentation/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

@singleton
class AppRouter {
  // Single app-level router that centralizes navigation and auth guards.
  AppRouter(
    this._preferenceManager,
    this._splashCubitFactory,
    this._onboardingCubitFactory,
    this._authCubitFactory,
  ) {
    _router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: RouteNames.splashPath,
      redirect: (BuildContext context, GoRouterState state) {
        // Redirect runs before each navigation and decides whether user
        // can access the requested route based on auth state.
        final bool isLoggedIn = _preferenceManager.isLoggedIn();
        final String currentPath = state.matchedLocation;
        final bool isAuthRoute = _authPaths.contains(currentPath);
        final bool isProtectedRoute = !_publicPaths.contains(currentPath);

        if (!isLoggedIn && isProtectedRoute) {
          return RouteNames.loginPath;
        }
        if (isLoggedIn && isAuthRoute) {
          return RouteNames.homePath;
        }
        return null;
      },
      routes: <RouteBase>[
        // TODO: Replace placeholders with feature pages as they are built.
        GoRoute(
          name: RouteNames.splash,
          path: RouteNames.splashPath,
          builder: (context, state) => SplashView(cubit: _splashCubitFactory()),
        ),
        GoRoute(
          name: RouteNames.onboarding,
          path: RouteNames.onboardingPath,
          builder: (context, state) =>
              OnboardingView(cubit: _onboardingCubitFactory()),
        ),
        GoRoute(
          name: RouteNames.login,
          path: RouteNames.loginPath,
          builder: (context, state) => LoginView(cubit: _authCubitFactory()),
        ),
        GoRoute(
          name: RouteNames.register,
          path: RouteNames.registerPath,
          builder: (context, state) => _placeholderPage('Register'),
        ),
        GoRoute(
          name: RouteNames.forgotPassword,
          path: RouteNames.forgotPasswordPath,
          builder: (context, state) => _placeholderPage('Forgot Password'),
        ),
        GoRoute(
          name: RouteNames.verifyOtp,
          path: RouteNames.verifyOtpPath,
          builder: (context, state) => _placeholderPage('Verify OTP'),
        ),
        GoRoute(
          name: RouteNames.resetPassword,
          path: RouteNames.resetPasswordPath,
          builder: (context, state) => _placeholderPage('Reset Password'),
        ),
        GoRoute(
          name: RouteNames.home,
          path: RouteNames.homePath,
          builder: (context, state) => HomeView(cubit: _authCubitFactory()),
        ),
      ],
    );
    _routerRef = _router;
  }

  final PreferenceManager _preferenceManager;
  final SplashCubit Function() _splashCubitFactory;
  final OnboardingCubit Function() _onboardingCubitFactory;
  final AuthCubit Function() _authCubitFactory;
  late final GoRouter _router;

  // Navigator key is shared so non-UI layers (e.g. interceptors) can trigger
  // navigation through router helpers when needed.
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static GoRouter? _routerRef;

  static const Set<String> _authPaths = <String>{
    RouteNames.loginPath,
    RouteNames.registerPath,
    RouteNames.forgotPasswordPath,
    RouteNames.verifyOtpPath,
    RouteNames.resetPasswordPath,
  };

  static const Set<String> _publicPaths = <String>{
    RouteNames.splashPath,
    RouteNames.onboardingPath,
    ..._authPaths,
  };

  GoRouter get router => _router;

  static void redirectToLogin() {
    // Used by network layer when token expires or 401 is received.
    _routerRef?.goNamed(RouteNames.login);
  }

  static Widget _placeholderPage(String title) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title Page',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
