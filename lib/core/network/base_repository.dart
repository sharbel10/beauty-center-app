import 'dart:io';

import 'package:beauty_center_app/core/failures/failure.dart';
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
          final String message = payload['message']?.toString() ?? 'Error';
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
      final Response<dynamic>? response = error.response;
      final dynamic body = response?.data;
      // Extract backend message when available to show meaningful feedback.
      final String message = body is Map<String, dynamic>
          ? (body['message']?.toString() ?? 'Unexpected API error')
          : 'Unexpected API error';

      switch (response?.statusCode) {
        case 401:
          return Left(UnauthorizedFailure(message));
        case 404:
          return Left(NotFoundFailure(message));
        case 422:
          final Map<String, dynamic>? errors = body is Map<String, dynamic>
              ? body['errors'] as Map<String, dynamic>?
              : null;
          return Left(ValidationFailure(message, errors: errors));
        case 500:
          return Left(ServerFailure(message));
        default:
          return Left(UnknownFailure(message));
      }
    } on SocketException catch (error, stackTrace) {
      AppLogger.e('SocketException', error, stackTrace);
      return const Left(NetworkFailure('No internet connection'));
    } on HandshakeException catch (error, stackTrace) {
      AppLogger.e('HandshakeException', error, stackTrace);
      return const Left(SSLFailure('Secure connection failed'));
    } catch (error, stackTrace) {
      AppLogger.e('Unknown error in repository call', error, stackTrace);
      return Left(UnknownFailure(error.toString()));
    }
  }
}
