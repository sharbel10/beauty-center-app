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

class OtpView extends StatefulWidget {
  const OtpView({required AuthCubit cubit, super.key, this.initialEmail})
    : _cubit = cubit;

  final AuthCubit _cubit;
  final String? initialEmail;

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  final TextEditingController _otpController = TextEditingController();
  String? _otpError;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showAuthSnackBar(
          context,
          message: 'Email is required to proceed.',
          isError: true,
        );
        context.pop();
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _otpController.clear();
    setState(() {
      _otpError = null;
    });
  }

  Future<void> _submit() async {
    if (!_validate()) {
      return;
    }

    await widget._cubit.verifyOtp(
      email: widget.initialEmail!,
      otp: _otpController.text,
    );
  }

  Future<void> _resendCode() async {
    await widget._cubit.resendOtp(email: widget.initialEmail!);

    if (!mounted) {
      return;
    }

    final AuthState state = widget._cubit.state;
    if (state.status == AuthStatus.success) {
      showAuthSnackBar(
        context,
        message: state.message ?? 'OTP sent successfully.',
      );
    } else if (state.status == AuthStatus.failure) {
      showAuthSnackBar(
        context,
        message: state.message ?? 'Failed to resend OTP.',
        isError: true,
      );
    }
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
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == AuthStatus.success) {
            if (state.message != null) {
              showAuthSnackBar(context, message: state.message!);
            }
            final otp = _otpController.text;
            _clearFields();
            context.pushReplacementNamed(
              RouteNames.resetPassword,
              extra: {'email': widget.initialEmail!, 'otp': otp},
            );
          } else if (state.status == AuthStatus.failure) {
            final String message = state.errors != null
                ? state.errors!.values.first.first as String
                : state.message ?? 'Verification failed';
            showAuthSnackBar(context, message: message, isError: true);
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 44, 24, 28),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: BlocBuilder<AuthCubit, AuthState>(
                          builder: (BuildContext context, AuthState state) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const AuthHeader(
                                  title: 'OTP Verification',
                                  subtitle: 'Secure account recovery',
                                ),
                                const SizedBox(height: 34),
                                AuthCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(
                                        'Enter Code',
                                        style: AppTextStyles.headlineSmall,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Enter the 6-digit code sent to ${widget.initialEmail ?? "your email"}.',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: AppColors.textLight,
                                            ),
                                      ),
                                      const SizedBox(height: 28),
                                      AppTextField(
                                        label: 'Verification Code',
                                        hintText: '000000',
                                        controller: _otpController,
                                        prefixIcon: Icons.pin_rounded,
                                        errorText: _otpError,
                                        keyboardType: TextInputType.number,
                                        textInputAction: TextInputAction.done,
                                        maxLength: 6,
                                        inputFormatters: <TextInputFormatter>[
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                        ],
                                        onSubmitted: (_) {
                                          _submit();
                                        },
                                      ),
                                      const SizedBox(height: 28),
                                      AppButton(
                                        text: 'Verify Code',
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
                                    _clearFields();
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
      ),
    );
  }
}
