class AuthValidation {
  AuthValidation._();

  static String? fullName(String value) {
    if (value.trim().length < 3) {
      return 'Enter your full name.';
    }
    return null;
  }

  static String? email(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'Email address is required.';
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? phone(String value) {
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return 'Phone number is required.';
    }
    if (digits.length < 8 || digits.length > 15) {
      return 'Enter a valid phone number.';
    }
    return null;
  }

  static String? emailOrPhone(String value) {
    final String trimmed = value.trim();
    final String digits = trimmed.replaceAll(RegExp(r'\D'), '');
    final bool isPhone = digits.length >= 8 && digits.length <= 15;

    if (trimmed.isEmpty) {
      return 'Email or phone is required.';
    }
    if (!_emailRegex.hasMatch(trimmed) && !isPhone) {
      return 'Enter a valid email or phone number.';
    }
    return null;
  }

  static String? password(String value) {
    if (value.isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters.';
    }
    return null;
  }

  static String? otp(String value) {
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Enter the 6-digit verification code.';
    }
    return null;
  }

  static String? confirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) {
      return 'Confirm your password.';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match.';
    }
    return null;
  }

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
}
