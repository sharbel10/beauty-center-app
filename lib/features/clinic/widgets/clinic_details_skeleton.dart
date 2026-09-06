import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/widgets/app_skeleton.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_details_header.dart';
import 'package:flutter/material.dart';

/// Loading layout that mirrors the main clinic-details screen.
class ClinicDetailsSkeleton extends StatelessWidget {
  const ClinicDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: <Widget>[
        const SliverToBoxAdapter(child: ClinicDetailsTopBar()),
        const SliverToBoxAdapter(child: _HeroSkeleton()),
        const SliverToBoxAdapter(child: _TabsSkeleton()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
            child: AppSkeletonShimmer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const AppSkeletonBox(
                    width: 118,
                    height: 22,
                    borderRadius: 11,
                  ),
                  const SizedBox(height: 18),
                  const AppSkeletonBox(height: 14, borderRadius: 7),
                  const SizedBox(height: 9),
                  const FractionallySizedBox(
                    widthFactor: 0.82,
                    child: AppSkeletonBox(height: 14, borderRadius: 7),
                  ),
                  const SizedBox(height: 9),
                  const FractionallySizedBox(
                    widthFactor: 0.58,
                    child: AppSkeletonBox(height: 14, borderRadius: 7),
                  ),
                  const SizedBox(height: 38),
                  const AppSkeletonBox(
                    width: 102,
                    height: 22,
                    borderRadius: 11,
                  ),
                  const SizedBox(height: 18),
                  const AppSkeletonBox(height: 154, borderRadius: 16),
                  const SizedBox(height: 38),
                  const AppSkeletonBox(
                    width: 148,
                    height: 22,
                    borderRadius: 11,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 130,
                    child: Row(
                      children: <Widget>[
                        const Expanded(
                          child: AppSkeletonBox(height: 130, borderRadius: 16),
                        ),
                        const SizedBox(width: 14),
                        SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.24,
                          child: const AppSkeletonBox(
                            height: 130,
                            borderRadius: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Keeps the sticky call-to-action area from jumping when details arrive.
class ClinicDetailsBookBarSkeleton extends StatelessWidget {
  const ClinicDetailsBookBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 8,
      shadowColor: const Color(0x220A2A55),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: AppSkeletonShimmer(
          child: AppSkeletonBox(height: 58, borderRadius: 16),
        ),
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
      child: Container(
        height: 260,
        color: AppColors.surfaceMuted,
        padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.topEnd,
              child: AppSkeletonBox(width: 48, height: 48, borderRadius: 24),
            ),
            Spacer(),
            FractionallySizedBox(
              widthFactor: 0.66,
              child: AppSkeletonBox(height: 28, borderRadius: 14),
            ),
            SizedBox(height: 12),
            FractionallySizedBox(
              widthFactor: 0.8,
              child: AppSkeletonBox(height: 15, borderRadius: 8),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabsSkeleton extends StatelessWidget {
  const _TabsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: const AppSkeletonShimmer(
        child: Row(
          children: <Widget>[
            Expanded(child: AppSkeletonBox(height: 11, borderRadius: 6)),
            SizedBox(width: 24),
            Expanded(child: AppSkeletonBox(height: 11, borderRadius: 6)),
            SizedBox(width: 24),
            Expanded(child: AppSkeletonBox(height: 11, borderRadius: 6)),
            SizedBox(width: 24),
            Expanded(child: AppSkeletonBox(height: 11, borderRadius: 6)),
          ],
        ),
      ),
    );
  }
}
