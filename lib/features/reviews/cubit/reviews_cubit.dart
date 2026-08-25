import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/features/reviews/cubit/reviews_state.dart';
import 'package:beauty_center_app/features/reviews/models/reviews_response.dart';
import 'package:beauty_center_app/features/reviews/models/submit_review_response.dart';
import 'package:beauty_center_app/features/reviews/repository/reviews_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ReviewsCubit extends Cubit<ReviewsState> {
  ReviewsCubit(this._repository) : super(const ReviewsState());

  final ReviewsRepository _repository;

  Future<void> loadReviews({int page = 1}) async {
    emit(
      state.copyWith(
        status: ReviewsStatus.loading,
        clearMessage: true,
      ),
    );

    final Either<Failure, ReviewsResponse> result =
        await _repository.getReviews(page: page);

    result.fold(
      (Failure failure) {
        emit(
          state.copyWith(
            status: ReviewsStatus.failure,
            message: failure.message,
            isMessageError: true,
          ),
        );
      },
      (ReviewsResponse response) {
        final bool hasMore = response.meta.hasNextPage;
        emit(
          state.copyWith(
            status: ReviewsStatus.success,
            reviews: response.reviews,
            currentPage: response.meta.currentPage,
            lastPage: response.meta.lastPage,
            hasMore: hasMore,
          ),
        );
      },
    );
  }

  Future<void> submitReview({
    required int appointmentId,
    required int centerId,
    required int serviceId,
    int? employeeId,
    required int rating,
    String? comment,
  }) async {
    if (state.isAppointmentSubmitting(appointmentId)) {
      return;
    }

    emit(
      state.copyWith(
        submitStatus: SubmitReviewStatus.loading,
        submittingAppointmentId: appointmentId,
        clearMessage: true,
      ),
    );

    final Either<Failure, SubmitReviewResponse> result =
        await _repository.submitReview(
      centerId: centerId,
      appointmentId: appointmentId,
      serviceId: serviceId,
      employeeId: employeeId,
      rating: rating,
      comment: comment,
    );

    result.fold(
      (Failure failure) {
        emit(
          state.copyWith(
            submitStatus: SubmitReviewStatus.failure,
            message: failure.message,
            isMessageError: true,
            clearSubmittingAppointment: true,
          ),
        );

        throw failure;
      },
      (SubmitReviewResponse response) {
        emit(
          state.copyWith(
            submitStatus: SubmitReviewStatus.success,
            message: response.message.isEmpty
                ? 'Review submitted successfully.'
                : response.message,
            isMessageError: false,
            clearSubmittingAppointment: true,
          ),
        );
      },
    );
  }

  void clearMessage() {
    emit(state.copyWith(clearMessage: true));
  }
}
