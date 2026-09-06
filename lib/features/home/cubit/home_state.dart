import 'package:beauty_center_app/features/home/models/home_data.dart';
import 'package:beauty_center_app/features/home/models/search_response.dart';
import 'package:equatable/equatable.dart';

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.data,
    this.message,
    this.searchQuery = '',
    this.isSearching = false,
    this.searchData,
    this.searchStatus = SearchStatus.initial,
  });

  final HomeStatus status;
  final HomeData? data;
  final String? message;
  final String searchQuery;
  final bool isSearching;
  final SearchData? searchData;
  final SearchStatus searchStatus;

  bool get isLoading => status == HomeStatus.loading;
  bool get hasData => data != null;
  bool get isSearchLoading => searchStatus == SearchStatus.loading;
  bool get hasSearchResults => searchData != null && searchData!.hasResults;
  bool get hasSearchQuery => searchQuery.isNotEmpty;

  HomeState copyWith({
    HomeStatus? status,
    HomeData? data,
    String? message,
    bool clearData = false,
    bool clearMessage = false,
    String? searchQuery,
    bool? isSearching,
    SearchData? searchData,
    SearchStatus? searchStatus,
    bool clearSearchData = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      data: clearData ? null : (data ?? this.data),
      message: clearMessage ? null : (message ?? this.message),
      searchQuery: searchQuery ?? this.searchQuery,
      isSearching: isSearching ?? this.isSearching,
      searchData: clearSearchData ? null : (searchData ?? this.searchData),
      searchStatus: searchStatus ?? this.searchStatus,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    data,
    message,
    searchQuery,
    isSearching,
    searchData,
    searchStatus,
  ];
}

enum SearchStatus { initial, loading, success, failure }
