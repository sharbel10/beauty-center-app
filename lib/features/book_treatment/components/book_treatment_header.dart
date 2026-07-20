import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class BookTreatmentHeader extends StatelessWidget {
  const BookTreatmentHeader({required this.onBackPressed, super.key});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 44,
            height: 44,
            child: IconButton(
              onPressed: onBackPressed,
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.primary,
              iconSize: 24,
            ),
          ),
          Expanded(
            child: Text(
              'Book Treatment',
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(fontSize: 20),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }
}
