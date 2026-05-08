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

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({required AuthCubit cubit, super.key})
    : _cubit = cubit;

  final AuthCubit _cubit;

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _phoneOrEmailController = TextEditingController();
  String? _phoneOrEmailError;

  @override
  void dispose() {
    _phoneOrEmailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_validate()) {
      return;
    }

    await widget._cubit.sendPasswordResetCode();

    if (!mounted) {
      return;
    }

    showAuthSnackBar(context, message: 'Verification code sent.');
    context.pushNamed(RouteNames.verifyOtp);
  }

  bool _validate() {
    final String? phoneOrEmailError = AuthValidation.emailOrPhone(
      _phoneOrEmailController.text,
    );

    setState(() {
      _phoneOrEmailError = phoneOrEmailError;
    });

    if (phoneOrEmailError != null) {
      showAuthSnackBar(context, message: phoneOrEmailError, isError: true);
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
                                title: 'Forgot Password',
                                subtitle: 'Recover your account',
                              ),
                              const SizedBox(height: 34),
                              AuthCard(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      'Send Verification Code',
                                      style: AppTextStyles.headlineSmall,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Enter your email address or phone number.',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    AppTextField(
                                      label: 'Email or Phone',
                                      hintText: 'name@example.com',
                                      controller: _phoneOrEmailController,
                                      prefixIcon: Icons.alternate_email_rounded,
                                      errorText: _phoneOrEmailError,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) {
                                        _submit();
                                      },
                                    ),
                                    const SizedBox(height: 28),
                                    AppButton(
                                      text: 'Send Code',
                                      isLoading: state.isSubmitting,
                                      onPressed: _submit,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextButton(
                                onPressed: () {
                                  context.goNamed(RouteNames.login);
                                },
                                child: const Text('Back to Login'),
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
