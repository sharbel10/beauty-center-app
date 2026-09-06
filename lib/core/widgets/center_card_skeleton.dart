import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum CenterCardSkeletonLayout { compact, expanded }

class CenterCardSkeleton extends StatelessWidget {
  const CenterCardSkeleton.compact({super.key})
    : layout = CenterCardSkeletonLayout.compact;

  const CenterCardSkeleton.expanded({super.key})
    : layout = CenterCardSkeletonLayout.expanded;

  final CenterCardSkeletonLayout layout;

  @override
  Widget build(BuildContext context) {
    return layout == CenterCardSkeletonLayout.compact
        ? const _CompactCenterCardSkeleton()
        : const _ExpandedCenterCardSkeleton();
  }
}

class _CompactCenterCardSkeleton extends StatelessWidget {
  const _CompactCenterCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return _SkeletonCard(
      borderRadius: 20,
      child: SizedBox(
        height: 188,
        child: _SkeletonShimmer(
          child: Row(
            children: <Widget>[
              const SizedBox(
                width: 108,
                height: double.infinity,
                child: ColoredBox(color: AppColors.surfaceMuted),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const _SkeletonLine(widthFactor: 0.78, height: 17),
                      const SizedBox(height: 9),
                      const _SkeletonLine(widthFactor: 0.58, height: 10),
                      const SizedBox(height: 11),
                      const _SkeletonLine(widthFactor: 0.35, height: 9),
                      const SizedBox(height: 16),
                      const _SkeletonLine(widthFactor: 0.88, height: 11),
                      const SizedBox(height: 8),
                      const _SkeletonLine(widthFactor: 0.62, height: 11),
                      const Spacer(),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: Container(
                          width: 92,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandedCenterCardSkeleton extends StatelessWidget {
  const _ExpandedCenterCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return _SkeletonCard(
      borderRadius: 16,
      child: _SkeletonShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              width: double.infinity,
              height: 176,
              child: ColoredBox(color: AppColors.surfaceMuted),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const _SkeletonLine(widthFactor: 0.66, height: 20),
                  const SizedBox(height: 11),
                  const _SkeletonLine(widthFactor: 0.9, height: 11),
                  const SizedBox(height: 7),
                  const _SkeletonLine(widthFactor: 0.7, height: 11),
                  const SizedBox(height: 16),
                  Container(
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(14),
                    ),
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

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.borderRadius, required this.child});

  final double borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.7)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x0A0A2A55),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.widthFactor, required this.height});

  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}

class _SkeletonShimmer extends StatefulWidget {
  const _SkeletonShimmer({required this.child});

  final Widget child;

  @override
  State<_SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<_SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (BuildContext context, Widget? child) {
        final double slide = (_controller.value * 3) - 1.5;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (Rect bounds) => LinearGradient(
            begin: Alignment(slide - 1, 0),
            end: Alignment(slide + 1, 0),
            colors: const <Color>[
              AppColors.surfaceMuted,
              Color(0xFFF8FAFC),
              AppColors.surfaceMuted,
            ],
            stops: const <double>[0.2, 0.5, 0.8],
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}
