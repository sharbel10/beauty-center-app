import 'package:beauty_center_app/features/bookings/models/appointment_model.dart';
import 'package:equatable/equatable.dart';

enum BookingsStatus { initial, loading, success, failure }

class BookingsState extends Equatable {
  const BookingsState({
    this.status = BookingsStatus.initial,
    this.upcoming = const <AppointmentModel>[],
    this.history = const <AppointmentModel>[],
    this.message,
    this.actionAppointmentId,
  });

  final BookingsStatus status;
  final List<AppointmentModel> upcoming;
  final List<AppointmentModel> history;
  final String? message;
  final int? actionAppointmentId;

  bool get isLoading => status == BookingsStatus.loading;
  bool get hasData => upcoming.isNotEmpty || history.isNotEmpty;

  BookingsState copyWith({
    BookingsStatus? status,
    List<AppointmentModel>? upcoming,
    List<AppointmentModel>? history,
    String? message,
    int? actionAppointmentId,
    bool clearMessage = false,
    bool clearAction = false,
  }) {
    return BookingsState(
      status: status ?? this.status,
      upcoming: upcoming ?? this.upcoming,
      history: history ?? this.history,
      message: clearMessage ? null : (message ?? this.message),
      actionAppointmentId: clearAction
          ? null
          : (actionAppointmentId ?? this.actionAppointmentId),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    upcoming,
    history,
    message,
    actionAppointmentId,
  ];
}
