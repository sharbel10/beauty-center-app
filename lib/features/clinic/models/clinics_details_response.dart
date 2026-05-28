import 'package:equatable/equatable.dart';

class ClinicDetailsResponse extends Equatable {
  const ClinicDetailsResponse({required this.success, required this.center});

  factory ClinicDetailsResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return ClinicDetailsResponse(
      success: json['success'] as bool? ?? true,
      center: ClinicCenterDetail.fromJson(
        data['center'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }

  final bool success;
  final ClinicCenterDetail center;

  @override
  List<Object?> get props => [success, center];
}

class ClinicCenterDetail extends Equatable {
  const ClinicCenterDetail({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.phone,
    required this.city,
    required this.area,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.logoPath,
    required this.coverPath,
    required this.averageRating,
    required this.ratingsCount,
    required this.isFeatured,
    this.distance,
    required this.email,
    required this.website,
    required this.bookingConfirmationType,
    required this.depositType,
    required this.depositValue,
    required this.cancellationPolicy,
    required this.images,
    required this.workingHours,
  });
  bool get hasCoordinates => latitude != null && longitude != null;

  factory ClinicCenterDetail.fromJson(Map<String, dynamic> json) {
    return ClinicCenterDetail(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      city: json['city'] as String? ?? '',
      area: json['area'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      logoPath: json['logo_path'] as String? ?? '',
      coverPath: json['cover_path'] as String? ?? '',
      averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0.0,
      ratingsCount: json['ratings_count'] as int? ?? 0,
      isFeatured: json['is_featured'] as bool? ?? false,
      distance: json['distance'],
      email: json['email'] as String? ?? '',
      website: json['website'] as String? ?? '',
      bookingConfirmationType:
          json['booking_confirmation_type'] as String? ?? '',
      depositType: json['deposit_type'] as String? ?? '',
      depositValue: json['deposit_value'] as int? ?? 0,
      cancellationPolicy: CancellationPolicy.fromJson(
        json['cancellation_policy'] as Map<String, dynamic>?,
      ),
      images: (json['images'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (dynamic item) =>
                CenterImage.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      workingHours: (json['working_hours'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (dynamic item) =>
                WorkingHour.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final int id;
  final String name;
  final String slug;
  final String description;
  final String phone;
  final String city;
  final String area;
  final String address;
  final double latitude;
  final double longitude;
  final String logoPath;
  final String coverPath;
  final double averageRating;
  final int ratingsCount;
  final bool isFeatured;
  final dynamic distance;
  final String email;
  final String website;
  final String bookingConfirmationType;
  final String depositType;
  final int depositValue;
  final CancellationPolicy cancellationPolicy;
  final List<CenterImage> images;
  final List<WorkingHour> workingHours;

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
    coverPath,
    averageRating,
    ratingsCount,
    isFeatured,
    distance,
    email,
    website,
    bookingConfirmationType,
    depositType,
    depositValue,
    cancellationPolicy,
    images,
    workingHours,
  ];
}

class CancellationPolicy extends Equatable {
  const CancellationPolicy({
    required this.type,
    required this.deadlineHours,
    required this.feePercentage,
  });

  factory CancellationPolicy.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const CancellationPolicy(
        type: '',
        deadlineHours: 0,
        feePercentage: 0,
      );
    }
    return CancellationPolicy(
      type: json['type'] as String? ?? '',
      deadlineHours: json['deadline_hours'] as int? ?? 0,
      feePercentage: json['fee_percentage'] as int? ?? 0,
    );
  }

  final String type;
  final int deadlineHours;
  final int feePercentage;

  @override
  List<Object?> get props => [type, deadlineHours, feePercentage];
}

class CenterImage extends Equatable {
  const CenterImage({
    required this.id,
    required this.imagePath,
    required this.caption,
  });

  factory CenterImage.fromJson(Map<String, dynamic> json) {
    return CenterImage(
      id: json['id'] as int? ?? 0,
      imagePath: json['image_path'] as String? ?? '',
      caption: json['caption'] as String? ?? '',
    );
  }

  final int id;
  final String imagePath;
  final String caption;

  @override
  List<Object?> get props => [id, imagePath, caption];
}

class WorkingHour extends Equatable {
  const WorkingHour({
    required this.dayOfWeek,
    required this.opensAt,
    required this.closesAt,
    required this.isClosed,
  });

  factory WorkingHour.fromJson(Map<String, dynamic> json) {
    return WorkingHour(
      dayOfWeek: json['day_of_week'] as int? ?? 0,
      opensAt: json['opens_at'] as String? ?? '',
      closesAt: json['closes_at'] as String? ?? '',
      isClosed: json['is_closed'] as bool? ?? false,
    );
  }

  final int dayOfWeek;
  final String opensAt;
  final String closesAt;
  final bool isClosed;

  @override
  List<Object?> get props => [dayOfWeek, opensAt, closesAt, isClosed];
}
