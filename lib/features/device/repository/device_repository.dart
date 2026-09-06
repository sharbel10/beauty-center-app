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
    required String deviceToken,
    required String platform,
    required String deviceName,
    required String locale,
  }) {
    return callApiWithErrorParser(
      dio.post(
        ApiEndpoints.devices,
        data: <String, dynamic>{
          'device_token': deviceToken,
          'platform': platform,
          'device_name': deviceName,
          'locale': locale,
        },
      ),
      DeviceMessageResponse.fromJson,
    );
  }

  Future<Either<Failure, DeviceMessageResponse>> unregisterDevice({
    required String deviceToken,
  }) {
    return callApiWithErrorParser(
      dio.delete(
        ApiEndpoints.devices,
        data: <String, dynamic>{'device_token': deviceToken},
      ),
      DeviceMessageResponse.fromJson,
    );
  }
}
