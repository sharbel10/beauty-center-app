import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

extension StringExtensions on String {
  bool get isValidEmail {
    // Lightweight email check for client-side form validation only.
    const String emailPattern =
        r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
    return RegExp(emailPattern).hasMatch(trim());
  }

  bool get isValidPhone {
    // Accepts common Syrian mobile formats: +9639..., 009639..., or 09....
    final String normalized = replaceAll(' ', '');
    const String syrianPhonePattern = r'^(?:\+963|00963|0)?9\d{8}$';
    return RegExp(syrianPhonePattern).hasMatch(normalized);
  }

  String get capitalize {
    if (trim().isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension ContextExtensions on BuildContext {
  // Shorthand getters to reduce repetitive MediaQuery/Theme boilerplate.
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  void showSnackbar(String message, {bool isError = false}) {
    final String trimmed = message.trim();
    if (trimmed.isEmpty) {
      return;
    }

    toastification.dismissAll();
    toastification.show(
      context: this,
      type: isError ? ToastificationType.error : ToastificationType.success,
      style: ToastificationStyle.fillColored,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      title: Text(
        trimmed,
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
          height: 1.35,
        ),
      ),
      icon: Icon(
        isError ? Icons.error_outline_rounded : Icons.check_circle_rounded,
        color: AppColors.white,
      ),
      primaryColor: isError ? AppColors.error : AppColors.success,
      backgroundColor: isError ? AppColors.error : AppColors.success,
      foregroundColor: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      borderRadius: BorderRadius.circular(14),
      showProgressBar: false,
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
    );
  }
}
