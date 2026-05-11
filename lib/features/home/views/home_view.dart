import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_cubit.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatelessWidget {
  const HomeView({required AuthCubit cubit, super.key}) : _cubit = cubit;

  final AuthCubit _cubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: _cubit,
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (AuthState previous, AuthState current) =>
            previous.isAuthenticated != current.isAuthenticated &&
            !current.isAuthenticated,
        listener: (BuildContext context, AuthState state) {
          context.goNamed(RouteNames.login);
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Home')),
          body: BlocBuilder<AuthCubit, AuthState>(
            buildWhen: (AuthState previous, AuthState current) =>
                previous.isSubmitting != current.isSubmitting,
            builder: (context, state) {
              return Center(
                child: state.isSubmitting
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: () => _cubit.logout(),
                        child: const Text('Logout'),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
