import 'package:beauty_center_app/features/home/models/clinic_center.dart';
import 'package:equatable/equatable.dart';

class Offer extends Equatable {
  const Offer({
    required this.id,
    required this.centerId,
    required this.title,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.startsAt,
    this.endsAt,
    this.center,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      id: json['id'] as int,
      centerId: json['center_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      discountType: json['discount_type'] as String,
      discountValue: _toDouble(json['discount_value']) ?? 0,
      startsAt: json['starts_at'] as String?,
      endsAt: json['ends_at'] as String?,
      center: json['center'] != null
          ? ClinicCenter.fromJson(json['center'] as Map<String, dynamic>)
          : null,
    );
  }

  final int id;
  final int centerId;
  final String title;
  final String? description;
  final String discountType;
  final double discountValue;
  final String? startsAt;
  final String? endsAt;
  final ClinicCenter? center;

  String get discountLabel {
    if (discountType == 'percentage') {
      return '${discountValue.toStringAsFixed(discountValue.truncateToDouble() == discountValue ? 0 : 1)}% OFF';
    }
    return '${discountValue.toStringAsFixed(0)} OFF';
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  @override
  List<Object?> get props => [
    id,
    centerId,
    title,
    description,
    discountType,
    discountValue,
    startsAt,
    endsAt,
    center,
  ];
}
