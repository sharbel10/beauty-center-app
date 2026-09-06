import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/features/favorites/cubit/favorites_state.dart';
import 'package:beauty_center_app/features/favorites/models/favorites_response.dart';
import 'package:beauty_center_app/features/favorites/models/toggle_favorite_response.dart';
import 'package:beauty_center_app/features/favorites/repository/favorites_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._repository) : super(const FavoritesState());

  final FavoritesRepository _repository;

  Future<void> loadFavorites() async {
    emit(state.copyWith(status: FavoritesStatus.loading, clearMessage: true));

    final Either<Failure, FavoritesResponse> result = await _repository
        .getFavorites();

    result.fold(
      (Failure failure) {
        emit(
          state.copyWith(
            status: FavoritesStatus.failure,
            message: failure.message,
            isMessageError: true,
          ),
        );
      },
      (FavoritesResponse response) {
        emit(
          state.copyWith(
            status: FavoritesStatus.success,
            centers: response.centers,
            services: response.services,
          ),
        );
      },
    );
  }

  Future<void> toggleCenterFavorite({
    required int centerId,
    required bool isCurrentlyFavorite,
  }) async {
    if (state.isCenterToggling(centerId)) {
      return;
    }

    final Set<int> newTogglingIds = Set<int>.from(state.togglingCenterIds)
      ..add(centerId);

    final List<FavoriteCenter> updatedCenters = _toggleCenterInList(
      state.centers,
      centerId,
      !isCurrentlyFavorite,
    );

    emit(
      state.copyWith(
        togglingCenterIds: newTogglingIds,
        centers: updatedCenters,
      ),
    );

    final Either<Failure, ToggleFavoriteResponse> result = isCurrentlyFavorite
        ? await _repository.removeCenterFromFavorites(centerId: centerId)
        : await _repository.addCenterToFavorites(centerId: centerId);

    result.fold(
      (Failure failure) {
        final List<FavoriteCenter> revertedCenters = _toggleCenterInList(
          state.centers,
          centerId,
          isCurrentlyFavorite,
        );

        final Set<int> restoredTogglingIds = Set<int>.from(
          state.togglingCenterIds,
        )..remove(centerId);

        emit(
          state.copyWith(
            centers: revertedCenters,
            togglingCenterIds: restoredTogglingIds,
            message: failure.message,
            isMessageError: true,
          ),
        );

        throw failure;
      },
      (ToggleFavoriteResponse response) {
        final Set<int> finalTogglingIds = Set<int>.from(state.togglingCenterIds)
          ..remove(centerId);

        final bool serverIsFavorite = response.favorite.isFavorite;
        List<FavoriteCenter> finalCenters = _toggleCenterInList(
          state.centers,
          centerId,
          serverIsFavorite,
        );

        if (!serverIsFavorite) {
          finalCenters.removeWhere((FavoriteCenter c) => c.id == centerId);
        }

        emit(
          state.copyWith(
            centers: finalCenters,
            togglingCenterIds: finalTogglingIds,
            message: response.message,
            isMessageError: false,
          ),
        );
      },
    );
  }

  Future<void> toggleServiceFavorite({
    required int serviceId,
    required bool isCurrentlyFavorite,
  }) async {
    if (state.isServiceToggling(serviceId)) {
      return;
    }

    final Set<int> newTogglingIds = Set<int>.from(state.togglingServiceIds)
      ..add(serviceId);

    final List<FavoriteService> updatedServices = _toggleServiceInList(
      state.services,
      serviceId,
      !isCurrentlyFavorite,
    );

    emit(
      state.copyWith(
        togglingServiceIds: newTogglingIds,
        services: updatedServices,
      ),
    );

    final Either<Failure, ToggleFavoriteResponse> result = isCurrentlyFavorite
        ? await _repository.removeServiceFromFavorites(serviceId: serviceId)
        : await _repository.addServiceToFavorites(serviceId: serviceId);

    result.fold(
      (Failure failure) {
        final List<FavoriteService> revertedServices = _toggleServiceInList(
          state.services,
          serviceId,
          isCurrentlyFavorite,
        );

        final Set<int> restoredTogglingIds = Set<int>.from(
          state.togglingServiceIds,
        )..remove(serviceId);

        emit(
          state.copyWith(
            services: revertedServices,
            togglingServiceIds: restoredTogglingIds,
            message: failure.message,
            isMessageError: true,
          ),
        );

        throw failure;
      },
      (ToggleFavoriteResponse response) {
        final Set<int> finalTogglingIds = Set<int>.from(
          state.togglingServiceIds,
        )..remove(serviceId);

        final bool serverIsFavorite = response.favorite.isFavorite;
        List<FavoriteService> finalServices = _toggleServiceInList(
          state.services,
          serviceId,
          serverIsFavorite,
        );

        if (!serverIsFavorite) {
          finalServices.removeWhere((FavoriteService s) => s.id == serviceId);
        }

        emit(
          state.copyWith(
            services: finalServices,
            togglingServiceIds: finalTogglingIds,
            message: response.message,
            isMessageError: false,
          ),
        );
      },
    );
  }

  void clearMessage() {
    emit(state.copyWith(clearMessage: true));
  }

  static List<FavoriteCenter> _toggleCenterInList(
    List<FavoriteCenter> list,
    int centerId,
    bool isFavorite,
  ) {
    return list
        .map(
          (FavoriteCenter c) =>
              c.id == centerId ? c.copyWith(isFavorite: isFavorite) : c,
        )
        .toList();
  }

  static List<FavoriteService> _toggleServiceInList(
    List<FavoriteService> list,
    int serviceId,
    bool isFavorite,
  ) {
    return list
        .map(
          (FavoriteService s) =>
              s.id == serviceId ? s.copyWith(isFavorite: isFavorite) : s,
        )
        .toList();
  }
}
