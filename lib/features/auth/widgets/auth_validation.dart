import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

class AuthValidation {
  AuthValidation._();

  static String? fullName(BuildContext context, String value) {
    if (value.trim().length < 3) {
      return AppLocalizations.of(context).validationFullName;
    }
    return null;
  }

  static String? email(BuildContext context, String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return AppLocalizations.of(context).validationEmailRequired;
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return AppLocalizations.of(context).validationEmailInvalid;
    }
    return null;
  }

  static String? phone(BuildContext context, String value) {
    final String digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return AppLocalizations.of(context).validationPhoneRequired;
    }
    if (digits.length < 8 || digits.length > 15) {
      return AppLocalizations.of(context).validationPhoneInvalid;
    }
    return null;
  }

  static String? emailOrPhone(BuildContext context, String value) {
    final String trimmed = value.trim();
    final String digits = trimmed.replaceAll(RegExp(r'\D'), '');
    final bool isPhone = digits.length >= 8 && digits.length <= 15;

    if (trimmed.isEmpty) {
      return AppLocalizations.of(context).validationEmailOrPhoneRequired;
    }
    if (!_emailRegex.hasMatch(trimmed) && !isPhone) {
      return AppLocalizations.of(context).validationEmailOrPhoneInvalid;
    }
    return null;
  }

  static String? password(BuildContext context, String value) {
    if (value.isEmpty) {
      return AppLocalizations.of(context).validationPasswordRequired;
    }
    if (value.length < 6) {
      return AppLocalizations.of(context).validationPasswordLength;
    }
    return null;
  }

  static String? otp(BuildContext context, String value) {
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return AppLocalizations.of(context).validationOtp;
    }
    return null;
  }

  static String? confirmPassword(
    BuildContext context,
    String password,
    String confirmPassword,
  ) {
    if (confirmPassword.isEmpty) {
      return AppLocalizations.of(context).validationConfirmPasswordRequired;
    }
    if (password != confirmPassword) {
      return AppLocalizations.of(context).validationPasswordsDoNotMatch;
    }
    return null;
  }

  static final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  );
}
