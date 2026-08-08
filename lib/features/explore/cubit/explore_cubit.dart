import 'package:beauty_center_app/features/explore/cubit/explore_state.dart';
import 'package:beauty_center_app/features/explore/repository/explore_repository.dart';
import 'package:beauty_center_app/features/home/models/clinic_center.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class ExploreCubit extends Cubit<ExploreState> {
  ExploreCubit(this._exploreRepository) : super(const ExploreState());

  static const int defaultPerPage = 15;

  final ExploreRepository _exploreRepository;

  Future<void> loadInitial() async {
    emit(
      state.copyWith(
        status: ExploreStatus.loading,
        clearMessage: true,
        clearCenters: true,
        clearMeta: true,
      ),
    );

    final categoriesResult = await _exploreRepository.getCategories();
    final centersResult = await _exploreRepository.getCenters(
      page: 1,
      perPage: defaultPerPage,
      search: state.search,
      categoryId: state.selectedCategoryId,
      minPrice: state.hasPriceFilter ? state.minPrice : null,
      maxPrice: state.hasPriceFilter ? state.maxPrice : null,
      sortBy: state.sortBy,
    );

    categoriesResult.fold(
      (failure) => emit(
        state.copyWith(status: ExploreStatus.failure, message: failure.message),
      ),
      (categoriesResponse) {
        centersResult.fold(
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
        );
      },
    );
  }

  Future<void> refreshCenters() async {
    emit(
      state.copyWith(
        status: ExploreStatus.loading,
        clearMessage: true,
        clearCenters: true,
        clearMeta: true,
      ),
    );

    final result = await _exploreRepository.getCenters(
      page: 1,
      perPage: defaultPerPage,
      search: state.search,
      categoryId: state.selectedCategoryId,
      minPrice: state.hasPriceFilter ? state.minPrice : null,
      maxPrice: state.hasPriceFilter ? state.maxPrice : null,
      sortBy: state.sortBy,
    );

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
    if (!state.canLoadMore || state.isLoadingMore || state.isLoading) {
      return;
    }

    emit(state.copyWith(status: ExploreStatus.loadingMore, clearMessage: true));

    final result = await _exploreRepository.getCenters(
      page: state.nextPage,
      perPage: defaultPerPage,
      search: state.search,
      categoryId: state.selectedCategoryId,
      minPrice: state.hasPriceFilter ? state.minPrice : null,
      maxPrice: state.hasPriceFilter ? state.maxPrice : null,
      sortBy: state.sortBy,
    );

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

  Future<void> updateSearch(String value) async {
    emit(state.copyWith(search: value));
    await refreshCenters();
  }

  Future<void> updateCategory(int? categoryId) async {
    emit(
      categoryId == null
          ? state.copyWith(clearCategory: true)
          : state.copyWith(selectedCategoryId: categoryId),
    );
    await refreshCenters();
  }

  Future<void> loadInitialWithCategory(int? categoryId) async {
    emit(
      state.copyWith(
        status: ExploreStatus.loading,
        clearMessage: true,
        clearCenters: true,
        clearMeta: true,
        selectedCategoryId: categoryId,
      ),
    );

    final categoriesResult = await _exploreRepository.getCategories();
    final centersResult = await _exploreRepository.getCenters(
      page: 1,
      perPage: defaultPerPage,
      search: state.search,
      categoryId: categoryId,
      minPrice: state.hasPriceFilter ? state.minPrice : null,
      maxPrice: state.hasPriceFilter ? state.maxPrice : null,
      sortBy: state.sortBy,
    );

    categoriesResult.fold(
      (failure) => emit(
        state.copyWith(status: ExploreStatus.failure, message: failure.message),
      ),
      (categoriesResponse) {
        centersResult.fold(
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
        );
      },
    );
  }

  Future<void> applyFilters({
    required int? categoryId,
    required int minPrice,
    required int maxPrice,
  }) async {
    emit(
      state.copyWith(
        selectedCategoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        clearCategory: categoryId == null,
        clearPrice: minPrice == 0 && maxPrice == ExploreState.defaultMaxPrice,
      ),
    );
    await refreshCenters();
  }

  Future<void> resetPriceFilter() async {
    emit(state.copyWith(clearPrice: true));
    await refreshCenters();
  }
}
