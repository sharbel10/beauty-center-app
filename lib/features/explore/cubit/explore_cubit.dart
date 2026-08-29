import 'package:beauty_center_app/features/explore/cubit/explore_state.dart';
import 'package:beauty_center_app/features/explore/models/center_filters.dart';
import 'package:beauty_center_app/features/explore/repository/explore_repository.dart';
import 'package:beauty_center_app/features/home/models/clinic_center.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ExploreCubit extends Cubit<ExploreState> {
  ExploreCubit(this._exploreRepository) : super(const ExploreState());

  final ExploreRepository _exploreRepository;
  int _requestId = 0;

  Future<void> loadInitial() => _loadInitial(categoryId: null);

  Future<void> loadInitialWithCategory(int? categoryId) =>
      _loadInitial(categoryId: categoryId);

  Future<void> _loadInitial({required int? categoryId}) async {
    final CenterFilters filters = categoryId == null
        ? state.filters
        : CenterFilters(categoryId: categoryId);
    emit(
      state.copyWith(
        status: ExploreStatus.loading,
        filters: filters,
        clearMessage: true,
        clearCenters: true,
        clearMeta: true,
      ),
    );

    final categoriesResult = await _exploreRepository.getCategories();
    final centersResult = await _exploreRepository.getCenters(
      query: state.search,
      filters: filters,
    );
    if (isClosed) return;

    categoriesResult.fold(
      (failure) => emit(
        state.copyWith(status: ExploreStatus.failure, message: failure.message),
      ),
      (categoriesResponse) => centersResult.fold(
        (failure) => emit(
          state.copyWith(
            status: ExploreStatus.failure,
            categories: categoriesResponse.categories,
            message: failure.message,
          ),
        ),
        (centersResponse) => emit(
          state.copyWith(
            status: ExploreStatus.success,
            categories: categoriesResponse.categories,
            centers: centersResponse.centers,
            meta: centersResponse.meta,
          ),
        ),
      ),
    );
  }

  Future<void> refreshCenters() async {
    final int requestId = ++_requestId;
    emit(
      state.copyWith(
        status: ExploreStatus.loading,
        clearMessage: true,
        clearCenters: true,
        clearMeta: true,
      ),
    );

    final result = await _exploreRepository.getCenters(
      query: state.search,
      filters: state.filters,
    );
    if (isClosed || requestId != _requestId) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: ExploreStatus.failure, message: failure.message),
      ),
      (response) => emit(
        state.copyWith(
          status: ExploreStatus.success,
          centers: response.centers,
          meta: response.meta,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore || state.isLoadingMore || state.isLoading) return;

    emit(state.copyWith(status: ExploreStatus.loadingMore, clearMessage: true));
    final result = await _exploreRepository.getCenters(
      page: state.nextPage,
      query: state.search,
      filters: state.filters,
    );
    if (isClosed) return;

    result.fold(
      (failure) => emit(
        state.copyWith(status: ExploreStatus.failure, message: failure.message),
      ),
      (response) => emit(
        state.copyWith(
          status: ExploreStatus.success,
          centers: <ClinicCenter>[...state.centers, ...response.centers],
          meta: response.meta,
        ),
      ),
    );
  }

  Future<void> submitSearch(String value) async {
    emit(state.copyWith(search: _normalizeQuery(value)));
    await refreshCenters();
  }

  Future<void> applyFilters(CenterFilters filters) async {
    emit(state.copyWith(filters: filters));
    await refreshCenters();
  }

  Future<void> clearCategory() => applyFilters(state.filters.withoutCategory());

  Future<void> clearPrice() => applyFilters(state.filters.withoutPrice());

  Future<void> resetFilters() =>
      applyFilters(CenterFilters(categoryId: state.filters.categoryId));

  static String _normalizeQuery(String query) {
    final String value = query.trim();
    return value.length <= 255 ? value : value.substring(0, 255);
  }
}
