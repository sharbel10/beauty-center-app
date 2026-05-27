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
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
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
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _emailController.clear();
    setState(() {
      _emailError = null;
    });
  }

  Future<void> _submit() async {
    if (!_validate()) {
      return;
    }

    await widget._cubit.forgotPassword(login: _emailController.text.trim());

    if (!mounted) {
      return;
    }

    final AuthState state = widget._cubit.state;
    if (state.status == AuthStatus.success) {
      showAuthSnackBar(context, message: state.message!);
      final email = _emailController.text.trim();
      _clearFields();
      context.pushReplacementNamed(RouteNames.verifyOtp, extra: email);
    } else if (state.status == AuthStatus.failure) {
      final String message = state.errors != null
          ? state.errors!.values.first.first as String
          : state.message ?? AppLocalizations.of(context).requestFailed;
      showAuthSnackBar(context, message: message, isError: true);
    }
  }

  bool _validate() {
    final String? emailError = AuthValidation.email(
      context,
      _emailController.text,
    );

    setState(() {
      _emailError = emailError;
    });

    if (emailError != null) {
      showAuthSnackBar(context, message: emailError, isError: true);
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

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
                        buildWhen: (AuthState previous, AuthState current) =>
                            previous.isSubmitting != current.isSubmitting,
                        builder: (BuildContext context, AuthState state) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              AuthHeader(
                                title: l10n.forgotPassword,
                                subtitle: l10n.recoverYourAccount,
                              ),
                              const SizedBox(height: 34),
                              AuthCard(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    Text(
                                      l10n.sendVerificationCode,
                                      style: AppTextStyles.headlineSmall,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      l10n.enterYourEmailAddress,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.textLight,
                                      ),
                                    ),
                                    const SizedBox(height: 28),
                                    AppTextField(
                                      label: l10n.emailAddress,
                                      hintText: l10n.emailHint,
                                      controller: _emailController,
                                      prefixIcon: Icons.alternate_email_rounded,
                                      errorText: _emailError,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) {
                                        _submit();
                                      },
                                    ),
                                    const SizedBox(height: 28),
                                    AppButton(
                                      text: l10n.sendCode,
                                      isLoading: state.isSubmitting,
                                      onPressed: _submit,
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
                                child: Text(l10n.backToLogin),
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
