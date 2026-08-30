import 'package:beauty_center_app/features/explore/models/pagination_meta.dart';
import 'package:beauty_center_app/features/home/models/clinic_center.dart';
import 'package:equatable/equatable.dart';

class FavoritesResponse extends Equatable {
  const FavoritesResponse({
    required this.success,
    required this.centers,
    required this.services,
    required this.centersMeta,
    required this.servicesMeta,
  });

  factory FavoritesResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return FavoritesResponse(
      success: json['success'] as bool? ?? true,
      centers: (data['centers'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (dynamic item) =>
                FavoriteCenter.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      services: (data['services'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (dynamic item) =>
                FavoriteService.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      centersMeta: PaginationMeta.fromJson(
        data['centers_meta'] as Map<String, dynamic>?,
      ),
      servicesMeta: PaginationMeta.fromJson(
        data['services_meta'] as Map<String, dynamic>?,
      ),
    );
  }

  final bool success;
  final List<FavoriteCenter> centers;
  final List<FavoriteService> services;
  final PaginationMeta centersMeta;
  final PaginationMeta servicesMeta;

  @override
  List<Object?> get props => [
    success,
    centers,
    services,
    centersMeta,
    servicesMeta,
  ];
}

class FavoriteCenter extends Equatable {
  const FavoriteCenter({
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
    required this.isFavorite,
    this.bookingConfirmationType,
    this.bookingConfirmationLabel,
    this.distanceKm,
    this.priceRange,
  });

  factory FavoriteCenter.fromJson(Map<String, dynamic> json) {
    return FavoriteCenter(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
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
      bookingConfirmationType: json['booking_confirmation_type'] as String?,
      bookingConfirmationLabel: json['booking_confirmation_label'] as String?,
      distanceKm: _toDouble(json['distance_km']),
      priceRange: json['price_range'] as String?,
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
  final String? bookingConfirmationType;
  final String? bookingConfirmationLabel;
  final double? distanceKm;
  final String? priceRange;

  String get locationLabel {
    if (area != null && area!.isNotEmpty) {
      return area!;
    }
    return city ?? '';
  }

  String get displayLogoUrl => logoUrl?.trim() ?? '';
  String get displayCoverUrl => coverUrl?.trim() ?? '';

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

  bool get hasCoordinates => latitude != null && longitude != null;

  FavoriteCenter copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? phone,
    String? city,
    String? area,
    String? address,
    double? latitude,
    double? longitude,
    String? logoPath,
    String? logoUrl,
    String? coverPath,
    String? coverUrl,
    double? averageRating,
    int? ratingsCount,
    bool? isFeatured,
    bool? isFavorite,
    String? bookingConfirmationType,
    String? bookingConfirmationLabel,
    double? distanceKm,
    String? priceRange,
  }) {
    return FavoriteCenter(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      area: area ?? this.area,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      logoPath: logoPath ?? this.logoPath,
      logoUrl: logoUrl ?? this.logoUrl,
      coverPath: coverPath ?? this.coverPath,
      coverUrl: coverUrl ?? this.coverUrl,
      averageRating: averageRating ?? this.averageRating,
      ratingsCount: ratingsCount ?? this.ratingsCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isFavorite: isFavorite ?? this.isFavorite,
      bookingConfirmationType:
          bookingConfirmationType ?? this.bookingConfirmationType,
      bookingConfirmationLabel:
          bookingConfirmationLabel ?? this.bookingConfirmationLabel,
      distanceKm: distanceKm ?? this.distanceKm,
      priceRange: priceRange ?? this.priceRange,
    );
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
    bookingConfirmationType,
    bookingConfirmationLabel,
    distanceKm,
    priceRange,
  ];
}

class FavoriteService extends Equatable {
  const FavoriteService({
    required this.id,
    required this.centerId,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.salePrice,
    required this.finalPrice,
    required this.hasDiscount,
    required this.durationMinutes,
    required this.preparationMinutes,
    this.imagePath,
    this.imageUrl,
    required this.requiresEmployee,
    required this.isFeatured,
    required this.isFavorite,
    required this.category,
    this.center,
  });

  factory FavoriteService.fromJson(Map<String, dynamic> json) {
    return FavoriteService(
      id: json['id'] as int? ?? 0,
      centerId: json['center_id'] as int? ?? 0,
      categoryId: json['category_id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      price: json['price'] as int? ?? 0,
      salePrice: json['sale_price'] as int?,
      finalPrice: json['final_price'] as int? ?? 0,
      hasDiscount: json['has_discount'] as bool? ?? false,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      preparationMinutes: json['preparation_minutes'] as int? ?? 0,
      imagePath: json['image_path'] as String?,
      imageUrl: json['image_url'] as String?,
      requiresEmployee: json['requires_employee'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      isFavorite: json['is_favorite'] as bool? ?? false,
      category: ServiceCategory.fromJson(
        json['category'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      center: json['center'] != null
          ? FavoriteCenter.fromJson(json['center'] as Map<String, dynamic>)
          : null,
    );
  }

  final int id;
  final int centerId;
  final int categoryId;
  final String name;
  final String slug;
  final String? description;
  final int price;
  final int? salePrice;
  final int finalPrice;
  final bool hasDiscount;
  final int durationMinutes;
  final int preparationMinutes;
  final String? imagePath;
  final String? imageUrl;
  final bool requiresEmployee;
  final bool isFeatured;
  final bool isFavorite;
  final ServiceCategory category;
  final FavoriteCenter? center;

  String get displayImageUrl => imageUrl?.trim() ?? '';

  FavoriteService copyWith({
    int? id,
    int? centerId,
    int? categoryId,
    String? name,
    String? slug,
    String? description,
    int? price,
    int? salePrice,
    int? finalPrice,
    bool? hasDiscount,
    int? durationMinutes,
    int? preparationMinutes,
    String? imagePath,
    String? imageUrl,
    bool? requiresEmployee,
    bool? isFeatured,
    bool? isFavorite,
    ServiceCategory? category,
    FavoriteCenter? center,
  }) {
    return FavoriteService(
      id: id ?? this.id,
      centerId: centerId ?? this.centerId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      finalPrice: finalPrice ?? this.finalPrice,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      preparationMinutes: preparationMinutes ?? this.preparationMinutes,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      requiresEmployee: requiresEmployee ?? this.requiresEmployee,
      isFeatured: isFeatured ?? this.isFeatured,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category ?? this.category,
      center: center ?? this.center,
    );
  }

  @override
  List<Object?> get props => [
    id,
    centerId,
    categoryId,
    name,
    slug,
    description,
    price,
    salePrice,
    finalPrice,
    hasDiscount,
    durationMinutes,
    preparationMinutes,
    imagePath,
    imageUrl,
    requiresEmployee,
    isFeatured,
    isFavorite,
    category,
    center,
  ];
}

class ServiceCategory extends Equatable {
  const ServiceCategory({
    required this.id,
    this.parentId,
    required this.name,
    required this.slug,
    this.description,
    required this.iconPath,
    this.iconUrl,
    this.servicesCount,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as int? ?? 0,
      parentId: json['parent_id'] as int?,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String?,
      iconPath: json['icon_path'] as String?,
      iconUrl: json['icon_url'] as String?,
      servicesCount: json['services_count'] as int?,
    );
  }

  final int id;
  final int? parentId;
  final String name;
  final String slug;
  final String? description;
  final String? iconPath;
  final String? iconUrl;
  final int? servicesCount;

  String get displayIconUrl => iconUrl?.trim() ?? '';

  @override
  List<Object?> get props => [
    id,
    parentId,
    name,
    slug,
    description,
    iconPath,
    iconUrl,
    servicesCount,
  ];
}
