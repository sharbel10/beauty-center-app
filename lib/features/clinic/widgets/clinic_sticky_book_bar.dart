import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Persistent book CTA shown above the main bottom navigation on clinic details.
class ClinicStickyBookBar extends StatelessWidget {
  const ClinicStickyBookBar({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x140A2A55),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: AppButton(text: label, onPressed: onPressed, height: 58),
        ),
      ),
    );
  }
}
