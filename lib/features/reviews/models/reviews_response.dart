import 'package:beauty_center_app/features/explore/models/pagination_meta.dart';
import 'package:beauty_center_app/features/reviews/models/review_model.dart';
import 'package:equatable/equatable.dart';

class ReviewsResponse extends Equatable {
  const ReviewsResponse({
    required this.success,
    required this.reviews,
    required this.meta,
  });

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return ReviewsResponse(
      success: json['success'] as bool? ?? true,
      reviews: (data['reviews'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (dynamic item) => ReviewModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      meta: PaginationMeta.fromJson(
        json['meta'] as Map<String, dynamic>?,
      ),
    );
  }

  final bool success;
  final List<ReviewModel> reviews;
  final PaginationMeta meta;

  @override
  List<Object?> get props => <Object?>[success, reviews, meta];
}
