import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/router/app_router.dart';
import 'package:beauty_center_app/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@singleton
class HeaderInterceptor extends InterceptorsWrapper {
  HeaderInterceptor(this._secureStorage);

  final SecureStorage _secureStorage;

  // Endpoints that should not trigger forced logout on 401.
  static const Set<String> _publicEndpoints = <String>{
    ApiEndpoints.login,
    ApiEndpoints.register,
    ApiEndpoints.forgotPassword,
  };

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Attach access token to every request when available.
    final String? token = await _secureStorage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final int? statusCode = err.response?.statusCode;
    final String path = err.requestOptions.path;
    final bool isPublicEndpoint = _publicEndpoints.any(path.contains);

    // If token is invalid/expired on protected endpoint, clear local auth state
    // and route user back to login for re-authentication.
    if (statusCode == 401 && !isPublicEndpoint) {
      await _secureStorage.clearToken();
      AppRouter.redirectToLogin();
    }
    handler.next(err);
  }
}
