import 'package:beauty_center_app/features/splash/cubit/splash_cubit.dart';
import 'package:beauty_center_app/features/splash/cubit/splash_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashView extends StatefulWidget {
  const SplashView({required SplashCubit cubit, super.key}) : _cubit = cubit;

  final SplashCubit _cubit;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _progressAnimation =
        Tween<double>(begin: 0, end: 1).animate(_progressController)
          ..addListener(() {
            setState(() {});
          });
    _progressController.forward();
    widget._cubit.resolveStartupRoute();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SplashCubit>.value(
      value: widget._cubit,
      child: BlocListener<SplashCubit, SplashState>(
        listenWhen: (SplashState previous, SplashState current) =>
            previous.nextRouteName != current.nextRouteName &&
            current.nextRouteName != null,
        listener: (BuildContext context, SplashState state) {
          final String? routeName = state.nextRouteName;
          if (routeName != null) {
            context.goNamed(routeName);
          }
        },
        child: Scaffold(
          // backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                // Logo Top
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 80,
                      height: 80,
                      cacheWidth: 80,
                      cacheHeight: 80,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Title
                Text(
                  'LUMINA',
                  style: GoogleFonts.cinzel(
                    fontSize: 42,
                    letterSpacing: 12,
                    color: const Color(0xFF1A3355),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle with line
                SizedBox(
                  width: 200,
                  child: Column(
                    children: [
                      const Divider(thickness: 1, color: Colors.black26),
                      Text(
                        'AESTHETIC CLINIC',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          letterSpacing: 4,
                          color: const Color(0xFF1A3355).withOpacity(0.7),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Middle Image
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constraints) {
                      final int? splashDecodeWidth =
                          constraints.maxWidth.isFinite &&
                              constraints.maxWidth > 0
                          ? constraints.maxWidth.round().clamp(1, 8192)
                          : null;
                      return Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/images/splash.png',
                              height: 220,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              cacheWidth: splashDecodeWidth,
                              cacheHeight: 220,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'EXCELLENCE IN CARE',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const Spacer(),
                // Progress Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'INITIALIZING SECURE ACCESS',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1A3355).withOpacity(0.5),
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            '${(_progressAnimation.value * 100).toInt()}%',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A3355),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: _progressAnimation.value,
                          minHeight: 6,
                          backgroundColor: const Color(0xFFE5E9F0),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF1A3355),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      size: 14,
                      color: Color(0xFF1A3355),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'MEDICAL GRADE SECURITY',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF1A3355).withOpacity(0.5),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF2F2F2)
      ..strokeWidth = 1;

    const double step = 40;

    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
