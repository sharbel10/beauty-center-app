import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_cubit.dart';
import 'package:beauty_center_app/features/auth/views/forgot_password_view.dart';
import 'package:beauty_center_app/features/auth/views/login_view.dart';
import 'package:beauty_center_app/features/auth/views/otp_view.dart';
import 'package:beauty_center_app/features/auth/views/register_otp_view.dart';
import 'package:beauty_center_app/features/auth/views/register_view.dart';
import 'package:beauty_center_app/features/auth/views/reset_password_view.dart';
import 'package:beauty_center_app/features/home/views/home_view.dart';
import 'package:beauty_center_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:beauty_center_app/features/onboarding/views/onboarding_view.dart';
import 'package:beauty_center_app/features/splash/cubit/splash_cubit.dart';
import 'package:beauty_center_app/features/splash/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

@singleton
class AppRouter {
  // Single app-level router that centralizes navigation and auth guards.
  AppRouter(
    this._splashCubitFactory,
    this._onboardingCubitFactory,
    this._authCubitFactory,
  ) {
    _router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: RouteNames.splashPath,
      redirect: (BuildContext context, GoRouterState state) {
        // Auth persistence is disabled for now, so protected routes stay closed.
        final String currentPath = state.matchedLocation;
        final bool isProtectedRoute = !_publicPaths.contains(currentPath);

        if (isProtectedRoute) {
          return RouteNames.loginPath;
        }
        return null;
      },
      routes: <RouteBase>[
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
          builder: (context, state) => RegisterView(cubit: _authCubitFactory()),
        ),
        GoRoute(
          name: RouteNames.registerOtp,
          path: RouteNames.registerOtpPath,
          builder: (context, state) =>
              RegisterOtpView(cubit: _authCubitFactory()),
        ),
        GoRoute(
          name: RouteNames.forgotPassword,
          path: RouteNames.forgotPasswordPath,
          builder: (context, state) =>
              ForgotPasswordView(cubit: _authCubitFactory()),
        ),
        GoRoute(
          name: RouteNames.verifyOtp,
          path: RouteNames.verifyOtpPath,
          builder: (context, state) => OtpView(cubit: _authCubitFactory()),
        ),
        GoRoute(
          name: RouteNames.resetPassword,
          path: RouteNames.resetPasswordPath,
          builder: (context, state) =>
              ResetPasswordView(cubit: _authCubitFactory()),
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
    RouteNames.registerOtpPath,
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
}
