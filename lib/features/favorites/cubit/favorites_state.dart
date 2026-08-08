import 'package:beauty_center_app/features/favorites/models/favorites_response.dart';
import 'package:equatable/equatable.dart';

enum FavoritesStatus {
  initial,
  loading,
  success,
  failure,
}

enum FavoriteActionType {
  add,
  remove,
}

class FavoritesState extends Equatable {
  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.centers = const <FavoriteCenter>[],
    this.services = const <FavoriteService>[],
    this.message,
    this.isMessageError = false,
    this.togglingCenterIds = const <int>{},
    this.togglingServiceIds = const <int>{},
  });

  final FavoritesStatus status;
  final List<FavoriteCenter> centers;
  final List<FavoriteService> services;
  final String? message;
  final bool isMessageError;
  final Set<int> togglingCenterIds;
  final Set<int> togglingServiceIds;

  bool get isLoading => status == FavoritesStatus.loading;
  bool get hasCenters => centers.isNotEmpty;
  bool get hasServices => services.isNotEmpty;
  bool get isEmpty => centers.isEmpty && services.isEmpty;

  bool isCenterToggling(int centerId) => togglingCenterIds.contains(centerId);
  bool isServiceToggling(int serviceId) => togglingServiceIds.contains(serviceId);

  bool isCenterFavorite(int centerId) {
    return centers.any((FavoriteCenter c) => c.id == centerId && c.isFavorite);
  }

  bool isServiceFavorite(int serviceId) {
    return services.any((FavoriteService s) => s.id == serviceId && s.isFavorite);
  }

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<FavoriteCenter>? centers,
    List<FavoriteService>? services,
    String? message,
    bool? isMessageError,
    bool clearMessage = false,
    Set<int>? togglingCenterIds,
    Set<int>? togglingServiceIds,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      centers: centers ?? this.centers,
      services: services ?? this.services,
      message: clearMessage ? null : (message ?? this.message),
      isMessageError: clearMessage ? false : (isMessageError ?? this.isMessageError),
      togglingCenterIds: togglingCenterIds ?? this.togglingCenterIds,
      togglingServiceIds: togglingServiceIds ?? this.togglingServiceIds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    centers,
    services,
    message,
    isMessageError,
    togglingCenterIds,
    togglingServiceIds,
  ];
}
