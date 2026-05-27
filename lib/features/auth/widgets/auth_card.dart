import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AuthCard extends StatelessWidget {
  const AuthCard({
    required this.child,
    this.padding = const EdgeInsets.all(28),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x161F3A5F),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
