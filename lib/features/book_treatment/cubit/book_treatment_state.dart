import 'package:beauty_center_app/features/book_treatment/models/available_slots_response.dart';
import 'package:beauty_center_app/features/book_treatment/models/book_treatment_args.dart';
import 'package:beauty_center_app/features/book_treatment/utils/booking_formats.dart';
import 'package:beauty_center_app/features/bookings/models/appointment_model.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_employees_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_services_response.dart';
import 'package:equatable/equatable.dart';

/// Screen-level status: initial load and booking submission.
enum BookTreatmentStatus {
  initial,
  loading,
  ready,
  submitting,
  success,
  failure,
}

/// Independent status for the slots request, so reloading times never
/// hides the rest of the screen and a slots error is not fatal.
enum SlotsStatus { initial, loading, ready, failure }

/// Wizard steps: 0 = service + specialist, 1 = date, 2 = time + confirm.
class BookingSteps {
  BookingSteps._();

  static const int service = 0;
  static const int date = 1;
  static const int time = 2;
  static const int count = 3;
}

class BookTreatmentState extends Equatable {
  const BookTreatmentState({
    this.status = BookTreatmentStatus.initial,
    this.slotsStatus = SlotsStatus.initial,
    this.currentStep = BookingSteps.service,
    this.args,
    this.services = const <ClinicServiceItem>[],
    this.employees = const <ClinicEmployeeItem>[],
    this.slots = const <AvailableSlot>[],
    this.selectedServiceId,
    this.selectedEmployeeId,
    this.selectedDate,
    this.selectedSlotStartsAt,
    this.appointment,
    this.message,
    this.slotsMessage,
  });

  final BookTreatmentStatus status;
  final SlotsStatus slotsStatus;
  final int currentStep;
  final BookTreatmentArgs? args;
  final List<ClinicServiceItem> services;
  final List<ClinicEmployeeItem> employees;
  final List<AvailableSlot> slots;
  final int? selectedServiceId;
  final int? selectedEmployeeId;
  final DateTime? selectedDate;
  final String? selectedSlotStartsAt;
  final AppointmentModel? appointment;
  final String? message;
  final String? slotsMessage;

  bool get isInitial => status == BookTreatmentStatus.initial;
  bool get isLoading => status == BookTreatmentStatus.loading;
  bool get isSubmitting => status == BookTreatmentStatus.submitting;
  bool get areSlotsLoading => slotsStatus == SlotsStatus.loading;
  bool get hasData => services.isNotEmpty;

  bool get isLastStep => currentStep == BookingSteps.time;

  /// Whether the current step's required selection is made.
  bool get canContinue {
    switch (currentStep) {
      case BookingSteps.service:
        return selectedServiceId != null;
      case BookingSteps.date:
        return selectedDate != null;
      default:
        return false;
    }
  }

  bool get canConfirm =>
      selectedServiceId != null &&
      selectedDate != null &&
      selectedSlot != null &&
      !isSubmitting;

  ClinicServiceItem? get selectedService {
    final int? serviceId = selectedServiceId;
    if (serviceId == null) {
      return null;
    }
    for (final ClinicServiceItem service in services) {
      if (service.id == serviceId) {
        return service;
      }
    }
    return null;
  }

  ClinicEmployeeItem? get selectedEmployee {
    final int? employeeId = selectedEmployeeId;
    if (employeeId == null) {
      return null;
    }
    for (final ClinicEmployeeItem employee in employees) {
      if (employee.id == employeeId) {
        return employee;
      }
    }
    return null;
  }

  /// The explicitly selected slot only; no silent fallback to the first
  /// slot, so the confirmed time always matches what the user tapped.
  AvailableSlot? get selectedSlot {
    final String? startsAt = selectedSlotStartsAt;
    if (startsAt == null) {
      return null;
    }
    for (final AvailableSlot slot in slots) {
      if (slot.startsAt == startsAt) {
        return slot;
      }
    }
    return null;
  }

  String get selectedDateLabel {
    final DateTime? date = selectedDate;
    return date == null ? '' : BookingFormats.date(date);
  }

  String get selectedTimeLabel => selectedSlot?.timeLabel ?? '';

  String get totalLabel {
    final ClinicServiceItem? service = selectedService;
    return BookingFormats.price(service?.finalPrice ?? 0);
  }

  BookTreatmentState copyWith({
    BookTreatmentStatus? status,
    SlotsStatus? slotsStatus,
    int? currentStep,
    BookTreatmentArgs? args,
    List<ClinicServiceItem>? services,
    List<ClinicEmployeeItem>? employees,
    List<AvailableSlot>? slots,
    int? selectedServiceId,
    int? selectedEmployeeId,
    DateTime? selectedDate,
    String? selectedSlotStartsAt,
    AppointmentModel? appointment,
    String? message,
    String? slotsMessage,
    bool clearSelectedEmployee = false,
    bool clearSelectedSlot = false,
    bool clearAppointment = false,
    bool clearMessage = false,
    bool clearSlotsMessage = false,
  }) {
    return BookTreatmentState(
      status: status ?? this.status,
      slotsStatus: slotsStatus ?? this.slotsStatus,
      currentStep: currentStep ?? this.currentStep,
      args: args ?? this.args,
      services: services ?? this.services,
      employees: employees ?? this.employees,
      slots: slots ?? this.slots,
      selectedServiceId: selectedServiceId ?? this.selectedServiceId,
      selectedEmployeeId: clearSelectedEmployee
          ? null
          : (selectedEmployeeId ?? this.selectedEmployeeId),
      selectedDate: selectedDate ?? this.selectedDate,
      selectedSlotStartsAt: clearSelectedSlot
          ? null
          : (selectedSlotStartsAt ?? this.selectedSlotStartsAt),
      appointment: clearAppointment ? null : (appointment ?? this.appointment),
      message: clearMessage ? null : (message ?? this.message),
      slotsMessage: clearSlotsMessage
          ? null
          : (slotsMessage ?? this.slotsMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    slotsStatus,
    currentStep,
    args,
    services,
    employees,
    slots,
    selectedServiceId,
    selectedEmployeeId,
    selectedDate,
    selectedSlotStartsAt,
    appointment,
    message,
    slotsMessage,
  ];
}
