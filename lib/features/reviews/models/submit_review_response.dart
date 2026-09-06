import 'package:beauty_center_app/features/reviews/models/review_model.dart';
import 'package:equatable/equatable.dart';

class SubmitReviewResponse extends Equatable {
  const SubmitReviewResponse({
    required this.success,
    required this.message,
    this.review,
  });

  factory SubmitReviewResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final dynamic reviewJson = data['review'] ?? data;

    return SubmitReviewResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      review: reviewJson is Map<String, dynamic> && reviewJson.isNotEmpty
          ? ReviewModel.fromJson(reviewJson)
          : null,
    );
  }

  final bool success;
  final String message;
  final ReviewModel? review;

  @override
  List<Object?> get props => <Object?>[success, message, review];
}
