import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/features/onboarding/cubit/onboarding_cubit.dart';
import 'package:beauty_center_app/features/onboarding/cubit/onboarding_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OnboardingView extends StatelessWidget {
  const OnboardingView({required OnboardingCubit cubit, super.key})
      : _cubit = cubit;

  final OnboardingCubit _cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<OnboardingCubit>.value(
      value: _cubit,
      child: BlocListener<OnboardingCubit, OnboardingState>(
        listenWhen: (OnboardingState previous, OnboardingState current) =>
            previous.isCompleted != current.isCompleted &&
            current.isCompleted,
        listener: (BuildContext context, OnboardingState state) {
          context.goNamed(RouteNames.login);
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Onboarding')),
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.read<OnboardingCubit>().completeOnboarding(),
              child: const Text('Finish Onboarding'),
            ),
          ),
        ),
      ),
    );
  }
}
