import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/network/base_repository.dart';
import 'package:beauty_center_app/features/profile/models/profile_response.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class ProfileRepository extends BaseRepository {
  ProfileRepository(super.dioClient);

  Future<Either<Failure, ProfileResponse>> getProfile() {
    return callApiWithErrorParser(
      dio.get(ApiEndpoints.profile),
      ProfileResponse.fromJson,
    );
  }
}
