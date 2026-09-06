import 'package:beauty_center_app/core/payments/stripe_config.dart';
import 'package:beauty_center_app/core/payments/stripe_payment_service.dart';
import 'package:beauty_center_app/features/book_treatment/cubit/book_treatment_state.dart';
import 'package:beauty_center_app/features/book_treatment/models/available_slots_response.dart';
import 'package:beauty_center_app/features/book_treatment/models/book_treatment_args.dart';
import 'package:beauty_center_app/features/book_treatment/models/payment_methods_response.dart';
import 'package:beauty_center_app/features/book_treatment/models/payment_response.dart';
import 'package:beauty_center_app/features/book_treatment/repository/booking_repository.dart';
import 'package:beauty_center_app/features/bookings/models/appointment_model.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_employees_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_services_response.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

/// Stable message keys emitted by [BookTreatmentCubit] for known user-facing
/// copy. The view maps these through [AppLocalizations]; API error strings
/// are passed through unchanged.
abstract final class BookTreatmentMessageKeys {
  static const String pleaseChooseServiceDateTime =
      'pleaseChooseServiceDateTime';
  static const String appointmentBookedSuccessfully =
      'appointmentBookedSuccessfully';
  static const String paymentFailed = 'paymentFailed';
  static const String paymentVerificationPending = 'paymentVerificationPending';
  static const String stripeNotConfigured = 'stripeNotConfigured';
  static const String stripeGatewayUnavailable = 'stripeGatewayUnavailable';
  static const String paymentNoLongerAvailable = 'paymentNoLongerAvailable';
}

@injectable
class BookTreatmentCubit extends Cubit<BookTreatmentState> {
  BookTreatmentCubit(
    this._repository, {
    StripePaymentService? stripePaymentService,
  }) : _stripePaymentService = stripePaymentService ?? StripePaymentService(),
       super(const BookTreatmentState());

  final BookingRepository _repository;
  final StripePaymentService _stripePaymentService;

  /// Monotonic id used to discard responses of superseded slot requests
  /// (rapid date/specialist taps would otherwise race each other).
  int _slotsRequestId = 0;

  Future<void> initialize(BookTreatmentArgs args) async {
    emit(
      state.copyWith(
        status: BookTreatmentStatus.loading,
        currentStep: BookingSteps.service,
        args: args,
        selectedDate: _initialDate(),
        clearMessage: true,
        clearAppointment: true,
      ),
    );

    if (args.isPaymentContinuation) {
      await _initializePaymentContinuation(args);
      return;
    }

    final servicesResult = await _repository.getClinicServices(
      centerId: args.centerId,
    );
    if (isClosed) {
      return;
    }

    await servicesResult.fold(
      (failure) async {
        emit(
          state.copyWith(
            status: BookTreatmentStatus.failure,
            message: failure.message,
          ),
        );
      },
      (response) async {
        final List<ClinicServiceItem> services = response.services;
        final int? serviceId = _resolveInitialServiceId(
          services,
          args.initialServiceId,
        );
        emit(
          state.copyWith(
            status: BookTreatmentStatus.ready,
            services: services,
            selectedServiceId: serviceId,
            clearMessage: true,
          ),
        );
        await Future.wait(<Future<void>>[
          _loadPaymentMethods(args.centerId),
          if (serviceId != null) _loadEmployeesAndSlots(serviceId),
        ]);
      },
    );
  }

