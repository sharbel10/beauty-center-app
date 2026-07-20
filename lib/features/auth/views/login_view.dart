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

class LoginView extends StatefulWidget {
  const LoginView({required AuthCubit cubit, super.key}) : _cubit = cubit;

  final AuthCubit _cubit;

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _emailController.clear();
    _passwordController.clear();
    setState(() {
      _emailError = null;
      _passwordError = null;
    });
  }

  Future<void> _submit() async {
    if (!_validate()) {
      return;
    }

    await widget._cubit.login(
      login: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  bool _validate() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? emailError = AuthValidation.email(
      _emailController.text,
      l10n,
    );
    final String? passwordError = AuthValidation.password(
      _passwordController.text,
      l10n,
    );

    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });

    if (emailError != null || passwordError != null) {
      showAuthSnackBar(
        context,
        message: emailError ?? passwordError ?? l10n.checkEnteredData,
        isError: true,
      );
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
        listenWhen: (AuthState previous, AuthState current) =>
            previous.status != current.status ||
            previous.isAuthenticated != current.isAuthenticated,
        listener: (BuildContext context, AuthState state) {
          final AppLocalizations l10n = AppLocalizations.of(context);
          if (state.status == AuthStatus.success) {
            if (state.message != null) {
              showAuthSnackBar(context, message: state.message!);
            }
            if (state.isAuthenticated) {
              context.goNamed(RouteNames.home);
            }
          } else if (state.status == AuthStatus.failure) {
            final String message = state.errors != null
                ? state.errors!.values.first.first as String
                : state.message ?? l10n.loginFailed;

            if (message == 'Email verification is required before login.') {
              final String email = _emailController.text.trim();

              showAuthSnackBar(context, message: message);
              _clearFields();
              context.pushReplacementNamed(
                RouteNames.registerOtp,
                extra: email,
              );
            } else {
              showAuthSnackBar(context, message: message, isError: true);
            }
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
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
                                  title: l10n.lumina,
                                  subtitle: l10n.signInToContinue,
                                ),
                                const SizedBox(height: 36),
                                AuthCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      Text(
                                        l10n.login,
                                        style: AppTextStyles.headlineSmall,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.accessYourLuminaAccount,
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: AppColors.textLight,
                                            ),
                                      ),
                                      const SizedBox(height: 28),
                                      AppTextField(
                                        label: l10n.emailAddress,
                                        hintText: l10n.emailHint,
                                        controller: _emailController,
                                        prefixIcon: Icons.email_rounded,
                                        errorText: _emailError,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 22),
                                      AppTextField(
                                        label: l10n.password,
                                        hintText: l10n.enterYourPassword,
                                        controller: _passwordController,
                                        prefixIcon: Icons.lock_rounded,
                                        obscureText: _obscurePassword,
                                        errorText: _passwordError,
                                        textInputAction: TextInputAction.done,
                                        // onSubmitted: (_) {
                                        //   _submit();
                                        // },
                                        trailingLabel: TextButton(
                                          onPressed: () {
                                            _clearFields();
                                            context.pushNamed(
                                              RouteNames.forgotPassword,
                                            );
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          child: Text(
                                            l10n.forgotPasswordQuestion,
                                          ),
                                        ),
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
                                      const SizedBox(height: 18),
                                      Row(
                                        children: <Widget>[
                                          SizedBox(
                                            width: 28,
                                            height: 28,
                                            child: Checkbox(
                                              value: _rememberMe,
                                              onChanged: (bool? value) {
                                                setState(() {
                                                  _rememberMe = value ?? false;
                                                });
                                              },
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              l10n.rememberMe,
                                              style: AppTextStyles.bodyMedium,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 26),
                                      AppButton(
                                        text: l10n.login,
                                        isLoading: state.isSubmitting,
                                        onPressed: _submit,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 26),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      l10n.dontHaveAccount,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _clearFields();
                                        context.pushNamed(RouteNames.register);
                                      },
                                      child: Text(l10n.register),
                                    ),
                                  ],
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
