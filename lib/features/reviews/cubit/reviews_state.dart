import 'package:beauty_center_app/features/reviews/models/review_model.dart';
import 'package:equatable/equatable.dart';

enum ReviewsStatus { initial, loading, success, failure }

enum SubmitReviewStatus { initial, loading, success, failure }

class ReviewsState extends Equatable {
  const ReviewsState({
    this.status = ReviewsStatus.initial,
    this.submitStatus = SubmitReviewStatus.initial,
    this.reviews = const <ReviewModel>[],
    this.currentPage = 1,
    this.lastPage = 1,
    this.hasMore = false,
    this.message,
    this.isMessageError = false,
    this.submittingAppointmentId,
  });

  final ReviewsStatus status;
  final SubmitReviewStatus submitStatus;
  final List<ReviewModel> reviews;
  final int currentPage;
  final int lastPage;
  final bool hasMore;
  final String? message;
  final bool isMessageError;
  final int? submittingAppointmentId;

  bool get isLoading => status == ReviewsStatus.loading;
  bool get isSubmitting => submitStatus == SubmitReviewStatus.loading;
  bool get hasData => reviews.isNotEmpty;

  bool isAppointmentSubmitting(int appointmentId) =>
      submittingAppointmentId == appointmentId;

  ReviewsState copyWith({
    ReviewsStatus? status,
    SubmitReviewStatus? submitStatus,
    List<ReviewModel>? reviews,
    int? currentPage,
    int? lastPage,
    bool? hasMore,
    String? message,
    bool? isMessageError,
    bool clearMessage = false,
    int? submittingAppointmentId,
    bool clearSubmittingAppointment = false,
  }) {
    return ReviewsState(
      status: status ?? this.status,
      submitStatus: submitStatus ?? this.submitStatus,
      reviews: reviews ?? this.reviews,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasMore: hasMore ?? this.hasMore,
      message: clearMessage ? null : (message ?? this.message),
      isMessageError:
          clearMessage ? false : (isMessageError ?? this.isMessageError),
      submittingAppointmentId: clearSubmittingAppointment
          ? null
          : (submittingAppointmentId ?? this.submittingAppointmentId),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    submitStatus,
    reviews,
    currentPage,
    lastPage,
    hasMore,
    message,
    isMessageError,
    submittingAppointmentId,
  ];
}
