import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/network/base_repository.dart';
import 'package:beauty_center_app/features/favorites/models/favorites_response.dart';
import 'package:beauty_center_app/features/favorites/models/toggle_favorite_response.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class FavoritesRepository extends BaseRepository {
  FavoritesRepository(super.dioClient);

  Future<Either<Failure, FavoritesResponse>> getFavorites() {
    return callApiWithErrorParser(
      dio.get(ApiEndpoints.favorites),
      FavoritesResponse.fromJson,
    );
  }

  Future<Either<Failure, ToggleFavoriteResponse>> addCenterToFavorites({
    required int centerId,
  }) {
    return callApiWithErrorParser(
      dio.post(
        ApiEndpoints.favorites,
        data: <String, dynamic>{
          'type': 'center',
          'id': centerId,
        },
      ),
      ToggleFavoriteResponse.fromJson,
    );
  }

  Future<Either<Failure, ToggleFavoriteResponse>> removeCenterFromFavorites({
    required int centerId,
  }) {
    return callApiWithErrorParser(
      dio.delete('${ApiEndpoints.favorites}/center/$centerId'),
      ToggleFavoriteResponse.fromJson,
    );
  }

  Future<Either<Failure, ToggleFavoriteResponse>> addServiceToFavorites({
    required int serviceId,
  }) {
    return callApiWithErrorParser(
      dio.post(
        ApiEndpoints.favorites,
        data: <String, dynamic>{
          'type': 'service',
          'id': serviceId,
        },
      ),
      ToggleFavoriteResponse.fromJson,
    );
  }

  Future<Either<Failure, ToggleFavoriteResponse>> removeServiceFromFavorites({
    required int serviceId,
  }) {
    return callApiWithErrorParser(
      dio.post(
        '${ApiEndpoints.favorites}/toggle',
        data: <String, dynamic>{
          'type': 'service',
          'id': serviceId,
        },
      ),
      ToggleFavoriteResponse.fromJson,
    );
  }
}
