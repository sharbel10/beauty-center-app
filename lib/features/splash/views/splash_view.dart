import 'package:beauty_center_app/features/splash/cubit/splash_cubit.dart';
import 'package:beauty_center_app/features/splash/cubit/splash_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashView extends StatefulWidget {
  const SplashView({required SplashCubit cubit, super.key}) : _cubit = cubit;

  final SplashCubit _cubit;

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    widget._cubit.resolveStartupRoute();
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
        child: const Scaffold(
          body: Center(child: Text('Splash Page')),
        ),
      ),
    );
  }
}
