import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/network/base_repository.dart';
import 'package:beauty_center_app/features/explore/models/categories_response.dart';
import 'package:beauty_center_app/features/explore/models/centers_response.dart';
import 'package:beauty_center_app/features/explore/models/center_filters.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class ExploreRepository extends BaseRepository {
  ExploreRepository(super.dioClient);

  Future<Either<Failure, CategoriesResponse>> getCategories() {
    return callApiWithErrorParser(
      dio.get(ApiEndpoints.categories),
      CategoriesResponse.fromJson,
    );
  }

  Future<Either<Failure, CentersResponse>> getCenters({
    int page = 1,
    required String query,
    required CenterFilters filters,
  }) {
    return callApiWithErrorParser(
      dio.get(
        ApiEndpoints.centers,
        queryParameters: filters.toQueryParameters(query: query, page: page),
      ),
      CentersResponse.fromJson,
    );
  }
}
