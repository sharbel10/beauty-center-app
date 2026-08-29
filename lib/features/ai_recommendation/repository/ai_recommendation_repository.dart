import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/network/base_repository.dart';
import 'package:beauty_center_app/features/ai_recommendation/models/ai_recommendations_response.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@injectable
class AiRecommendationRepository extends BaseRepository {
  AiRecommendationRepository(super.dioClient);

  static const Duration _requestTimeout = Duration(minutes: 2);

  Future<Either<Failure, AiRecommendationsResponse>> getRecommendations({
    String? text,
    String? imagePath,
  }) async {
    final String normalizedText = text?.trim() ?? '';
    final FormData formData = FormData.fromMap(<String, dynamic>{
      if (normalizedText.isNotEmpty) 'text': normalizedText,
      if (imagePath != null)
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split(RegExp(r'[/\\]')).last,
        ),
    });

    return callApiWithErrorParser(
      dio.post(
        ApiEndpoints.aiRecommendations,
        data: formData,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          sendTimeout: _requestTimeout,
          receiveTimeout: _requestTimeout,
        ),
      ),
      AiRecommendationsResponse.fromJson,
    );
  }
}
