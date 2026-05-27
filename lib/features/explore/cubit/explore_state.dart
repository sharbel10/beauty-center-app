import 'package:beauty_center_app/features/explore/models/pagination_meta.dart';
import 'package:beauty_center_app/features/home/models/category.dart';
import 'package:beauty_center_app/features/home/models/clinic_center.dart';
import 'package:equatable/equatable.dart';

enum ExploreStatus { initial, loading, loadingMore, success, failure }

class ExploreState extends Equatable {
  const ExploreState({
    this.status = ExploreStatus.initial,
    this.categories = const <Category>[],
    this.centers = const <ClinicCenter>[],
    this.meta,
    this.message,
    this.search = '',
    this.selectedCategoryId,
    this.minPrice = 0,
    this.maxPrice = defaultMaxPrice,
    this.sortBy = 'rating',
  });

  static const int defaultMaxPrice = 1000;

  final ExploreStatus status;
  final List<Category> categories;
  final List<ClinicCenter> centers;
  final PaginationMeta? meta;
  final String? message;
  final String search;
  final int? selectedCategoryId;
  final int minPrice;
  final int maxPrice;
  final String sortBy;

  bool get isLoading => status == ExploreStatus.loading;
  bool get isLoadingMore => status == ExploreStatus.loadingMore;
  bool get hasCenters => centers.isNotEmpty;
  bool get canLoadMore => meta?.hasNextPage ?? false;
  int get nextPage => meta?.nextPage ?? 1;
  bool get hasPriceFilter => minPrice > 0 || maxPrice < defaultMaxPrice;

  ExploreState copyWith({
    ExploreStatus? status,
    List<Category>? categories,
    List<ClinicCenter>? centers,
    PaginationMeta? meta,
    String? message,
    String? search,
    int? selectedCategoryId,
    int? minPrice,
    int? maxPrice,
    String? sortBy,
    bool clearCenters = false,
    bool clearMeta = false,
    bool clearMessage = false,
    bool clearCategory = false,
    bool clearPrice = false,
  }) {
    return ExploreState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      centers: clearCenters
          ? const <ClinicCenter>[]
          : (centers ?? this.centers),
      meta: clearMeta ? null : (meta ?? this.meta),
      message: clearMessage ? null : (message ?? this.message),
      search: search ?? this.search,
      selectedCategoryId: clearCategory
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      minPrice: clearPrice ? 0 : (minPrice ?? this.minPrice),
      maxPrice: clearPrice ? defaultMaxPrice : (maxPrice ?? this.maxPrice),
      sortBy: sortBy ?? this.sortBy,
    );
  }

  @override
  List<Object?> get props => [
    status,
    categories,
    centers,
    meta,
    message,
    search,
    selectedCategoryId,
    minPrice,
    maxPrice,
    sortBy,
  ];
}
