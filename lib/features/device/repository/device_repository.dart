import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/network/base_repository.dart';
import 'package:beauty_center_app/features/device/models/device_response.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeviceRepository extends BaseRepository {
  DeviceRepository(super.dioClient);

  Future<Either<Failure, DeviceMessageResponse>> registerDevice({
    required String fcmToken,
    required String platform,
    String appVersion = '1.0.0',
  }) async {
    return callApiWithErrorParser(
      dio.post(
        ApiEndpoints.devices,
        data: <String, dynamic>{
          'fcm_token': fcmToken,
          'platform': platform,
          'app_version': appVersion,
        },
      ),
      DeviceMessageResponse.fromJson,
    );
  }

  Future<Either<Failure, DeviceMessageResponse>> unregisterDevice({
    required String fcmToken,
  }) async {
    return callApiWithErrorParser(
      dio.delete(
        ApiEndpoints.devices,
        data: <String, dynamic>{'fcm_token': fcmToken},
      ),
      DeviceMessageResponse.fromJson,
    );
  }
}
