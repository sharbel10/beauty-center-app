import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';

class BookingProgressIndicator extends StatelessWidget {
  const BookingProgressIndicator({
    required this.currentStep,
    required this.onStepTapped,
    super.key,
  });

  static const List<String> _labels = <String>['Service', 'Date', 'Time'];

  final int currentStep;

  /// Called when the user taps an already-completed step to go back.
  final ValueChanged<int> onStepTapped;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (int index = 0; index < _labels.length; index++) ...<Widget>[
          if (index > 0) const SizedBox(width: 8),
          Expanded(child: _buildSegment(index)),
        ],
      ],
    );
  }

  Widget _buildSegment(int index) {
    final bool isCompleted = index < currentStep;
    final bool isActive = index == currentStep;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: isCompleted ? () => onStepTapped(index) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 4,
              decoration: BoxDecoration(
                color: isActive || isCompleted
                    ? AppColors.primary
                    : AppColors.textFaint,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (isCompleted) ...<Widget>[
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  _labels[index],
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive || isCompleted
                        ? AppColors.primary
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