  Future<void> _initializePaymentContinuation(BookTreatmentArgs args) async {
    final appointmentResult = await _repository.getAppointment(
      appointmentId: args.paymentAppointmentId!,
    );
    if (isClosed) {
      return;
    }

    AppointmentModel? appointment;
    String? failureMessage;
    appointmentResult.fold(
      (failure) => failureMessage = failure.message,
      (response) => appointment = response.appointment,
    );

    if (appointment == null) {
      emit(
        state.copyWith(
          status: BookTreatmentStatus.failure,
          message: failureMessage,
        ),
      );
      return;
    }
    if (!appointment!.canRetryPayment) {
      emit(
        state.copyWith(
          status: BookTreatmentStatus.failure,
          message: BookTreatmentMessageKeys.paymentNoLongerAvailable,
        ),
      );
      return;
    }

    final paymentMethodsResult = await _repository.getPaymentMethods(
      centerId: args.centerId,
    );
    if (isClosed) {
      return;
    }

    PaymentMethodsResponse? paymentMethods;
    failureMessage = null;
    paymentMethodsResult.fold(
      (failure) => failureMessage = failure.message,
      (response) => paymentMethods = response,
    );
    if (paymentMethods == null) {
      emit(
        state.copyWith(
          status: BookTreatmentStatus.failure,
          message: failureMessage,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: BookTreatmentStatus.ready,
        currentStep: BookingSteps.payment,
        appointment: appointment,
        paymentMethods: paymentMethods,
        paymentStatus: BookingPaymentStatus.ready,
        clearMessage: true,
        clearPaymentMessage: true,
      ),
    );
  }

  void nextStep() {
    if (state.isLastStep) {
      return;
    }
    goToStep(state.currentStep + 1);
  }

  void previousStep() {
    if (state.currentStep <= BookingSteps.service) {
      return;
    }
    goToStep(state.currentStep - 1);
  }

  void goToStep(int step) {
    if (state.currentStep == BookingSteps.payment &&
        state.appointment != null &&
        step != BookingSteps.payment) {
      return;
    }
    final int target = step.clamp(BookingSteps.service, state.lastStep);
    if (target == state.currentStep) {
      return;
    }
    emit(state.copyWith(currentStep: target, clearMessage: true));
    if (target == BookingSteps.time &&
        (state.slotsStatus == SlotsStatus.initial ||
            state.slotsStatus == SlotsStatus.failure)) {
      loadSlots();
    }
  }

  Future<void> selectService(int serviceId) async {
    if (serviceId == state.selectedServiceId) {
      return;
    }
    emit(
      state.copyWith(
        selectedServiceId: serviceId,
        employees: const <ClinicEmployeeItem>[],
        slots: const <AvailableSlot>[],
        slotsStatus: SlotsStatus.initial,
        clearSelectedEmployee: true,
        clearSelectedSlot: true,
        clearMessage: true,
      ),
    );
    await _loadEmployeesAndSlots(serviceId);
  }

  Future<void> selectEmployee(int? employeeId) async {
    if (employeeId == state.selectedEmployeeId) {
      return;
    }
    emit(
      state.copyWith(
        selectedEmployeeId: employeeId,
        clearSelectedEmployee: employeeId == null,
        clearSelectedSlot: true,
        clearMessage: true,
      ),
    );
    await loadSlots();
  }

  Future<void> selectDate(DateTime date) async {
    final DateTime normalized = DateTime(date.year, date.month, date.day);
    if (normalized == state.selectedDate) {
      return;
    }
    emit(state.copyWith(selectedDate: normalized, clearMessage: true));
    await loadSlots();
  }

  Future<void> loadSlots() async {
    final BookTreatmentArgs? args = state.args;
    final int? serviceId = state.selectedServiceId;
    final DateTime? date = state.selectedDate;
    if (args == null || serviceId == null || date == null) {
      return;
    }

    final int requestId = ++_slotsRequestId;
    emit(
      state.copyWith(
        status: BookTreatmentStatus.ready,
        slotsStatus: SlotsStatus.loading,
        clearSlotsMessage: true,
      ),
    );
    final result = await _repository.getAvailableSlots(
      centerId: args.centerId,
      serviceId: serviceId,
      date: date,
      employeeId: state.selectedEmployeeId,
    );
    if (isClosed || requestId != _slotsRequestId) {
      return;
    }

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            slotsStatus: SlotsStatus.failure,
            slots: const <AvailableSlot>[],
            slotsMessage: failure.message,
            clearSelectedSlot: true,
          ),
        );
      },
      (response) {
        final String? retained = _retainSelection(response.slots);
        emit(
          state.copyWith(
            slotsStatus: SlotsStatus.ready,
            slots: response.slots,
            selectedSlotStartsAt: retained,
            clearSelectedSlot: retained == null,
            clearSlotsMessage: true,
          ),
        );
      },
    );
  }

  void selectSlot(String startsAt) {
    emit(state.copyWith(selectedSlotStartsAt: startsAt, clearMessage: true));
  }

  Future<void> _loadPaymentMethods(int centerId) async {
    final result = await _repository.getPaymentMethods(centerId: centerId);
    if (isClosed) {
      return;
    }
    result.fold(
      (_) {},
      (response) => emit(state.copyWith(paymentMethods: response)),
    );
  }

  Future<void> confirmBooking() async {
    final BookTreatmentArgs? args = state.args;
    final int? serviceId = state.selectedServiceId;
    final AvailableSlot? slot = state.selectedSlot;
    if (args == null || serviceId == null || slot == null) {
      emit(
        state.copyWith(
          status: BookTreatmentStatus.failure,
          message: BookTreatmentMessageKeys.pleaseChooseServiceDateTime,
        ),
      );
      return;
    }

    final int? employeeId =
        state.selectedEmployeeId ??
        (slot.availableEmployeeIds.isEmpty
            ? null
            : slot.availableEmployeeIds.first);

    emit(
      state.copyWith(
        status: BookTreatmentStatus.submitting,
        clearMessage: true,
      ),
    );

    final result = args.isRescheduling
        ? await _repository.rescheduleAppointment(
            appointmentId: args.appointmentId!,
            startsAt: slot.startsAt,
            employeeId: employeeId,
          )
        : await _repository.createAppointment(
            centerId: args.centerId,
            serviceId: serviceId,
            startsAt: slot.startsAt,
            employeeId: employeeId,
          );
    if (isClosed) {
      return;
    }

    result.fold(
      (failure) {
        emit(
          state.copyWith(
            status: BookTreatmentStatus.failure,
            message: failure.message,
          ),
        );
      },
      (response) {
        final bool needsDeposit = response.appointment.depositDue > 0;
        if (needsDeposit) {
          emit(
            state.copyWith(
              status: BookTreatmentStatus.ready,
              currentStep: BookingSteps.payment,
              appointment: response.appointment,
              paymentStatus: BookingPaymentStatus.ready,
              clearMessage: true,
              clearPaymentMessage: true,
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            status: BookTreatmentStatus.success,
            appointment: response.appointment,
            message: response.message.isEmpty
                ? BookTreatmentMessageKeys.appointmentBookedSuccessfully
                : response.message,
          ),
        );
      },
    );
  }

  Future<void> payDeposit() async {
    if (state.isPaymentBusy) {
      return;
    }
    final AppointmentModel? appointment = state.appointment;
    if (appointment == null || !appointment.canRetryPayment) {
      emit(
        state.copyWith(
          paymentStatus: BookingPaymentStatus.failure,
          paymentMessage: BookTreatmentMessageKeys.paymentNoLongerAvailable,
        ),
      );
      return;
    }
    if (!StripeConfig.hasPublishableKey) {
      emit(
        state.copyWith(
          paymentStatus: BookingPaymentStatus.failure,
          paymentMessage: BookTreatmentMessageKeys.stripeNotConfigured,
        ),
      );
      return;
    }

    final gateway = state.paymentMethods?.stripeGateway;
    if (gateway == null) {
      emit(
        state.copyWith(
          paymentStatus: BookingPaymentStatus.failure,
          paymentMessage: BookTreatmentMessageKeys.stripeGatewayUnavailable,
        ),
      );
      return;
    }

    if (state.paymentSheetCompleted && state.payment != null) {
      await _confirmPaymentAfterStripeSuccess(state.payment!);
      return;
    }

    PaymentAttempt? payment = state.payment;
    if (payment == null || !payment.isPending) {
      emit(
        state.copyWith(
          paymentStatus: BookingPaymentStatus.preparing,
          clearPayment: true,
          clearPaymentMessage: true,
        ),
      );
      final result = await _repository.initiateDepositPayment(
        appointmentId: appointment.id,
        paymentGatewayId: gateway.id,
      );
      if (isClosed) {
        return;
      }

      result.fold(
        (failure) => emit(
          state.copyWith(
            paymentStatus: BookingPaymentStatus.failure,
            paymentMessage: failure.message,
          ),
        ),
        (response) => payment = response.payment,
      );
      if (payment == null) {
        return;
      }
      emit(state.copyWith(payment: payment));
    }

    final String? clientSecret = payment!.clientSecret;
    if (clientSecret == null || clientSecret.isEmpty) {
      emit(
        state.copyWith(
          paymentStatus: BookingPaymentStatus.failure,
          paymentMessage: BookTreatmentMessageKeys.paymentFailed,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        paymentStatus: BookingPaymentStatus.presenting,
        clearPaymentMessage: true,
      ),
    );
    try {
      final StripeSheetResult sheetResult = await _stripePaymentService
          .presentPaymentSheet(clientSecret: clientSecret);
      if (isClosed) {
        return;
      }
      if (sheetResult == StripeSheetResult.cancelled) {
        emit(state.copyWith(paymentStatus: BookingPaymentStatus.ready));
        return;
      }

      emit(state.copyWith(paymentSheetCompleted: true));
      await _confirmPaymentAfterStripeSuccess(payment!);
    } catch (_) {
      if (!isClosed) {
        emit(
          state.copyWith(
            paymentStatus: BookingPaymentStatus.failure,
            paymentMessage: BookTreatmentMessageKeys.paymentFailed,
          ),
        );
      }
    }
  }

  /// POST /api/customer/payments/{paymentId}/confirm — only after Stripe
  /// Payment Sheet reports success. If the webhook already marked it paid,
  /// confirm rejects "not pending"; we then read GET and treat paid as success.
  Future<void> _confirmPaymentAfterStripeSuccess(PaymentAttempt payment) async {
    emit(
      state.copyWith(
        paymentStatus: BookingPaymentStatus.verifying,
        clearPaymentMessage: true,
      ),
    );

    final confirmResult = await _repository.confirmPayment(
      paymentId: payment.id,
    );
    if (isClosed) {
      return;
    }

    PaymentAttempt? confirmed;
    String? failureMessage;
    confirmResult.fold(
      (failure) => failureMessage = failure.message,
      (response) => confirmed = response.payment,
    );

    if (confirmed != null && confirmed!.isPaid) {
      _emitPaymentSuccess(confirmed!);
      return;
    }

    final statusResult = await _repository.getPayment(paymentId: payment.id);
    if (isClosed) {
      return;
    }

    PaymentAttempt? current;
    statusResult.fold(
      (failure) => failureMessage ??= failure.message,
      (response) => current = response.payment,
    );

    if (current != null) {
      emit(state.copyWith(payment: current));
      if (current!.isPaid) {
        _emitPaymentSuccess(current!);
        return;
      }
      if (current!.isFailed) {
        emit(
          state.copyWith(
            paymentStatus: BookingPaymentStatus.failure,
            paymentSheetCompleted: false,
            paymentMessage:
                current!.failureReason ?? BookTreatmentMessageKeys.paymentFailed,
          ),
        );
        return;
      }
    }

    emit(
      state.copyWith(
        paymentStatus: BookingPaymentStatus.ready,
        paymentMessage:
            failureMessage ??
            BookTreatmentMessageKeys.paymentVerificationPending,
      ),
    );
  }

  void _emitPaymentSuccess(PaymentAttempt payment) {
    emit(
      state.copyWith(
        status: BookTreatmentStatus.success,
        paymentStatus: BookingPaymentStatus.ready,
        payment: payment,
        message: BookTreatmentMessageKeys.appointmentBookedSuccessfully,
      ),
    );
  }

  /// Loads the specialists for the service and the slots for the current
  /// date in parallel. Specialist selection stays on "Any" (null); employee
  /// load failures are non-fatal and just leave the row empty.
  Future<void> _loadEmployeesAndSlots(int serviceId) async {
    final BookTreatmentArgs? args = state.args;
    if (args == null) {
      return;
    }

    final Future<void> slotsFuture = loadSlots();
    final Future<void> employeesFuture = _repository
        .getClinicEmployees(centerId: args.centerId, serviceId: serviceId)
        .then((result) {
          if (isClosed || serviceId != state.selectedServiceId) {
            return;
          }
          result.fold(
            (_) {},
            (response) => emit(state.copyWith(employees: response.employees)),
          );
        });

    await Future.wait(<Future<void>>[slotsFuture, employeesFuture]);
  }

  /// Keeps the user's chosen time highlighted across a slots reload when
  /// possible: an exact match first, otherwise the same time of day.
  String? _retainSelection(List<AvailableSlot> slots) {
    final String? previous = state.selectedSlotStartsAt;
    if (previous == null || slots.isEmpty) {
      return null;
    }
    for (final AvailableSlot slot in slots) {
      if (slot.startsAt == previous) {
        return slot.startsAt;
      }
    }
    final String previousTime = _timeOfDay(previous);
    if (previousTime.isEmpty) {
      return null;
    }
    for (final AvailableSlot slot in slots) {
      if (_timeOfDay(slot.startsAt) == previousTime) {
        return slot.startsAt;
      }
    }
    return null;
  }

  String _timeOfDay(String startsAt) {
    final DateTime? date = DateTime.tryParse(startsAt)?.toLocal();
    if (date == null) {
      return '';
    }
    return '${date.hour}:${date.minute}';
  }

  int? _resolveInitialServiceId(
    List<ClinicServiceItem> services,
    int? requestedServiceId,
  ) {
    if (services.isEmpty) {
      return null;
    }

    if (requestedServiceId != null &&
        services.any(
          (ClinicServiceItem service) => service.id == requestedServiceId,
        )) {
      return requestedServiceId;
    }

    return services.first.id;
  }

  DateTime _initialDate() {
    final DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    return DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
  }
}
