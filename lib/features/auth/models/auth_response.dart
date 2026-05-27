import 'package:beauty_center_app/features/auth/models/customer.dart';
import 'package:beauty_center_app/features/auth/models/token.dart';
import 'package:equatable/equatable.dart';

class AuthResponse extends Equatable {
  const AuthResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'],
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  final bool success;
  final String message;
  final dynamic data;
  final Map<String, dynamic>? errors;

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
      'errors': errors,
    };
  }

  @override
  List<Object?> get props => [success, message, data, errors];
}

class RegisterResponse extends AuthResponse {
  const RegisterResponse({
    required super.success,
    required super.message,
    super.data,
    super.errors,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  Customer? get customer {
    if (data != null && data!['customer'] != null) {
      return Customer.fromJson(data!['customer'] as Map<String, dynamic>);
    }
    return null;
  }

  int? get otpExpiresInMinutes {
    if (data != null && data!['otp_expires_in_minutes'] != null) {
      return data!['otp_expires_in_minutes'] as int;
    }
    return null;
  }
}

class VerifyOtpResponse extends AuthResponse {
  const VerifyOtpResponse({
    required super.success,
    required super.message,
    super.data,
    super.errors,
  });

  factory VerifyOtpResponse.fromJson(Map<String, dynamic> json) {
    return VerifyOtpResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  Customer? get customer {
    if (data != null && data!['customer'] != null) {
      return Customer.fromJson(data!['customer'] as Map<String, dynamic>);
    }
    return null;
  }

  Token? get token {
    if (data != null && data!['token'] != null) {
      return Token.fromJson(data!['token'] as Map<String, dynamic>);
    }
    return null;
  }
}

class ResendOtpResponse extends AuthResponse {
  const ResendOtpResponse({
    required super.success,
    required super.message,
    super.data,
    super.errors,
  });

  factory ResendOtpResponse.fromJson(Map<String, dynamic> json) {
    return ResendOtpResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  int? get otpExpiresInMinutes {
    if (data != null && data!['otp_expires_in_minutes'] != null) {
      return data!['otp_expires_in_minutes'] as int;
    }
    return null;
  }

  bool? get alreadyVerified {
    if (data != null && data!['already_verified'] != null) {
      return data!['already_verified'] as bool;
    }
    return null;
  }
}

class LoginResponse extends AuthResponse {
  const LoginResponse({
    required super.success,
    required super.message,
    super.data,
    super.errors,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }

  Customer? get customer {
    if (data != null && data!['customer'] != null) {
      return Customer.fromJson(data!['customer'] as Map<String, dynamic>);
    }
    return null;
  }

  Token? get token {
    if (data != null && data!['token'] != null) {
      return Token.fromJson(data!['token'] as Map<String, dynamic>);
    }
    return null;
  }
}

class LogoutResponse extends AuthResponse {
  const LogoutResponse({
    required super.success,
    required super.message,
    super.data,
    super.errors,
  });

  factory LogoutResponse.fromJson(Map<String, dynamic> json) {
    return LogoutResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'],
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }
}

class ForgotPasswordResponse extends AuthResponse {
  const ForgotPasswordResponse({
    required super.success,
    required super.message,
    super.data,
    super.errors,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'],
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }
}

class ResetPasswordResponse extends AuthResponse {
  const ResetPasswordResponse({
    required super.success,
    required super.message,
    super.data,
    super.errors,
  });

  factory ResetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'],
      errors: json['errors'] as Map<String, dynamic>?,
    );
  }
}
