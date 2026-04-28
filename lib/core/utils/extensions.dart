import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

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
    // Unified snack style for quick user feedback across the app.
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }
}
