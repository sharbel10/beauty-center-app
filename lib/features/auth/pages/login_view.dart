import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:beauty_center_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatelessWidget {
  const LoginView({required AuthCubit cubit, super.key}) : _cubit = cubit;

  final AuthCubit _cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: _cubit,
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (AuthState previous, AuthState current) =>
            previous.isAuthenticated != current.isAuthenticated &&
            current.isAuthenticated,
        listener: (BuildContext context, AuthState state) {
          context.goNamed(RouteNames.home);
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Login')),
          body: Center(
            child: ElevatedButton(
              onPressed: () => context.read<AuthCubit>().login(),
              child: const Text('Login (Placeholder)'),
            ),
          ),
        ),
      ),
    );
  }
}
