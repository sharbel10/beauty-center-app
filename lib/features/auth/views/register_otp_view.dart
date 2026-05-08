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
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class RegisterOtpView extends StatefulWidget {
  const RegisterOtpView({required AuthCubit cubit, super.key}) : _cubit = cubit;

  final AuthCubit _cubit;

  @override
  State<RegisterOtpView> createState() => _RegisterOtpViewState();
}

class _RegisterOtpViewState extends State<RegisterOtpView> {
  final TextEditingController _otpController = TextEditingController();
  String? _otpError;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_validate()) {
      return;
    }

    await widget._cubit.verifyRegistrationOtp();

    if (!mounted) {
      return;
    }

    showAuthSnackBar(context, message: 'Account verified successfully.');
  }

  Future<void> _resendCode() async {
    await widget._cubit.resendRegistrationCode();

    if (!mounted) {
      return;
    }

    showAuthSnackBar(context, message: 'Registration code sent.');
  }

  bool _validate() {
    final String? otpError = AuthValidation.otp(_otpController.text);

    setState(() {
      _otpError = otpError;
    });

    if (otpError != null) {
      showAuthSnackBar(context, message: otpError, isError: true);
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
                                title: 'Verify Account',
                                subtitle: 'Complete your registration',
                              ),
                              const SizedBox(height: 34),
                              AuthCard(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      'Registration Code',
                                      style: AppTextStyles.headlineSmall,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Enter the 6-digit code sent after creating your account.',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    AppTextField(
                                      label: 'Verification Code',
                                      hintText: '000000',
                                      controller: _otpController,
                                      prefixIcon: Icons.mark_email_read_rounded,
                                      errorText: _otpError,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.done,
                                      maxLength: 6,
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onSubmitted: (_) {
                                        _submit();
                                      },
                                    ),
                                    const SizedBox(height: 28),
                                    AppButton(
                                      text: 'Verify Account',
                                      isLoading: state.isSubmitting,
                                      onPressed: _submit,
                                    ),
                                    const SizedBox(height: 14),
                                    TextButton(
                                      onPressed: state.isSubmitting
                                          ? null
                                          : _resendCode,
                                      child: const Text('Resend code'),
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
