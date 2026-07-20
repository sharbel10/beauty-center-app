class BookTreatmentArgs {
  const BookTreatmentArgs({
    required this.centerId,
    this.initialServiceId,
    this.appointmentId,
  });

  final int centerId;
  final int? initialServiceId;
  final int? appointmentId;

  bool get isRescheduling => appointmentId != null;
}
