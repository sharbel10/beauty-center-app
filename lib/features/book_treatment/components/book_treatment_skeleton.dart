import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/widgets/app_skeleton.dart';
import 'package:flutter/material.dart';

/// Initial loading layout for the booking flow.
class BookTreatmentSkeleton extends StatelessWidget {
  const BookTreatmentSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppSkeletonShimmer(
      child: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
            child: Row(
              children: <Widget>[
                Expanded(child: _ProgressSegmentSkeleton()),
                SizedBox(width: 8),
                Expanded(child: _ProgressSegmentSkeleton()),
                SizedBox(width: 8),
                Expanded(child: _ProgressSegmentSkeleton()),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: const <Widget>[
                AppSkeletonBox(width: 148, height: 24, borderRadius: 12),
                SizedBox(height: 10),
                AppSkeletonBox(width: 222, height: 13, borderRadius: 7),
                SizedBox(height: 18),
                _CategorySkeleton(expanded: true),
                SizedBox(height: 10),
                _CategorySkeleton(),
                SizedBox(height: 10),
                _CategorySkeleton(),
                SizedBox(height: 28),
                AppSkeletonBox(width: 136, height: 22, borderRadius: 11),
                SizedBox(height: 10),
                AppSkeletonBox(width: 208, height: 13, borderRadius: 7),
                SizedBox(height: 18),
                _SpecialistsSkeleton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading placeholder for the booking flow's sticky action bar.
class BookTreatmentBottomBarSkeleton extends StatelessWidget {
  const BookTreatmentBottomBarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.divider)),
        ),
        child: const AppSkeletonShimmer(
          child: AppSkeletonBox(height: 54, borderRadius: 16),
        ),
      ),
    );
  }
}

class _ProgressSegmentSkeleton extends StatelessWidget {
  const _ProgressSegmentSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppSkeletonBox(height: 4, borderRadius: 4),
        SizedBox(height: 8),
        AppSkeletonBox(width: 54, height: 11, borderRadius: 6),
      ],
    );
  }
}

class _CategorySkeleton extends StatelessWidget {
  const _CategorySkeleton({this.expanded = false});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        children: <Widget>[
          const Row(
            children: <Widget>[
              Expanded(child: AppSkeletonBox(height: 15, borderRadius: 8)),
              SizedBox(width: 36),
              AppSkeletonBox(width: 28, height: 18, borderRadius: 9),
              SizedBox(width: 10),
              AppSkeletonBox(width: 20, height: 20, borderRadius: 10),
            ],
          ),
          if (expanded) ...<Widget>[
            const SizedBox(height: 15),
            const Divider(height: 1, color: AppColors.divider),
            const SizedBox(height: 14),
            const Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      AppSkeletonBox(height: 14, borderRadius: 7),
                      SizedBox(height: 7),
                      AppSkeletonBox(width: 124, height: 11, borderRadius: 6),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                AppSkeletonBox(width: 20, height: 20, borderRadius: 10),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SpecialistsSkeleton extends StatelessWidget {
  const _SpecialistsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 92,
      child: Row(
        children: <Widget>[
          _SpecialistSkeleton(),
          SizedBox(width: 18),
          _SpecialistSkeleton(),
          SizedBox(width: 18),
          _SpecialistSkeleton(),
          SizedBox(width: 18),
          _SpecialistSkeleton(),
        ],
      ),
    );
  }
}

class _SpecialistSkeleton extends StatelessWidget {
  const _SpecialistSkeleton();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 60,
      child: Column(
        children: <Widget>[
          AppSkeletonBox(width: 60, height: 60, borderRadius: 30),
          SizedBox(height: 8),
          AppSkeletonBox(width: 52, height: 10, borderRadius: 5),
        ],
      ),
    );
  }
}
