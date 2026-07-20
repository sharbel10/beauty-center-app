import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class BookingProgressIndicator extends StatelessWidget {
  const BookingProgressIndicator({
    required this.currentStep,
    required this.onStepTapped,
    super.key,
  });

  final int currentStep;

  /// Called when the user taps an already-completed step to go back.
  final ValueChanged<int> onStepTapped;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> labels = <String>[
      l10n.serviceLabel,
      l10n.dateLabel,
      l10n.timeLabel,
    ];

    return Row(
      children: <Widget>[
        for (int index = 0; index < labels.length; index++) ...<Widget>[
          if (index > 0) const SizedBox(width: 8),
          Expanded(child: _buildSegment(index, labels[index])),
        ],
      ],
    );
  }

  Widget _buildSegment(int index, String label) {
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
                  label,
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
