import 'package:beauty_center_app/features/book_treatment/cubit/book_treatment_state.dart';
import 'package:beauty_center_app/features/book_treatment/models/book_treatment_args.dart';
import 'package:beauty_center_app/features/book_treatment/models/payment_methods_response.dart';
import 'package:beauty_center_app/features/bookings/models/appointment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BookTreatmentState.requiresDeposit', () {
    test('includes payment while rescheduling a clinic that requires a deposit', () {
      final BookTreatmentState state = BookTreatmentState(
        args: const BookTreatmentArgs(centerId: 1, appointmentId: 9),
        paymentMethods: _paymentMethods(depositRequired: true),
      );

      expect(state.isRescheduling, isTrue);
      expect(state.requiresDeposit, isTrue);
      expect(state.lastStep, BookingSteps.payment);
    });

    test('includes payment after a reschedule that still has deposit due', () {
      final BookTreatmentState state = BookTreatmentState(
        args: const BookTreatmentArgs(centerId: 1, appointmentId: 9),
        appointment: _appointment(depositDue: 25),
        currentStep: BookingSteps.payment,
      );

      expect(state.requiresDeposit, isTrue);
      expect(state.lastStep, BookingSteps.payment);
      expect(state.isLastStep, isTrue);
    });

    test('stops at the time step when rescheduling without a deposit', () {
      final BookTreatmentState state = BookTreatmentState(
        args: const BookTreatmentArgs(centerId: 1, appointmentId: 9),
        paymentMethods: _paymentMethods(depositRequired: false),
      );

      expect(state.requiresDeposit, isFalse);
      expect(state.lastStep, BookingSteps.time);
    });
  });
}

PaymentMethodsResponse _paymentMethods({required bool depositRequired}) {
  return PaymentMethodsResponse(
    currency: 'USD',
    deposit: DepositPolicy(
      type: depositRequired ? 'fixed' : 'none',
      value: depositRequired ? 25 : 0,
    ),
    methods: const <PaymentGatewayOption>[],
  );
}

AppointmentModel _appointment({required double depositDue}) {
  return AppointmentModel(
    id: 9,
    clinicName: 'Clinic',
    serviceName: 'Service',
    date: 'Date',
    time: 'Time',
    status: AppointmentStatus.pendingPayment,
    statusLabel: 'Pending payment',
    imageUrl: '',
    startsAt: DateTime.now().add(const Duration(days: 1)),
    endsAt: DateTime.now().add(const Duration(days: 1, hours: 1)),
    total: 100,
    depositRequired: depositDue,
    depositPaid: 0,
    depositDue: depositDue,
    paymentStatus: 'unpaid',
    centerId: 1,
    serviceId: 1,
  );
}
