class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://your-api.com/api/';

  // Auth endpoints.
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String logout = 'auth/logout';
  static const String forgotPassword = 'auth/forgot-password';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resetPassword = 'auth/reset-password';
}
