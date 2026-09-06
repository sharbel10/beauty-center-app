import 'package:equatable/equatable.dart';

class AiRecommendationsResponse extends Equatable {
  const AiRecommendationsResponse({
    required this.services,
    required this.centers,
  });

  factory AiRecommendationsResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = _asMap(json['data']);
    return AiRecommendationsResponse(
      services: _asList(data['services'])
          .map((dynamic item) => AiRecommendedService.fromJson(_asMap(item)))
          .toList(growable: false),
      centers: _asList(data['centers'])
          .map((dynamic item) => AiRecommendedCenter.fromJson(_asMap(item)))
          .toList(growable: false),
    );
  }

  final List<AiRecommendedService> services;
  final List<AiRecommendedCenter> centers;

  bool get isEmpty => services.isEmpty && centers.isEmpty;

  @override
  List<Object?> get props => <Object?>[services, centers];
}

class AiRecommendedService extends Equatable {
  const AiRecommendedService({
    required this.id,
    required this.name,
    required this.description,
    required this.finalPrice,
    required this.imageUrl,
    required this.matchScore,
    required this.categoryName,
    required this.centerId,
    required this.centerName,
    required this.durationMinutes,
  });

  factory AiRecommendedService.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> category = _asMap(json['category']);
    final Map<String, dynamic> center = _asMap(json['center']);
    return AiRecommendedService(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      description: _asString(json['description']),
      finalPrice: _asDouble(json['final_price']),
      imageUrl: _asString(json['image_url']),
      matchScore: _asDouble(json['match_score']),
      categoryName: _asString(category['name']),
      centerId: _asNullableInt(center['id'] ?? json['center_id']),
      centerName: _asString(center['name']),
      durationMinutes: _asInt(json['duration_minutes']),
    );
  }

  final int id;
  final String name;
  final String description;
  final double finalPrice;
  final String imageUrl;
  final double matchScore;
  final String categoryName;
  final int? centerId;
  final String centerName;
  final int durationMinutes;

  int get matchPercentage => (matchScore.clamp(0, 1) * 100).round();

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    description,
    finalPrice,
    imageUrl,
    matchScore,
    categoryName,
    centerId,
    centerName,
    durationMinutes,
  ];
}

class AiRecommendedCenter extends Equatable {
  const AiRecommendedCenter({
    required this.id,
    required this.name,
    required this.location,
    required this.imageUrl,
    required this.matchScore,
  });

  factory AiRecommendedCenter.fromJson(Map<String, dynamic> json) {
    return AiRecommendedCenter(
      id: _asInt(json['id']),
      name: _asString(json['name']),
      location: _firstString(<dynamic>[
        json['area'],
        json['city'],
        json['address'],
      ]),
      imageUrl: _firstString(<dynamic>[
        json['cover_url'],
        json['logo_url'],
        json['image_url'],
      ]),
      matchScore: _asDouble(json['match_score']),
    );
  }

  final int id;
  final String name;
  final String location;
  final String imageUrl;
  final double matchScore;

  int? get matchPercentage =>
      matchScore > 0 ? (matchScore.clamp(0, 1) * 100).round() : null;

  @override
  List<Object?> get props => <Object?>[
    id,
    name,
    location,
    imageUrl,
    matchScore,
  ];
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) => value is List ? value : <dynamic>[];

String _asString(dynamic value) => value?.toString().trim() ?? '';

String _firstString(List<dynamic> values) {
  for (final dynamic value in values) {
    final String text = _asString(value);
    if (text.isNotEmpty) return text;
  }
  return '';
}

int _asInt(dynamic value) => _asNullableInt(value) ?? 0;

int? _asNullableInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

double _asDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
