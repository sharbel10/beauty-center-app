import 'package:beauty_center_app/features/ai_recommendation/models/ai_recommendations_response.dart';
import 'package:equatable/equatable.dart';

enum AiRecommendationStatus { initial, loading, success, failure }

class AiRecommendationState extends Equatable {
  const AiRecommendationState({
    this.status = AiRecommendationStatus.initial,
    this.result,
    this.message,
  });

  final AiRecommendationStatus status;
  final AiRecommendationsResponse? result;
  final String? message;

  bool get isLoading => status == AiRecommendationStatus.loading;

  AiRecommendationState copyWith({
    AiRecommendationStatus? status,
    AiRecommendationsResponse? result,
    String? message,
    bool clearResult = false,
    bool clearMessage = false,
  }) {
    return AiRecommendationState(
      status: status ?? this.status,
      result: clearResult ? null : result ?? this.result,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, result, message];
}
