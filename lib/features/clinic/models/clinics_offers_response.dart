import 'package:equatable/equatable.dart';

class ClinicOffersResponse extends Equatable {
  const ClinicOffersResponse({required this.success, required this.offers});

  factory ClinicOffersResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return ClinicOffersResponse(
      success: json['success'] as bool? ?? true,
      offers: (data['offers'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (dynamic item) =>
                ClinicOffer.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final bool success;
  final List<ClinicOffer> offers;

  @override
  List<Object?> get props => [success, offers];
}

class ClinicOffer extends Equatable {
  const ClinicOffer({
    required this.id,
    required this.centerId,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.startsAt,
    required this.endsAt,
    this.center,
  });

  factory ClinicOffer.fromJson(Map<String, dynamic> json) {
    return ClinicOffer(
      id: json['id'] as int? ?? 0,
      centerId: json['center_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      discountType: json['discount_type'] as String? ?? '',
      discountValue: json['discount_value'] as int? ?? 0,
      startsAt: json['starts_at'] as String? ?? '',
      endsAt: json['ends_at'] as String? ?? '',
      center: json['center'],
    );
  }

  final int id;
  final int centerId;
  final String title;
  final String description;
  final String discountType;
  final int discountValue;
  final String startsAt;
  final String endsAt;
  final dynamic center;

  String get formattedDiscount {
    if (discountType == 'percentage') {
      return '$discountValue% OFF';
    }
    return '\$$discountValue OFF';
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
