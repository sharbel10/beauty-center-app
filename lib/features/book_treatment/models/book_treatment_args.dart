class BookTreatmentArgs {
  const BookTreatmentArgs({
    required this.centerId,
    this.initialServiceId,
    this.appointmentId,
    this.paymentAppointmentId,
  });

  final int centerId;
  final int? initialServiceId;
  final int? appointmentId;
  final int? paymentAppointmentId;

  bool get isRescheduling => appointmentId != null;
  bool get isPaymentContinuation => paymentAppointmentId != null;
}
