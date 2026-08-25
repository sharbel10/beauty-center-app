import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/features/reviews/cubit/report_state.dart';
import 'package:beauty_center_app/features/reviews/models/submit_report_response.dart';
import 'package:beauty_center_app/features/reviews/repository/reviews_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ReportCubit extends Cubit<ReportState> {
  ReportCubit(this._repository) : super(const ReportState());

  final ReviewsRepository _repository;

  Future<void> submitReport({
    required int appointmentId,
    required int reportedCenterId,
    required String reason,
    String? description,
  }) async {
    if (state.isAppointmentReporting(appointmentId)) {
      return;
    }

    emit(
      state.copyWith(
        status: SubmitReportStatus.loading,
        reportingAppointmentId: appointmentId,
        clearMessage: true,
      ),
    );

    final Either<Failure, SubmitReportResponse> result =
        await _repository.submitReport(
      reportedCenterId: reportedCenterId,
      appointmentId: appointmentId,
      reason: reason,
      description: description,
    );

    result.fold(
      (Failure failure) {
        emit(
          state.copyWith(
            status: SubmitReportStatus.failure,
            message: failure.message,
            isMessageError: true,
            clearReportingAppointment: true,
          ),
        );

        throw failure;
      },
      (SubmitReportResponse response) {
        emit(
          state.copyWith(
            status: SubmitReportStatus.success,
            message: response.message.isEmpty
                ? 'Report submitted successfully.'
                : response.message,
            isMessageError: false,
            clearReportingAppointment: true,
          ),
        );
      },
    );
  }

  void clearMessage() {
    emit(state.copyWith(clearMessage: true));
  }
}
