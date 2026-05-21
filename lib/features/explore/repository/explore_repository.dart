import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/network/base_repository.dart';
import 'package:beauty_center_app/features/explore/models/categories_response.dart';
import 'package:beauty_center_app/features/explore/models/centers_response.dart';
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
    int perPage = 15,
    String sortBy = 'rating',
    String? search,
    int? categoryId,
    int? minPrice,
    int? maxPrice,
  }) {
    return callApiWithErrorParser(
      dio.get(
        ApiEndpoints.centers,
        queryParameters: <String, dynamic>{
          'sort_by': sortBy,
          'page': page,
          'per_page': perPage,
          if (search != null && search.trim().isNotEmpty)
            'search': search.trim(),
          if (categoryId != null) 'category_id': categoryId,
          if (minPrice != null) 'min_price': minPrice,
          if (maxPrice != null) 'max_price': maxPrice,
        },
      ),
      CentersResponse.fromJson,
    );
  }
}
