import 'package:equatable/equatable.dart';

class ClinicCenter extends Equatable {
  const ClinicCenter({
    required this.id,
    required this.name,
    required this.slug,
    this.description,
    this.phone,
    this.city,
    this.area,
    this.address,
    this.latitude,
    this.longitude,
    this.logoPath,
    this.logoUrl,
    this.coverPath,
    this.coverUrl,
    required this.averageRating,
    required this.ratingsCount,
    required this.isFeatured,
    this.isFavorite = false,
    this.distance,
  });

  factory ClinicCenter.fromJson(Map<String, dynamic> json) {
    return ClinicCenter(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      city: json['city'] as String?,
      area: json['area'] as String?,
      address: json['address'] as String?,
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      logoPath: json['logo_path'] as String?,
      logoUrl: json['logo_url'] as String?,
      coverPath: json['cover_path'] as String?,
      coverUrl: json['cover_url'] as String?,
      averageRating: _toDouble(json['average_rating']) ?? 0,
      ratingsCount: json['ratings_count'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      isFavorite: json['is_favorite'] as bool? ?? false,
      distance: _toDouble(json['distance_km'] ?? json['distance']),
    );
  }

  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? phone;
  final String? city;
  final String? area;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? logoPath;
  final String? logoUrl;
  final String? coverPath;
  final String? coverUrl;
  final double averageRating;
  final int ratingsCount;
  final bool isFeatured;
  final bool isFavorite;
  final double? distance;

  String get locationLabel {
    if (area != null && area!.isNotEmpty) {
      return area!;
    }
    return city ?? '';
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
    name,
    slug,
    description,
    phone,
    city,
    area,
    address,
    latitude,
    longitude,
    logoPath,
    logoUrl,
    coverPath,
    coverUrl,
    averageRating,
    ratingsCount,
    isFeatured,
    isFavorite,
    distance,
  ];
}
