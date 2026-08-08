import 'dart:io';

import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/network/base_repository.dart';
import 'package:beauty_center_app/features/profile/models/profile_response.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
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

  Future<Either<Failure, ProfileResponse>> updateProfile(
    Map<String, dynamic> data,
  ) {
    return callApiWithErrorParser(
      dio.patch(ApiEndpoints.profile, data: data),
      ProfileResponse.fromJson,
    );
  }

  Future<Either<Failure, ProfileResponse>> uploadAvatar(File avatarFile) {
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'avatar': MultipartFile.fromFileSync(
        avatarFile.path,
        filename: avatarFile.path.split('/').last,
      ),
    });

    return callApiWithErrorParser(
      dio.post(
        ApiEndpoints.profileAvatar,
        data: formData,
      ),
      ProfileResponse.fromJson,
    );
  }

  Future<Either<Failure, void>> deleteAccount() {
    return callApiWithErrorParser(
      dio.delete(ApiEndpoints.profile),
      (_) {},
    );
  }

  Future<Either<Failure, ProfileResponse>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String passwordConfirmation,
  }) {
    return callApiWithErrorParser(
      dio.post(
        ApiEndpoints.changePassword,
        data: <String, dynamic>{
          'current_password': currentPassword,
          'password': newPassword,
          'password_confirmation': passwordConfirmation,
        },
      ),
      ProfileResponse.fromJson,
    );
  }
}
