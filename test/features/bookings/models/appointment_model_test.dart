import 'package:beauty_center_app/features/bookings/models/appointment_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppointmentModel pending payment', () {
    test('parses pending_payment and allows retry before the deadline', () {
      final DateTime deadline = DateTime.now().add(const Duration(minutes: 15));
      final AppointmentModel appointment =
          AppointmentModel.fromJson(<String, dynamic>{
            'id': 7,
            'status': 'pending_payment',
            'deposit_due': 25,
            'payment_expires_at': deadline.toUtc().toIso8601String(),
          });

      expect(appointment.status, AppointmentStatus.pendingPayment);
      expect(appointment.canRetryPayment, isTrue);
      expect(appointment.paymentExpiresAt, isNotNull);
    });

    test('does not allow retry after the payment deadline', () {
      final AppointmentModel appointment =
          AppointmentModel.fromJson(<String, dynamic>{
            'id': 8,
            'status': 'pending_payment',
            'deposit_due': 25,
            'payment_expires_at': DateTime.now()
                .subtract(const Duration(minutes: 1))
                .toUtc()
                .toIso8601String(),
          });

      expect(appointment.canRetryPayment, isFalse);
      expect(appointment.isPaymentExpired, isTrue);
    });
  });

  group('AppointmentModel.canReschedule', () {
    test('is false for an appointment whose start time has passed', () {
      final AppointmentModel appointment = _appointment(
        startsAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      expect(appointment.canReschedule, isFalse);
    });

    test('is true for an upcoming pending appointment', () {
      final AppointmentModel appointment = _appointment(
        startsAt: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(appointment.canReschedule, isTrue);
    });
  });
}

AppointmentModel _appointment({required DateTime startsAt}) {
  return AppointmentModel(
    id: 1,
    clinicName: 'Clinic',
    serviceName: 'Service',
    date: 'Date',
    time: 'Time',
    status: AppointmentStatus.pending,
    statusLabel: 'Pending',
    imageUrl: '',
    startsAt: startsAt,
    endsAt: startsAt.add(const Duration(hours: 1)),
    total: 100,
    depositRequired: 20,
    depositPaid: 0,
    depositDue: 20,
    paymentStatus: 'unpaid',
    centerId: 1,
    serviceId: 1,
  );
}
