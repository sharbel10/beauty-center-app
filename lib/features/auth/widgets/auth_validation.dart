import 'package:beauty_center_app/l10n/generated/app_localizations.dart';

class AuthValidation {
  AuthValidation._();

  static String? fullName(String value, AppLocalizations l10n) {
    if (value.trim().length < 3) {
      return l10n.validationFullName;
    }
    return null;
  }

  static String? email(String value, AppLocalizations l10n) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return l10n.validationEmailRequired;
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return l10n.validationEmailInvalid;
    }
    return null;
  }

  static String? phone(String value, AppLocalizations l10n) {
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return l10n.validationPhoneRequired;
    }
    if (digits.length < 8 || digits.length > 15) {
      return l10n.validationPhoneInvalid;
    }
    return null;
  }

  static String? emailOrPhone(String value, AppLocalizations l10n) {
    final String trimmed = value.trim();
    final String digits = trimmed.replaceAll(RegExp(r'\D'), '');
    final bool isPhone = digits.length >= 8 && digits.length <= 15;

    if (trimmed.isEmpty) {
      return l10n.validationEmailOrPhoneRequired;
    }
    if (!_emailRegex.hasMatch(trimmed) && !isPhone) {
      return l10n.validationEmailOrPhoneInvalid;
    }
    return null;
  }

  static String? password(String value, AppLocalizations l10n) {
    if (value.isEmpty) {
      return l10n.validationPasswordRequired;
    }
    if (value.length < 6) {
      return l10n.validationPasswordLength;
    }
    return null;
  }

  static String? otp(String value, AppLocalizations l10n) {
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return l10n.validationOtp;
    }
    return null;
  }

  static String? confirmPassword(
    String password,
    String confirmPassword,
    AppLocalizations l10n,
  ) {
    if (confirmPassword.isEmpty) {
      return l10n.validationConfirmPasswordRequired;
    }
    if (password != confirmPassword) {
      return l10n.validationPasswordsDoNotMatch;
    }
    return null;
  }

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
}
