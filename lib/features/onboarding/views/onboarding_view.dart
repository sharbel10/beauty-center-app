import 'dart:math' as math;

import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/widgets/app_button.dart';
import 'package:beauty_center_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:beauty_center_app/features/onboarding/cubit/onboarding_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({required OnboardingCubit cubit, super.key})
    : _cubit = cubit;

  final OnboardingCubit _cubit;

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_OnboardingData> _pages = <_OnboardingData>[
    _OnboardingData(
      navTitle: 'Discover Clinics',
      imageUrl:
          'https://images.pexels.com/photos/3997988/pexels-photo-3997988.jpeg?auto=compress&cs=tinysrgb&w=1400',
      title: 'Find trusted beauty centers near you.',
      subtitle:
          'Explore services, specialists, and available appointments from one place.',
    ),
    _OnboardingData(
      navTitle: 'Book Visits',
      imageUrl:
          'https://images.pexels.com/photos/3985360/pexels-photo-3985360.jpeg?auto=compress&cs=tinysrgb&w=1400',
      title: 'Schedule your care without extra calls.',
      subtitle:
          'Choose your treatment, pick a time, and keep your booking details organized.',
    ),
    _OnboardingData(
      navTitle: 'Personal Care',
      imageUrl:
          'https://images.pexels.com/photos/5069432/pexels-photo-5069432.jpeg?auto=compress&cs=tinysrgb&w=1400',
      title: 'Track your beauty journey clearly.',
      subtitle:
          'Review appointments and follow-up notes in a simple patient experience.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _finish();
      return;
    }

    _pageController.animateToPage(
      _currentPage + 1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _finish() {
    widget._cubit.completeOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingCubit>.value(
      value: widget._cubit,
      child: BlocListener<OnboardingCubit, OnboardingState>(
        listenWhen: (OnboardingState previous, OnboardingState current) =>
            previous.isCompleted != current.isCompleted && current.isCompleted,
        listener: (BuildContext context, OnboardingState state) {
          context.goNamed(RouteNames.login);
        },
        child: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
              child: Column(
                children: <Widget>[
                  _OnboardingTopBar(
                    title: _pages[_currentPage].navTitle,
                    onSkip: _finish,
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (int index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemBuilder: (BuildContext context, int index) {
                        return _OnboardingPage(data: _pages[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 18),
                  _OnboardingIndicator(
                    count: _pages.length,
                    currentIndex: _currentPage,
                  ),
                  const SizedBox(height: 28),
                  AppButton(
                    text: _currentPage == _pages.length - 1
                        ? 'Get Started'
                        : 'Next',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: _next,
                    height: 60,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingTopBar extends StatelessWidget {
  const _OnboardingTopBar({required this.title, required this.onSkip});

  final String title;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: <Widget>[
          const SizedBox(width: 64),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.titleLarge,
            ),
          ),
          SizedBox(
            width: 64,
            child: TextButton(
              onPressed: onSkip,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                foregroundColor: AppColors.textLight,
              ),
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({required this.data});

  final _OnboardingData data;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double imageHeight = math.min(
          420.0,
          math.max(260.0, constraints.maxHeight * 0.52),
        );

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[
              _ClinicImageCard(imageUrl: data.imageUrl, height: imageHeight),
              const SizedBox(height: 32),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineMedium,
              ),
              const SizedBox(height: 18),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textLight,
                  height: 1.45,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ClinicImageCard extends StatelessWidget {
  const _ClinicImageCard({required this.imageUrl, required this.height});

  final String imageUrl;
  final double height;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x161F3A5F),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: double.infinity,
          height: height,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) {
              return Container(
                color: AppColors.neutral,
                child: const Icon(
                  Icons.spa_rounded,
                  color: AppColors.textLight,
                  size: 72,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _OnboardingIndicator extends StatelessWidget {
  const _OnboardingIndicator({required this.count, required this.currentIndex});

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        final bool isActive = index == currentIndex;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          width: isActive ? 36 : 12,
          height: 12,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.textLight,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }
}

class _OnboardingData {
  const _OnboardingData({
    required this.navTitle,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
  });

  final String navTitle;
  final String imageUrl;
  final String title;
  final String subtitle;
}
