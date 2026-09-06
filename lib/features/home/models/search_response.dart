import 'package:beauty_center_app/features/home/models/category.dart';
import 'package:equatable/equatable.dart';

class SearchResponse extends Equatable {
  const SearchResponse({required this.success, this.data});

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      success: json['success'] as bool? ?? true,
      data: json['data'] != null
          ? SearchData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  final bool success;
  final SearchData? data;

  @override
  List<Object?> get props => [success, data];
}

class SearchData extends Equatable {
  const SearchData({
    required this.query,
    required this.type,
    this.centers = const [],
    this.services = const [],
    this.categories = const [],
    this.offers = const [],
    this.total = 0,
  });

  factory SearchData.fromJson(Map<String, dynamic> json) {
    return SearchData(
      query: json['query'] as String? ?? '',
      type: json['type'] as String? ?? 'all',
      centers:
          (json['centers'] as List<dynamic>?)
              ?.map(
                (dynamic e) =>
                    CenterSearchResult.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      services:
          (json['services'] as List<dynamic>?)
              ?.map(
                (dynamic e) =>
                    ServiceSearchResult.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      categories:
          (json['categories'] as List<dynamic>?)
              ?.map((dynamic e) => Category.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      offers:
          (json['offers'] as List<dynamic>?)
              ?.map(
                (dynamic e) =>
                    OfferSearchResult.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      total: json['total'] as int? ?? 0,
    );
  }

  final String query;
  final String type;
  final List<CenterSearchResult> centers;
  final List<ServiceSearchResult> services;
  final List<Category> categories;
  final List<OfferSearchResult> offers;
  final int total;

  bool get hasResults =>
      centers.isNotEmpty ||
      services.isNotEmpty ||
      categories.isNotEmpty ||
      offers.isNotEmpty;

  SearchData copyWith({
    String? query,
    String? type,
    List<CenterSearchResult>? centers,
    List<ServiceSearchResult>? services,
    List<Category>? categories,
    List<OfferSearchResult>? offers,
    int? total,
  }) {
    return SearchData(
      query: query ?? this.query,
      type: type ?? this.type,
      centers: centers ?? this.centers,
      services: services ?? this.services,
      categories: categories ?? this.categories,
      offers: offers ?? this.offers,
      total: total ?? this.total,
    );
  }

  @override
  List<Object?> get props => [
    query,
    type,
    centers,
    services,
    categories,
    offers,
    total,
  ];
}

class CenterSearchResult extends Equatable {
  const CenterSearchResult({
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
    this.bookingConfirmationType,
    this.bookingConfirmationLabel,
    this.distanceKm,
    this.priceRange,
  });

  factory CenterSearchResult.fromJson(Map<String, dynamic> json) {
    return CenterSearchResult(
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
      bookingConfirmationType: json['booking_confirmation_type'] as String?,
      bookingConfirmationLabel: json['booking_confirmation_label'] as String?,
      distanceKm: _toDouble(json['distance_km']),
      priceRange: json['price_range'] != null
          ? PriceRange.fromJson(json['price_range'] as Map<String, dynamic>)
          : null,
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
  final PriceRange? priceRange;

  String get locationLabel {
    if (area != null && area!.isNotEmpty) {
      return area!;
    }
    return city ?? '';
  }

  CenterSearchResult copyWith({bool? isFavorite}) {
    return CenterSearchResult(
      id: id,
      name: name,
      slug: slug,
      description: description,
      phone: phone,
      city: city,
      area: area,
      address: address,
      latitude: latitude,
      longitude: longitude,
      logoPath: logoPath,
      logoUrl: logoUrl,
      coverPath: coverPath,
      coverUrl: coverUrl,
      averageRating: averageRating,
      ratingsCount: ratingsCount,
      isFeatured: isFeatured,
      isFavorite: isFavorite ?? this.isFavorite,
      bookingConfirmationType: bookingConfirmationType,
      bookingConfirmationLabel: bookingConfirmationLabel,
      distanceKm: distanceKm,
      priceRange: priceRange,
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

class PriceRange extends Equatable {
  const PriceRange({required this.min, required this.max});

  factory PriceRange.fromJson(Map<String, dynamic> json) {
    return PriceRange(
      min: _toDouble(json['min']) ?? 0,
      max: _toDouble(json['max']) ?? 0,
    );
  }

  final double min;
  final double max;

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
  List<Object?> get props => [min, max];
}

class ServiceSearchResult extends Equatable {
  const ServiceSearchResult({
    required this.id,
    required this.centerId,
    required this.categoryId,
    required this.name,
    required this.slug,
    this.description,
    required this.price,
    this.salePrice,
    required this.finalPrice,
    this.hasDiscount = false,
    required this.durationMinutes,
    this.preparationMinutes,
    this.imagePath,
    this.imageUrl,
    this.requiresEmployee = false,
    this.isFeatured = false,
    this.isFavorite = false,
    this.category,
    this.center,
  });

  factory ServiceSearchResult.fromJson(Map<String, dynamic> json) {
    return ServiceSearchResult(
      id: json['id'] as int,
      centerId: json['center_id'] as int,
      categoryId: json['category_id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      price: _toDouble(json['price']) ?? 0,
      salePrice: _toDouble(json['sale_price']),
      finalPrice: _toDouble(json['final_price']) ?? 0,
      hasDiscount: json['has_discount'] as bool? ?? false,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      preparationMinutes: json['preparation_minutes'] as int?,
      imagePath: json['image_path'] as String?,
      imageUrl: json['image_url'] as String?,
      requiresEmployee: json['requires_employee'] as bool? ?? false,
      isFeatured: json['is_featured'] as bool? ?? false,
      isFavorite: json['is_favorite'] as bool? ?? false,
      category: json['category'] != null
          ? Category.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      center: json['center'] != null
          ? CenterSearchResult.fromJson(json['center'] as Map<String, dynamic>)
          : null,
    );
  }

  final int id;
  final int centerId;
  final int categoryId;
  final String name;
  final String slug;
  final String? description;
  final double price;
  final double? salePrice;
  final double finalPrice;
  final bool hasDiscount;
  final int durationMinutes;
  final int? preparationMinutes;
  final String? imagePath;
  final String? imageUrl;
  final bool requiresEmployee;
  final bool isFeatured;
  final bool isFavorite;
  final Category? category;
  final CenterSearchResult? center;

  ServiceSearchResult copyWith({bool? isFavorite, CenterSearchResult? center}) {
    return ServiceSearchResult(
      id: id,
      centerId: centerId,
      categoryId: categoryId,
      name: name,
      slug: slug,
      description: description,
      price: price,
      salePrice: salePrice,
      finalPrice: finalPrice,
      hasDiscount: hasDiscount,
      durationMinutes: durationMinutes,
      preparationMinutes: preparationMinutes,
      imagePath: imagePath,
      imageUrl: imageUrl,
      requiresEmployee: requiresEmployee,
      isFeatured: isFeatured,
      isFavorite: isFavorite ?? this.isFavorite,
      category: category,
      center: center ?? this.center,
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

class OfferSearchResult extends Equatable {
  const OfferSearchResult({
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

  factory OfferSearchResult.fromJson(Map<String, dynamic> json) {
    return OfferSearchResult(
      id: json['id'] as int,
      centerId: json['center_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      discountType: json['discount_type'] as String,
      discountValue: _toDouble(json['discount_value']) ?? 0,
      startsAt: json['starts_at'] as String?,
      endsAt: json['ends_at'] as String?,
      center: json['center'] != null
          ? CenterSearchResult.fromJson(json['center'] as Map<String, dynamic>)
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
  final CenterSearchResult? center;

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
