import 'package:beauty_center_app/features/book_treatment/repository/booking_repository.dart';
import 'package:beauty_center_app/features/bookings/cubit/bookings_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class BookingsCubit extends Cubit<BookingsState> {
  BookingsCubit(this._repository) : super(const BookingsState());

  final BookingRepository _repository;

  Future<void> loadAppointments() async {
    emit(
      state.copyWith(
        status: BookingsStatus.loading,
        clearMessage: true,
        clearAction: true,
      ),
    );

    final upcomingResult = await _repository.getAppointments(scope: 'upcoming');
    if (isClosed) {
      return;
    }

    await upcomingResult.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: BookingsStatus.failure,
            message: failure.message,
          ),
        );
      },
      (upcomingResponse) async {
        final historyResult = await _repository.getAppointments(
          scope: 'history',
        );
        if (isClosed) {
          return;
        }
        historyResult.fold(
          (failure) {
            emit(
              state.copyWith(
                status: BookingsStatus.failure,
                message: failure.message,
              ),
            );
          },
          (historyResponse) {
            emit(
              state.copyWith(
                status: BookingsStatus.success,
                upcoming: upcomingResponse.appointments,
                history: historyResponse.appointments,
                clearMessage: true,
                clearAction: true,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> cancelAppointment(int appointmentId) async {
    emit(
      state.copyWith(actionAppointmentId: appointmentId, clearMessage: true),
    );

    final result = await _repository.cancelAppointment(
      appointmentId: appointmentId,
    );
    if (isClosed) {
      return;
    }

    await result.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: BookingsStatus.failure,
            message: failure.message,
            clearAction: true,
          ),
        );
      },
      (response) async {
        emit(
          state.copyWith(
            message: response.message.isEmpty
                ? 'Appointment cancelled successfully.'
                : response.message,
            clearAction: true,
          ),
        );
        await loadAppointments();
      },
    );
  }
}
