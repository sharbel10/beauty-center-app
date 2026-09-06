import 'dart:io';

import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/network/api_error_messages.dart';
import 'package:beauty_center_app/core/network/dio_client.dart';
import 'package:beauty_center_app/core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

abstract class BaseRepository {
  BaseRepository(this._dioClient);

  final DioClient _dioClient;

  Dio get dio => _dioClient.dio;

  // Standard API wrapper for repositories:
  // - executes request
  // - parses Laravel-style payloads
  // - maps errors into typed Failures
  // - returns Either<Failure, T> to keep calling layers explicit
  Future<Either<Failure, T>> callApiWithErrorParser<T>(
    Future<Response<dynamic>> apiCall,
    T Function(Map<String, dynamic> json) parser,
  ) async {
    try {
      final Response<dynamic> response = await apiCall;
      final dynamic payload = response.data;

      // Prefer passing the full response payload (envelope) to the parser.
      // The auth API returns the envelope: { success, message, data }
      if (payload is Map<String, dynamic>) {
        final bool success = payload['success'] as bool? ?? true;
        if (!success) {
          final String message =
              payload['message']?.toString() ?? ApiErrorMessages.unexpected;
          final Map<String, dynamic>? errors =
              payload['errors'] as Map<String, dynamic>?;
          return Left(ValidationFailure(message, errors: errors));
        }
        return Right(parser(payload));
      }

      // If payload is not a Map (rare), wrap it under `data` so parser
      // implementations that expect a map won't crash.
      return Right(parser(<String, dynamic>{'data': payload}));
    } on DioException catch (error, stackTrace) {
      AppLogger.e(
        'DioException on ${error.requestOptions.path}',
        error,
        stackTrace,
      );
      return Left(_mapDioException(error));
    } on SocketException catch (error, stackTrace) {
      AppLogger.e('SocketException', error, stackTrace);
      return Left(NetworkFailure(ApiErrorMessages.noInternet));
    } on HandshakeException catch (error, stackTrace) {
      AppLogger.e('HandshakeException', error, stackTrace);
      return Left(SSLFailure(ApiErrorMessages.serverUnavailable));
    } catch (error, stackTrace) {
      AppLogger.e('Unknown error in repository call', error, stackTrace);
      return Left(UnknownFailure(ApiErrorMessages.unexpected));
    }
  }

  Failure _mapDioException(DioException error) {
    final Response<dynamic>? response = error.response;
    final dynamic body = response?.data;
    final String? backendMessage = body is Map<String, dynamic>
        ? body['message']?.toString()
        : null;
    final bool hasBackendMessage =
        backendMessage != null && backendMessage.trim().isNotEmpty;

    // Prefer the exact backend message whenever the API returned one
    // (e.g. booking an unavailable slot → 422 + message).
    if (hasBackendMessage) {
      final String message = backendMessage.trim();
      switch (response?.statusCode) {
        case 401:
          return UnauthorizedFailure(message);
        case 404:
          return NotFoundFailure(message);
        case 422:
          final Map<String, dynamic>? errors = body is Map<String, dynamic>
              ? body['errors'] as Map<String, dynamic>?
              : null;
          return ValidationFailure(message, errors: errors);
        case 500:
        case 502:
        case 503:
        case 504:
          return ServerFailure(message);
        default:
          return UnknownFailure(message);
      }
    }

    // No response body — connection / timeout / empty server errors.
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure(ApiErrorMessages.serverUnavailable);
      case DioExceptionType.connectionError:
        if (error.error is SocketException) {
          return NetworkFailure(ApiErrorMessages.noInternet);
        }
        return NetworkFailure(ApiErrorMessages.serverUnavailable);
      case DioExceptionType.badResponse:
        final int? status = response?.statusCode;
        if (status != null && status >= 500) {
          return ServerFailure(ApiErrorMessages.unexpected);
        }
        return UnknownFailure(ApiErrorMessages.unexpected);
      case DioExceptionType.cancel:
        return UnknownFailure(ApiErrorMessages.unexpected);
      case DioExceptionType.badCertificate:
        return SSLFailure(ApiErrorMessages.serverUnavailable);
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkFailure(ApiErrorMessages.noInternet);
        }
        return NetworkFailure(ApiErrorMessages.serverUnavailable);
    }
  }
}
