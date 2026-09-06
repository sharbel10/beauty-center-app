import 'package:equatable/equatable.dart';

const List<String> centerGovernorates = <String>[
  'damascus',
  'rif_dimashq',
  'aleppo',
  'homs',
  'hama',
  'lattakia',
  'idlib',
  'al_hasakah',
  'deir_ez_zor',
  'raqqa',
  'daraa',
  'as_suwayda',
  'quneitra',
  'tartus',
];

const List<String> centerSortOptions = <String>[
  'rating',
  'nearest',
  'name',
  'latest',
  'price_asc',
  'price_desc',
];

class CenterFilters extends Equatable {
  static const int defaultPerPage = 15;

  const CenterFilters({
    this.categoryId,
    this.city,
    this.area,
    this.governorate,
    this.isFeatured,
    this.requiresDeposit,
    this.minRating,
    this.minPrice,
    this.maxPrice,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.sortBy = 'rating',
  });

  final int? categoryId;
  final String? city;
  final String? area;
  final String? governorate;
  final bool? isFeatured;
  final bool? requiresDeposit;
  final double? minRating;
  final double? minPrice;
  final double? maxPrice;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final String sortBy;

  bool get hasCoordinates => latitude != null && longitude != null;
  bool get isActive =>
      categoryId != null ||
      _notBlank(city) ||
      _notBlank(area) ||
      governorate != null ||
      isFeatured != null ||
      requiresDeposit != null ||
      minRating != null ||
      minPrice != null ||
      maxPrice != null ||
      hasCoordinates ||
      radiusKm != null ||
      sortBy != 'rating';

  Map<String, dynamic> toQueryParameters({
    required String query,
    required int page,
  }) {
    final String normalizedQuery = query.trim();
    return <String, dynamic>{
      if (normalizedQuery.isNotEmpty) 'q': normalizedQuery,
      if (categoryId != null) 'category_id': categoryId,
      if (_notBlank(city)) 'city': city!.trim(),
      if (_notBlank(area)) 'area': area!.trim(),
      if (governorate != null) 'governorate': governorate,
      if (isFeatured != null) 'is_featured': isFeatured,
      if (requiresDeposit != null) 'requires_deposit': requiresDeposit,
      if (minRating != null) 'min_rating': minRating,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (hasCoordinates) ...<String, dynamic>{
        'latitude': latitude,
        'longitude': longitude,
        if (radiusKm != null) 'radius_km': radiusKm,
      },
      'sort_by': sortBy,
      'page': page,
      'per_page': defaultPerPage,
    };
  }

  CenterFilters withoutCategory() => CenterFilters(
    city: city,
    area: area,
    governorate: governorate,
    isFeatured: isFeatured,
    requiresDeposit: requiresDeposit,
    minRating: minRating,
    minPrice: minPrice,
    maxPrice: maxPrice,
    latitude: latitude,
    longitude: longitude,
    radiusKm: radiusKm,
    sortBy: sortBy,
  );

  CenterFilters withoutPrice() => CenterFilters(
    categoryId: categoryId,
    city: city,
    area: area,
    governorate: governorate,
    isFeatured: isFeatured,
    requiresDeposit: requiresDeposit,
    minRating: minRating,
    latitude: latitude,
    longitude: longitude,
    radiusKm: radiusKm,
    sortBy: sortBy,
  );

  static bool _notBlank(String? value) => value?.trim().isNotEmpty == true;

  @override
  List<Object?> get props => <Object?>[
    categoryId,
    city,
    area,
    governorate,
    isFeatured,
    requiresDeposit,
    minRating,
    minPrice,
    maxPrice,
    latitude,
    longitude,
    radiusKm,
    sortBy,
  ];
}
