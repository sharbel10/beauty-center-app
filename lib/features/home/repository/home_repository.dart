import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/network/base_repository.dart';
import 'package:beauty_center_app/features/home/models/home_response.dart';
import 'package:beauty_center_app/features/home/models/search_response.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeRepository extends BaseRepository {
  HomeRepository(super.dioClient);

  Future<Either<Failure, HomeResponse>> getHome({
    double? latitude,
    double? longitude,
    double? radiusKm,
    int? categoryId,
  }) {
    return callApiWithErrorParser(
      dio.get(
        ApiEndpoints.home,
        queryParameters: <String, dynamic>{
          'latitude': latitude,
          'longitude': longitude,
          'radius_km': radiusKm,
          'category_id': categoryId,
        }..removeWhere((String key, dynamic value) => value == null),
      ),
      HomeResponse.fromJson,
    );
  }

  Future<Either<Failure, SearchResponse>> search({
    required String query,
    int perPage = 10,
  }) {
    return callApiWithErrorParser(
      dio.get(
        ApiEndpoints.search,
        queryParameters: <String, dynamic>{
          'q': query,
          'per_page': perPage,
        },
      ),
      SearchResponse.fromJson,
    );
  }
}
