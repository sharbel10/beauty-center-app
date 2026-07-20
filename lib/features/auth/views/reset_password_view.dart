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

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({
    required AuthCubit cubit,
    required this.email,
    required this.otp,
    super.key,
  }) : _cubit = cubit;

  final AuthCubit _cubit;
  final String email;
  final String otp;

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

  void _clearFields() {
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
    });
  }

  Future<void> _submit() async {
    if (!_validate()) {
      return;
    }

    await widget._cubit.resetPassword(
      login: widget.email,
      otp: widget.otp,
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );
  }

  bool _validate() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? passwordError = AuthValidation.password(
      _passwordController.text,
      l10n,
    );
    final String? confirmPasswordError = AuthValidation.confirmPassword(
      _passwordController.text,
      _confirmPasswordController.text,
      l10n,
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
    final AppLocalizations l10n = AppLocalizations.of(context);

    return BlocProvider<AuthCubit>.value(
      value: widget._cubit,
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          final AppLocalizations l10n = AppLocalizations.of(context);
          if (state.status == AuthStatus.success) {
            if (state.message != null) {
              showAuthSnackBar(context, message: state.message!);
            }
            _clearFields();
            context.goNamed(RouteNames.login);
          } else if (state.status == AuthStatus.failure) {
            final String message = state.errors != null
                ? state.errors!.values.first.first as String
                : state.message ?? l10n.resetFailed;
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
                          buildWhen: (AuthState previous, AuthState current) =>
                              previous.isSubmitting != current.isSubmitting,
                          builder: (BuildContext context, AuthState state) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                AuthHeader(
                                  title: l10n.resetPassword,
                                  subtitle: l10n.createNewPassword,
                                ),
                                const SizedBox(height: 34),
                                AuthCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(
                                        l10n.newPassword,
                                        style: AppTextStyles.headlineSmall,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        l10n.choosePasswordForAccount,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: AppColors.textLight,
                                            ),
                                      ),
                                      const SizedBox(height: 28),
                                      AppTextField(
                                        label: l10n.newPassword,
                                        hintText: l10n.enterNewPassword,
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
                                        label: l10n.confirmPassword,
                                        hintText: l10n.confirmNewPassword,
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
                                        text: l10n.resetPassword,
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
      ),
    );
  }
}
