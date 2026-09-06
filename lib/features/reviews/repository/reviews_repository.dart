import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/network/base_repository.dart';
import 'package:beauty_center_app/features/reviews/models/reviews_response.dart';
import 'package:beauty_center_app/features/reviews/models/submit_report_response.dart';
import 'package:beauty_center_app/features/reviews/models/submit_review_response.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class ReviewsRepository extends BaseRepository {
  ReviewsRepository(super.dioClient);

  Future<Either<Failure, ReviewsResponse>> getReviews({int page = 1}) {
    return callApiWithErrorParser(
      dio.get(
        ApiEndpoints.reviews,
        queryParameters: <String, dynamic>{'page': page},
      ),
      ReviewsResponse.fromJson,
    );
  }

  Future<Either<Failure, SubmitReviewResponse>> submitReview({
    required int centerId,
    required int appointmentId,
    required int serviceId,
    int? employeeId,
    required int rating,
    String? comment,
  }) {
    final Map<String, dynamic> body = <String, dynamic>{
      'center_id': centerId,
      'appointment_id': appointmentId,
      'service_id': serviceId,
      'rating': rating,
      if (employeeId != null) 'employee_id': employeeId,
      if (comment?.trim().isNotEmpty ?? false) 'comment': comment!.trim(),
    };

    return callApiWithErrorParser(
      dio.post(ApiEndpoints.reviews, data: body),
      SubmitReviewResponse.fromJson,
    );
  }

  Future<Either<Failure, SubmitReportResponse>> submitReport({
    required int reportedCenterId,
    required int appointmentId,
    required String reason,
    String? description,
  }) {
    final Map<String, dynamic> body = <String, dynamic>{
      'reported_center_id': reportedCenterId,
      'appointment_id': appointmentId,
      'reason': reason.trim(),
      if (description?.trim().isNotEmpty ?? false)
        'description': description!.trim(),
    };

    return callApiWithErrorParser(
      dio.post(ApiEndpoints.reports, data: body),
      SubmitReportResponse.fromJson,
    );
  }
}
