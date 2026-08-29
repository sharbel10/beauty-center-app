import 'dart:async';

import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/features/home/cubit/home_state.dart';
import 'package:beauty_center_app/features/home/models/home_response.dart';
import 'package:beauty_center_app/features/home/models/search_response.dart';
import 'package:beauty_center_app/features/home/repository/home_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._homeRepository) : super(const HomeState());

  static const int searchPerPage = 10;
  static const Duration _searchDebounceDuration = Duration(milliseconds: 700);

  final HomeRepository _homeRepository;
  Timer? _debounceTimer;
  int _searchRequestId = 0;

  Future<void> loadHome({
    double? latitude,
    double? longitude,
    double? radiusKm,
    int? categoryId,
    bool clearData = false,
  }) async {
    emit(
      state.copyWith(
        status: HomeStatus.loading,
        clearData: clearData,
        clearMessage: true,
      ),
    );

    final Either<Failure, HomeResponse> homeResult = await _homeRepository
        .getHome(
          latitude: latitude,
          longitude: longitude,
          radiusKm: radiusKm,
          categoryId: categoryId,
        );
    if (isClosed) {
      return;
    }

    homeResult.fold(
      (Failure failure) => emit(
        state.copyWith(status: HomeStatus.failure, message: failure.message),
      ),
      (HomeResponse response) =>
          emit(state.copyWith(status: HomeStatus.success, data: response.data)),
    );
  }

  void onSearchQueryChanged(String query) {
    _debounceTimer?.cancel();

    final String normalizedQuery = _normalizeQuery(query);

    emit(
      state.copyWith(
        searchQuery: normalizedQuery,
        isSearching: normalizedQuery.isNotEmpty,
        clearMessage: true,
      ),
    );

    if (normalizedQuery.isEmpty) {
      _searchRequestId++;
      emit(
        state.copyWith(
          isSearching: false,
          clearSearchData: true,
          searchStatus: SearchStatus.initial,
        ),
      );
      return;
    }

    emit(
      state.copyWith(searchStatus: SearchStatus.loading, clearSearchData: true),
    );

    final int requestId = ++_searchRequestId;
    _debounceTimer = Timer(_searchDebounceDuration, () {
      performSearch(normalizedQuery, requestId: requestId);
    });
  }

  Future<void> performSearch(String query, {int? requestId}) async {
    if (isClosed) return;

    final int resolvedRequestId = requestId ?? ++_searchRequestId;
    final String normalizedQuery = _normalizeQuery(query);

    if (normalizedQuery.isEmpty) {
      return;
    }

    emit(
      state.copyWith(
        searchQuery: normalizedQuery,
        isSearching: true,
        searchStatus: SearchStatus.loading,
        clearMessage: true,
      ),
    );

    final Either<Failure, SearchResponse> searchResult = await _homeRepository
        .search(query: normalizedQuery, perPage: searchPerPage);

    if (isClosed) return;
    if (resolvedRequestId != _searchRequestId ||
        normalizedQuery != state.searchQuery) {
      return;
    }

    searchResult.fold(
      (Failure failure) => emit(
        state.copyWith(
          searchStatus: SearchStatus.failure,
          message: failure.message,
          clearSearchData: true,
        ),
      ),
      (SearchResponse response) {
        emit(
          state.copyWith(
            searchStatus: SearchStatus.success,
            searchData: response.data,
          ),
        );
      },
    );
  }

  void clearSearch() {
    _debounceTimer?.cancel();
    _searchRequestId++;
    emit(
      state.copyWith(
        searchQuery: '',
        isSearching: false,
        clearSearchData: true,
        searchStatus: SearchStatus.initial,
      ),
    );
  }

  void setSearchCenterFavorite({
    required int centerId,
    required bool isFavorite,
  }) {
    final SearchData? searchData = state.searchData;
    if (searchData == null) {
      return;
    }

    emit(
      state.copyWith(
        searchData: searchData.copyWith(
          centers: searchData.centers
              .map(
                (CenterSearchResult center) => center.id == centerId
                    ? center.copyWith(isFavorite: isFavorite)
                    : center,
              )
              .toList(),
          services: searchData.services
              .map(
                (ServiceSearchResult service) => service.center?.id == centerId
                    ? service.copyWith(
                        center: service.center!.copyWith(
                          isFavorite: isFavorite,
                        ),
                      )
                    : service,
              )
              .toList(),
        ),
      ),
    );
  }

  void setSearchServiceFavorite({
    required int serviceId,
    required bool isFavorite,
  }) {
    final SearchData? searchData = state.searchData;
    if (searchData == null) {
      return;
    }

    emit(
      state.copyWith(
        searchData: searchData.copyWith(
          services: searchData.services
              .map(
                (ServiceSearchResult service) => service.id == serviceId
                    ? service.copyWith(isFavorite: isFavorite)
                    : service,
              )
              .toList(),
        ),
      ),
    );
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }

  static String _normalizeQuery(String query) {
    final String value = query.trim();
    return value.length <= 255 ? value : value.substring(0, 255);
  }
}
