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
    Future<Response<T>> apiCall,
    T Function(dynamic json) parser,
  ) async {
    try {
      final Response<T> response = await apiCall;
      final dynamic payload = response.data;

      // Common Laravel shape: { "data": ... }. Fallback to raw body otherwise.
      if (payload is Map<String, dynamic> && payload['data'] != null) {
        return Right(parser(payload['data']));
      }

      return Right(parser(payload));
    } on DioException catch (error, stackTrace) {
      AppLogger.e('DioException on ${error.requestOptions.path}', error, stackTrace);
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
