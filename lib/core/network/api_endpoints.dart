class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = "http://192.168.1.11:8000/api/";

  // Auth endpoints.
  static const String login = 'customer/login';
  static const String register = 'customer/register';
  static const String logout = 'customer/logout';
  static const String forgotPassword = 'customer/forgot-password';
  static const String verifyOtp = 'customer/verify-email-otp';
  static const String resendOtp = 'customer/resend-email-otp';
  static const String resetPassword = 'customer/reset-password';

  // Devices (FCM)
  static const String devices = 'customer/devices';

  // Home
  static const String home = 'customer/home';

  // Explore
  static const String categories = 'customer/categories';
  static const String centers = 'customer/centers';

  static const String storageUrl = 'http://192.168.1.11:8000/storage/';

  static String mediaUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    if (path.startsWith('http')) {
      return path;
    }
    return '$storageUrl$path';
  }
}
