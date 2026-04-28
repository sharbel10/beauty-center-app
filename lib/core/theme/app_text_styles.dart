import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle get _baseStyle =>
      GoogleFonts.playfairDisplay(color: AppColors.textDark);

  static TextStyle get headlineLarge =>
      _baseStyle.copyWith(fontSize: 32, fontWeight: FontWeight.w700);
  static TextStyle get headlineMedium =>
      _baseStyle.copyWith(fontSize: 28, fontWeight: FontWeight.w700);
  static TextStyle get headlineSmall =>
      _baseStyle.copyWith(fontSize: 24, fontWeight: FontWeight.w600);

  static TextStyle get titleLarge =>
      _baseStyle.copyWith(fontSize: 22, fontWeight: FontWeight.w600);
  static TextStyle get titleMedium =>
      _baseStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w600);
  static TextStyle get titleSmall =>
      _baseStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w500);

  static TextStyle get bodyLarge =>
      GoogleFonts.inter(color: AppColors.textDark, fontSize: 16);
  static TextStyle get bodyMedium =>
      GoogleFonts.inter(color: AppColors.textDark, fontSize: 14);
  static TextStyle get bodySmall =>
      GoogleFonts.inter(color: AppColors.textDark, fontSize: 12);

  static TextStyle get labelLarge =>
      GoogleFonts.inter(color: AppColors.textDark, fontSize: 14);
  static TextStyle get labelSmall =>
      GoogleFonts.inter(color: AppColors.textDark, fontSize: 11);
}
