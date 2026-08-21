import 'dart:io';

import 'package:beauty_center_app/features/ai_recommendation/cubit/ai_recommendation_state.dart';
import 'package:beauty_center_app/features/ai_recommendation/repository/ai_recommendation_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class AiRecommendationCubit extends Cubit<AiRecommendationState> {
  AiRecommendationCubit(this._repository)
    : super(const AiRecommendationState());

  static const int maxTextLength = 1000;
  static const int maxImageBytes = 5 * 1024 * 1024;
  static const Set<String> allowedImageExtensions = <String>{
    'jpg',
    'jpeg',
    'png',
    'webp',
  };

  final AiRecommendationRepository _repository;

  Future<void> request({String? text, String? imagePath}) async {
    if (state.isLoading) return;

    final String normalizedText = text?.trim() ?? '';
    final String? normalizedImagePath = imagePath?.trim();
    if (normalizedText.isEmpty &&
        (normalizedImagePath == null || normalizedImagePath.isEmpty)) {
      throw const AiRecommendationInputException(
        AiRecommendationInputError.empty,
      );
    }
    if (normalizedText.length > maxTextLength) {
      throw const AiRecommendationInputException(
        AiRecommendationInputError.textTooLong,
      );
    }
    if (normalizedImagePath != null && normalizedImagePath.isNotEmpty) {
      final String extension = normalizedImagePath
          .split('.')
          .last
          .toLowerCase();
      if (!allowedImageExtensions.contains(extension)) {
        throw const AiRecommendationInputException(
          AiRecommendationInputError.unsupportedImage,
        );
      }
      final File image = File(normalizedImagePath);
      if (!await image.exists()) {
        throw const AiRecommendationInputException(
          AiRecommendationInputError.missingImage,
        );
      }
      if (await image.length() > maxImageBytes) {
        throw const AiRecommendationInputException(
          AiRecommendationInputError.imageTooLarge,
        );
      }
    }

    emit(
      state.copyWith(
        status: AiRecommendationStatus.loading,
        clearMessage: true,
        clearResult: true,
      ),
    );
    final result = await _repository.getRecommendations(
      text: normalizedText,
      imagePath: normalizedImagePath,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AiRecommendationStatus.failure,
          message: failure.message,
        ),
      ),
      (response) => emit(
        state.copyWith(
          status: AiRecommendationStatus.success,
          result: response,
          clearMessage: true,
        ),
      ),
    );
  }

  void reset() => emit(const AiRecommendationState());
}

enum AiRecommendationInputError {
  empty,
  textTooLong,
  imageTooLarge,
  unsupportedImage,
  missingImage,
}

class AiRecommendationInputException implements Exception {
  const AiRecommendationInputException(this.error);

  final AiRecommendationInputError error;
}
