import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/network/base_repository.dart';
import 'package:beauty_center_app/features/home/models/home_response.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class HomeRepository extends BaseRepository {
  HomeRepository(super.dioClient);

  Future<Either<Failure, HomeResponse>> getHome() {
    return callApiWithErrorParser(
      dio.get(ApiEndpoints.home),
      HomeResponse.fromJson,
    );
  }
}
