import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/widgets/app_skeleton.dart';
import 'package:flutter/material.dart';

class NotificationsSkeleton extends StatelessWidget {
  const NotificationsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, _) => const _NotificationCardSkeleton(),
    );
  }
}

class _NotificationCardSkeleton extends StatelessWidget {
  const _NotificationCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.85)),
      ),
      child: AppSkeletonShimmer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const AppSkeletonBox(width: 44, height: 44, borderRadius: 13),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  FractionallySizedBox(
                    widthFactor: 0.55,
                    child: AppSkeletonBox(height: 15, borderRadius: 8),
                  ),
                  SizedBox(height: 9),
                  AppSkeletonBox(height: 11, borderRadius: 6),
                  SizedBox(height: 7),
                  FractionallySizedBox(
                    widthFactor: 0.78,
                    child: AppSkeletonBox(height: 11, borderRadius: 6),
                  ),
                  SizedBox(height: 10),
                  FractionallySizedBox(
                    widthFactor: 0.28,
                    child: AppSkeletonBox(height: 10, borderRadius: 6),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
