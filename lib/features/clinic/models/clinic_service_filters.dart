import 'package:equatable/equatable.dart';

const List<String> clinicServiceSortOptions = <String>[
  'price_asc',
  'price_desc',
  'duration',
  'name',
  'latest',
];

class ClinicServiceFilters extends Equatable {
  const ClinicServiceFilters({
    this.query = '',
    this.categoryId,
    this.isFeatured,
    this.minPrice,
    this.maxPrice,
    this.maxDuration,
    this.sortBy,
  });

  final String query;
  final int? categoryId;
  final bool? isFeatured;
  final double? minPrice;
  final double? maxPrice;
  final int? maxDuration;
  final String? sortBy;

  bool get isActive =>
      query.trim().isNotEmpty ||
      categoryId != null ||
      isFeatured != null ||
      minPrice != null ||
      maxPrice != null ||
      maxDuration != null ||
      sortBy != null;

  Map<String, dynamic> toQueryParameters() => <String, dynamic>{
    if (query.trim().isNotEmpty) 'q': query.trim(),
    if (categoryId != null) 'category_id': categoryId,
    if (isFeatured != null) 'is_featured': isFeatured,
    if (minPrice != null) 'min_price': minPrice,
    if (maxPrice != null) 'max_price': maxPrice,
    if (maxDuration != null) 'max_duration': maxDuration,
    if (sortBy != null) 'sort_by': sortBy,
  };

  @override
  List<Object?> get props => <Object?>[
    query,
    categoryId,
    isFeatured,
    minPrice,
    maxPrice,
    maxDuration,
    sortBy,
  ];
}
