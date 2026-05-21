import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/features/home/models/clinic_center.dart';

class HomeClinicUiModel {
  const HomeClinicUiModel({
    required this.imageUrl,
    required this.name,
    required this.location,
    required this.distance,
    required this.tags,
    required this.rating,
    required this.ratingsCount,
    required this.isFeatured,
    this.description,
    this.phone,
    this.city,
    this.area,
    this.address,
    this.latitude,
    this.longitude,
    this.priceLabel,
  });

  factory HomeClinicUiModel.fromCenter(ClinicCenter center) {
    return HomeClinicUiModel(
      imageUrl: ApiEndpoints.mediaUrl(center.coverPath),
      name: center.name,
      location: center.locationLabel,
      distance: center.distance != null
          ? '${center.distance!.toStringAsFixed(1)} km'
          : '—',
      tags: const <String>[],
      rating: center.averageRating,
      ratingsCount: center.ratingsCount,
      isFeatured: center.isFeatured,
      description: center.description,
      phone: center.phone,
      city: center.city,
      area: center.area,
      address: center.address,
      latitude: center.latitude,
      longitude: center.longitude,
      priceLabel: null,
    );
  }

  final String imageUrl;
  final String name;
  final String location;
  final String distance;
  final List<String> tags;
  final double rating;
  final int ratingsCount;
  final bool isFeatured;
  final String? description;
  final String? phone;
  final String? city;
  final String? area;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? priceLabel;

  bool get hasCoordinates => latitude != null && longitude != null;

  List<String> get displayTags => tags.take(2).toList();

  String get reviewsLabel =>
      ratingsCount == 0 ? 'No reviews yet' : '$ratingsCount reviews';

  String? get cityAreaLabel {
    final List<String> parts = <String>[
      if (city != null && city!.isNotEmpty) city!,
      if (area != null && area!.isNotEmpty) area!,
    ];
    if (parts.isEmpty) {
      return null;
    }
    return parts.join(' · ');
  }
}
