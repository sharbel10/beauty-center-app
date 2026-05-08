import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/widgets/app_button.dart';
import 'package:beauty_center_app/core/widgets/app_text_field.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_cubit.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_state.dart';
import 'package:beauty_center_app/features/auth/widgets/auth_card.dart';
import 'package:beauty_center_app/features/auth/widgets/auth_feedback.dart';
import 'package:beauty_center_app/features/auth/widgets/auth_header.dart';
import 'package:beauty_center_app/features/auth/widgets/auth_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({required AuthCubit cubit, super.key})
    : _cubit = cubit;

  final AuthCubit _cubit;

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_validate()) {
      return;
    }

    await widget._cubit.resetPassword();

    if (!mounted) {
      return;
    }

    showAuthSnackBar(context, message: 'Password reset successfully.');
    context.goNamed(RouteNames.login);
  }

  bool _validate() {
    final String? passwordError = AuthValidation.password(
      _passwordController.text,
    );
    final String? confirmPasswordError = AuthValidation.confirmPassword(
      _passwordController.text,
      _confirmPasswordController.text,
    );

    setState(() {
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });

    final String? firstError = passwordError ?? confirmPasswordError;
    if (firstError != null) {
      showAuthSnackBar(context, message: firstError, isError: true);
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>.value(
      value: widget._cubit,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 44, 24, 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 430),
                      child: BlocBuilder<AuthCubit, AuthState>(
                        builder: (BuildContext context, AuthState state) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const AuthHeader(
                                title: 'Reset Password',
                                subtitle: 'Create a new password',
                              ),
                              const SizedBox(height: 34),
                              AuthCard(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      'New Password',
                                      style: AppTextStyles.headlineSmall,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Choose a password for your account.',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    AppTextField(
                                      label: 'New Password',
                                      hintText: 'Enter new password',
                                      controller: _passwordController,
                                      prefixIcon: Icons.lock_rounded,
                                      obscureText: _obscurePassword,
                                      errorText: _passwordError,
                                      textInputAction: TextInputAction.next,
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 22),
                                    AppTextField(
                                      label: 'Confirm Password',
                                      hintText: 'Confirm new password',
                                      controller: _confirmPasswordController,
                                      prefixIcon: Icons.lock_reset_rounded,
                                      obscureText: _obscureConfirmPassword,
                                      errorText: _confirmPasswordError,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) {
                                        _submit();
                                      },
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_rounded
                                              : Icons.visibility_off_rounded,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    AppButton(
                                      text: 'Reset Password',
                                      isLoading: state.isSubmitting,
                                      onPressed: _submit,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
