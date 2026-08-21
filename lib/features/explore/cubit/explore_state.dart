import 'package:beauty_center_app/features/explore/models/center_filters.dart';
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
    this.filters = const CenterFilters(),
  });

  final ExploreStatus status;
  final List<Category> categories;
  final List<ClinicCenter> centers;
  final PaginationMeta? meta;
  final String? message;
  final String search;
  final CenterFilters filters;

  bool get isLoading => status == ExploreStatus.loading;
  bool get isLoadingMore => status == ExploreStatus.loadingMore;
  bool get hasCenters => centers.isNotEmpty;
  bool get canLoadMore => meta?.hasNextPage ?? false;
  int get nextPage => meta?.nextPage ?? 1;

  ExploreState copyWith({
    ExploreStatus? status,
    List<Category>? categories,
    List<ClinicCenter>? centers,
    PaginationMeta? meta,
    String? message,
    String? search,
    CenterFilters? filters,
    bool clearCenters = false,
    bool clearMeta = false,
    bool clearMessage = false,
  }) {
    return ExploreState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      centers: clearCenters ? const <ClinicCenter>[] : centers ?? this.centers,
      meta: clearMeta ? null : meta ?? this.meta,
      message: clearMessage ? null : message ?? this.message,
      search: search ?? this.search,
      filters: filters ?? this.filters,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    categories,
    centers,
    meta,
    message,
    search,
    filters,
  ];
}
