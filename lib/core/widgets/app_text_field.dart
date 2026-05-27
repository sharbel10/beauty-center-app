import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    required this.hintText,
    required this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.trailingLabel,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLength,
    this.errorText,
    this.onSubmitted,
    super.key,
  });

  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final Widget? trailingLabel;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ?trailingLabel,
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          onSubmitted: onSubmitted,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            counterText: '',
            hintText: hintText,
            errorText: errorText,
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textLight,
            ),
            filled: true,
            fillColor: AppColors.white,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, color: AppColors.primary),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
