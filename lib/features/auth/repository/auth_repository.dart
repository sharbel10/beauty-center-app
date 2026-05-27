import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/network/base_repository.dart';
import 'package:beauty_center_app/features/auth/models/auth_response.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class AuthRepository extends BaseRepository {
  AuthRepository(super.dioClient);

  Future<Either<Failure, RegisterResponse>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    return callApiWithErrorParser(
      dio.post(
        ApiEndpoints.register,
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      ),
      RegisterResponse.fromJson,
    );
  }

  Future<Either<Failure, VerifyOtpResponse>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    return callApiWithErrorParser(
      dio.post(ApiEndpoints.verifyOtp, data: {'email': email, 'otp': otp}),
      VerifyOtpResponse.fromJson,
    );
  }

  Future<Either<Failure, ResendOtpResponse>> resendOtp({
    required String email,
  }) async {
    return callApiWithErrorParser(
      dio.post(ApiEndpoints.resendOtp, data: {'email': email}),
      ResendOtpResponse.fromJson,
    );
  }

  Future<Either<Failure, LoginResponse>> login({
    required String login,
    required String password,
  }) async {
    return callApiWithErrorParser(
      dio.post(
        ApiEndpoints.login,
        data: {'login': login, 'password': password},
      ),
      LoginResponse.fromJson,
    );
  }

  Future<Either<Failure, LogoutResponse>> logout() async {
    return callApiWithErrorParser(
      dio.post(ApiEndpoints.logout),
      LogoutResponse.fromJson,
    );
  }

  Future<Either<Failure, ForgotPasswordResponse>> forgotPassword({
    required String login,
  }) async {
    return callApiWithErrorParser(
      dio.post(ApiEndpoints.forgotPassword, data: {'email': login}),
      ForgotPasswordResponse.fromJson,
    );
  }

  Future<Either<Failure, ResetPasswordResponse>> resetPassword({
    required String login,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    return callApiWithErrorParser(
      dio.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': login,
          'otp': otp,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      ),
      ResetPasswordResponse.fromJson,
    );
  }
}
