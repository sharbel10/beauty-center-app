import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/widgets/app_bottom_navigation.dart';
import 'package:beauty_center_app/core/widgets/app_skeleton.dart';
import 'package:flutter/material.dart';

class AppointmentsSkeleton extends StatelessWidget {
  const AppointmentsSkeleton({required this.isPast, super.key});

  final bool isPast;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + AppBottomNavigation.contentOverlap(context),
      ),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return const AppSkeletonShimmer(
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: AppSkeletonBox(width: 82, height: 11, borderRadius: 6),
            ),
          );
        }
        return _AppointmentCardSkeleton(isPast: isPast);
      },
    );
  }
}

class _AppointmentCardSkeleton extends StatelessWidget {
  const _AppointmentCardSkeleton({required this.isPast});

  final bool isPast;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: AppSkeletonShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const <Widget>[
                      AppSkeletonBox(width: 78, height: 24, borderRadius: 12),
                      SizedBox(height: 12),
                      AppSkeletonBox(height: 16, borderRadius: 8),
                      SizedBox(height: 7),
                      FractionallySizedBox(
                        widthFactor: 0.7,
                        child: AppSkeletonBox(height: 12, borderRadius: 6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const AppSkeletonBox(width: 72, height: 72, borderRadius: 12),
              ],
            ),
            const SizedBox(height: 14),
            if (!isPast) const Divider(height: 1, color: AppColors.divider),
            if (!isPast) const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: isPast
                  ? const EdgeInsets.symmetric(horizontal: 12, vertical: 12)
                  : EdgeInsets.zero,
              decoration: isPast
                  ? BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                    )
                  : null,
              child: const Row(
                children: <Widget>[
                  AppSkeletonBox(width: 92, height: 13, borderRadius: 7),
                  SizedBox(width: 16),
                  AppSkeletonBox(width: 68, height: 13, borderRadius: 7),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                const Expanded(
                  child: AppSkeletonBox(height: 44, borderRadius: 12),
                ),
                const SizedBox(width: 8),
                if (isPast)
                  const Expanded(
                    child: AppSkeletonBox(height: 44, borderRadius: 12),
                  )
                else
                  const AppSkeletonBox(width: 44, height: 44, borderRadius: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
