import 'package:beauty_center_app/features/auth/models/auth_response.dart';

class DeviceMessageResponse extends AuthResponse {
  const DeviceMessageResponse({
    required super.success,
    required super.message,
    super.data,
    super.errors,
  });

  factory DeviceMessageResponse.fromJson(Map<String, dynamic> json) {
    return DeviceMessageResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'],
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }
}
