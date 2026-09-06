import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/features/ai_recommendation/cubit/ai_recommendation_cubit.dart';
import 'package:beauty_center_app/features/ai_recommendation/views/ai_recommendation_view.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_cubit.dart';
import 'package:beauty_center_app/features/auth/views/forgot_password_view.dart';
import 'package:beauty_center_app/features/auth/views/login_view.dart';
import 'package:beauty_center_app/features/auth/views/otp_view.dart';
import 'package:beauty_center_app/features/auth/views/register_otp_view.dart';
import 'package:beauty_center_app/features/auth/views/register_view.dart';
import 'package:beauty_center_app/features/auth/views/reset_password_view.dart';
import 'package:beauty_center_app/features/book_treatment/cubit/book_treatment_cubit.dart';
import 'package:beauty_center_app/features/book_treatment/models/book_treatment_args.dart';
import 'package:beauty_center_app/features/book_treatment/views/book_treatment_view.dart';
import 'package:beauty_center_app/features/bookings/cubit/bookings_cubit.dart';
import 'package:beauty_center_app/features/bookings/views/bookings_view.dart';
import 'package:beauty_center_app/features/explore/cubit/explore_cubit.dart';
import 'package:beauty_center_app/features/explore/views/explore_view.dart';
import 'package:beauty_center_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:beauty_center_app/features/favorites/views/favorites_view.dart';
import 'package:beauty_center_app/features/home/cubit/home_cubit.dart';
import 'package:beauty_center_app/features/home/views/home_view.dart';
import 'package:beauty_center_app/features/notifications/views/notifications_view.dart';
import 'package:beauty_center_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:beauty_center_app/features/onboarding/views/onboarding_view.dart';
import 'package:beauty_center_app/features/profile/cubit/profile_cubit.dart';
import 'package:beauty_center_app/features/profile/views/profile_view.dart';
import 'package:beauty_center_app/features/reviews/cubit/report_cubit.dart';
import 'package:beauty_center_app/features/reviews/cubit/reviews_cubit.dart';
import 'package:beauty_center_app/features/splash/cubit/splash_cubit.dart';
import 'package:beauty_center_app/features/splash/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

@singleton
class AppRouter {
  // Single app-level router that centralizes navigation and auth guards.
  AppRouter(this._splashCubit, this._onboardingCubit, this._authCubit) {
    _router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: RouteNames.splashPath,
      redirect: (BuildContext context, GoRouterState state) {
        final String currentPath = state.matchedLocation;
        final bool isProtectedRoute = !_publicPaths.contains(currentPath);

        if (isProtectedRoute && !_authCubit.state.isAuthenticated) {
          return RouteNames.loginPath;
        }
        return null;
      },
      routes: <RouteBase>[
        GoRoute(
          name: RouteNames.splash,
          path: RouteNames.splashPath,
          builder: (context, state) => SplashView(cubit: _splashCubit),
        ),
        GoRoute(
          name: RouteNames.onboarding,
          path: RouteNames.onboardingPath,
          builder: (context, state) => OnboardingView(cubit: _onboardingCubit),
        ),
        GoRoute(
          name: RouteNames.login,
          path: RouteNames.loginPath,
          builder: (context, state) => LoginView(cubit: _authCubit),
        ),
        GoRoute(
          name: RouteNames.register,
          path: RouteNames.registerPath,
          builder: (context, state) => RegisterView(cubit: _authCubit),
        ),
        GoRoute(
          name: RouteNames.registerOtp,
          path: RouteNames.registerOtpPath,
          builder: (context, state) {
            final String? email = state.extra as String?;
            return RegisterOtpView(cubit: _authCubit, email: email);
          },
        ),
        GoRoute(
          name: RouteNames.forgotPassword,
          path: RouteNames.forgotPasswordPath,
          builder: (context, state) => ForgotPasswordView(cubit: _authCubit),
        ),
        GoRoute(
          name: RouteNames.verifyOtp,
          path: RouteNames.verifyOtpPath,
          builder: (context, state) {
            final String? initialEmail = state.extra as String?;
            return OtpView(cubit: _authCubit, initialEmail: initialEmail);
          },
        ),
        GoRoute(
          name: RouteNames.resetPassword,
          path: RouteNames.resetPasswordPath,
          builder: (context, state) {
            final Map<String, dynamic> data =
                state.extra as Map<String, dynamic>;
            return ResetPasswordView(
              cubit: _authCubit,
              email: data['email'] as String,
              otp: data['otp'] as String,
            );
          },
        ),
        GoRoute(
          name: RouteNames.home,
          path: RouteNames.homePath,
          builder: (context, state) =>
              HomeView(authCubit: _authCubit, homeCubit: getIt<HomeCubit>()),
        ),
        GoRoute(
          name: RouteNames.explore,
          path: RouteNames.explorePath,
          builder: (context, state) {
            final String? categoryId = state.uri.queryParameters['category_id'];
            final int? parsedCategoryId =
                categoryId != null && categoryId.isNotEmpty
                ? int.tryParse(categoryId)
                : null;
            return ExploreView(
              cubit: getIt<ExploreCubit>(),
              initialCategoryId: parsedCategoryId,
            );
          },
        ),
        GoRoute(
          name: RouteNames.favorites,
          path: RouteNames.favoritesPath,
          builder: (context, state) =>
              FavoritesView(cubit: getIt<FavoritesCubit>()),
        ),
        GoRoute(
          name: RouteNames.bookings,
          path: RouteNames.bookingsPath,
          builder: (context, state) => BookingsView(
            cubit: getIt<BookingsCubit>(),
            reviewsCubit: getIt<ReviewsCubit>(),
            reportCubit: getIt<ReportCubit>(),
          ),
        ),
        GoRoute(
          name: RouteNames.profile,
          path: RouteNames.profilePath,
          builder: (context, state) => ProfileView(
            authCubit: _authCubit,
            profileCubit: getIt<ProfileCubit>(),
          ),
        ),
        GoRoute(
          name: RouteNames.notifications,
          path: RouteNames.notificationsPath,
          builder: (context, state) => const NotificationsView(),
        ),
        GoRoute(
          name: RouteNames.aiRecommendation,
          path: RouteNames.aiRecommendationPath,
          builder: (context, state) =>
              AiRecommendationView(cubit: getIt<AiRecommendationCubit>()),
        ),
        GoRoute(
          name: RouteNames.bookTreatment,
          path: RouteNames.bookTreatmentPath,
          // Booking requires real navigation args; deep links or missing
          // extras redirect back to explore instead of booking against a
          // hardcoded clinic.
          redirect: (context, state) =>
              state.extra is BookTreatmentArgs ? null : RouteNames.explorePath,
          builder: (context, state) {
            return BookTreatmentView(
              args: state.extra! as BookTreatmentArgs,
              cubit: getIt<BookTreatmentCubit>(),
            );
          },
        ),
      ],
    );
    _routerRef = _router;
  }

  final SplashCubit _splashCubit;
  final OnboardingCubit _onboardingCubit;
  final AuthCubit _authCubit;
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

  static void navigateFromNotification({
    required String type,
    String? id,
    String? appointmentId,
    String? centerId,
  }) {
    final GoRouter? router = _routerRef;

    if (router == null) {
      return;
    }

    switch (type) {
      case 'booking':
      case 'appointment':
        router.goNamed(RouteNames.bookings);
        break;

      case 'explore':
      case 'center':
      case 'offer':
      case 'promotion':
        router.goNamed(RouteNames.explore);
        break;

      case 'home':
        router.goNamed(RouteNames.home);
        break;

      default:
        router.goNamed(RouteNames.notifications);
    }
  }
}
