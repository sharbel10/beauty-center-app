import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Applies the app's shared shimmer treatment to a group of skeleton shapes.
class AppSkeletonShimmer extends StatefulWidget {
  const AppSkeletonShimmer({required this.child, super.key});

  final Widget child;

  @override
  State<AppSkeletonShimmer> createState() => _AppSkeletonShimmerState();
}

class _AppSkeletonShimmerState extends State<AppSkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller
        ..stop()
        ..value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: RepaintBoundary(
        child: AnimatedBuilder(
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
        ),
      ),
    );
  }
}

/// A reusable placeholder shape for loading layouts.
class AppSkeletonBox extends StatelessWidget {
  const AppSkeletonBox({
    this.width,
    required this.height,
    this.borderRadius = 8,
    super.key,
  });

  final double? width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
