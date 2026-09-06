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
    this.serviceId,
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
      serviceId: _extractServiceId(json),
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
  final int? serviceId;
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

  static int? _extractServiceId(Map<String, dynamic> json) {
    for (final String key in const <String>[
      'service_id',
      'center_service_id',
      'clinic_service_id',
    ]) {
      final int? id = _toInt(json[key]);
      if (id != null) {
        return id;
      }
    }

    for (final String key in const <String>[
      'service',
      'center_service',
      'clinic_service',
    ]) {
      final dynamic value = json[key];
      if (value is Map<String, dynamic>) {
        final int? id = _toInt(value['id']);
        if (id != null) {
          return id;
        }
      }
    }

    for (final String key in const <String>[
      'services',
      'center_services',
      'clinic_services',
    ]) {
      final dynamic value = json[key];
      if (value is List && value.isNotEmpty) {
        final dynamic first = value.first;
        if (first is Map<String, dynamic>) {
          final int? id = _toInt(first['id']);
          if (id != null) {
            return id;
          }
        }
      }
    }

    return null;
  }

  static int? _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '');
  }

  @override
  List<Object?> get props => [
    id,
    centerId,
    title,
    description,
    discountType,
    discountValue,
    serviceId,
    startsAt,
    endsAt,
    center,
  ];
}
