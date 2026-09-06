import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/widgets/app_bottom_navigation.dart';
import 'package:beauty_center_app/core/widgets/app_skeleton.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        96 + AppBottomNavigation.contentOverlap(context),
      ),
      children: <Widget>[
        Text(
          l10n.profileTitle,
          style: AppTextStyles.title.copyWith(fontSize: 28),
        ),
        const SizedBox(height: 24),
        const AppSkeletonShimmer(
          child: Column(
            children: <Widget>[
              Center(
                child: AppSkeletonBox(
                  width: 154,
                  height: 154,
                  borderRadius: 77,
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: AppSkeletonBox(width: 196, height: 30, borderRadius: 15),
              ),
              SizedBox(height: 9),
              Center(
                child: AppSkeletonBox(width: 238, height: 15, borderRadius: 8),
              ),
              SizedBox(height: 36),
              Row(
                children: <Widget>[
                  Expanded(child: AppSkeletonBox(height: 72, borderRadius: 16)),
                  SizedBox(width: 24),
                  Expanded(child: AppSkeletonBox(height: 72, borderRadius: 16)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _ProfileInfoSkeleton(),
        const SizedBox(height: 28),
        const AppSkeletonShimmer(
          child: AppSkeletonBox(width: 94, height: 20, borderRadius: 10),
        ),
        const SizedBox(height: 14),
        const _SettingsSkeleton(),
      ],
    );
  }
}

class _ProfileInfoSkeleton extends StatelessWidget {
  const _ProfileInfoSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: const AppSkeletonShimmer(
        child: Column(
          children: <Widget>[
            _ProfileRowSkeleton(),
            Divider(height: 1),
            _ProfileRowSkeleton(shortValue: true),
            Divider(height: 1),
            _ProfileRowSkeleton(),
          ],
        ),
      ),
    );
  }
}

class _SettingsSkeleton extends StatelessWidget {
  const _SettingsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: const AppSkeletonShimmer(
        child: Column(
          children: <Widget>[
            _ProfileRowSkeleton(shortValue: true),
            Divider(height: 1),
            _ProfileRowSkeleton(),
            Divider(height: 1),
            _ProfileRowSkeleton(shortValue: true),
          ],
        ),
      ),
    );
  }
}

class _ProfileRowSkeleton extends StatelessWidget {
  const _ProfileRowSkeleton({this.shortValue = false});

  final bool shortValue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: <Widget>[
          const AppSkeletonBox(width: 38, height: 38, borderRadius: 19),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const AppSkeletonBox(width: 72, height: 9, borderRadius: 5),
                const SizedBox(height: 7),
                FractionallySizedBox(
                  widthFactor: shortValue ? 0.45 : 0.72,
                  child: const AppSkeletonBox(height: 14, borderRadius: 7),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
