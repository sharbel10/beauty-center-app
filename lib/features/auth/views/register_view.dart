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

class RegisterView extends StatefulWidget {
  const RegisterView({required AuthCubit cubit, super.key}) : _cubit = cubit;

  final AuthCubit _cubit;

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _fullNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearFields() {
    _fullNameController.clear();
    _emailController.clear();
    _phoneController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    setState(() {
      _fullNameError = null;
      _emailError = null;
      _phoneError = null;
      _passwordError = null;
      _confirmPasswordError = null;
    });
  }

  Future<void> _submit() async {
    if (!_validate()) {
      return;
    }

    await widget._cubit.register(
      name: _fullNameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );
  }

  bool _validate() {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? fullNameError = AuthValidation.fullName(
      context,
      _fullNameController.text,
    );
    final String? emailError = AuthValidation.email(
      context,
      _emailController.text,
    );
    final String? phoneError = AuthValidation.phone(
      context,
      _phoneController.text,
    );
    final String? passwordError = AuthValidation.password(
      context,
      _passwordController.text,
    );
    final String? confirmPasswordError = AuthValidation.confirmPassword(
      context,
      _passwordController.text,
      _confirmPasswordController.text,
    );

    setState(() {
      _fullNameError = fullNameError;
      _emailError = emailError;
      _phoneError = phoneError;
      _passwordError = passwordError;
      _confirmPasswordError = confirmPasswordError;
    });

    final String? firstError =
        fullNameError ??
        emailError ??
        phoneError ??
        passwordError ??
        confirmPasswordError;
    if (firstError != null) {
      showAuthSnackBar(
        context,
        message: firstError.isEmpty ? l10n.checkEnteredData : firstError,
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
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == AuthStatus.success) {
            if (state.message != null) {
              showAuthSnackBar(context, message: state.message!);
            }
            final String email = _emailController.text.trim();
            _clearFields();
            context.pushReplacementNamed(RouteNames.registerOtp, extra: email);
          } else if (state.status == AuthStatus.failure) {
            final String message = state.errors != null
                ? state.errors!.values.first.first as String
                : state.message ?? l10n.registrationFailed;
            showAuthSnackBar(context, message: message, isError: true);
          }
        },
        child: Scaffold(
          body: SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
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
                                  title: l10n.createAccount,
                                  subtitle: l10n.joinLumina,
                                ),
                                const SizedBox(height: 34),
                                AuthCard(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: <Widget>[
                                      AppTextField(
                                        label: l10n.fullName,
                                        hintText: l10n.fullNameHint,
                                        controller: _fullNameController,
                                        prefixIcon: Icons.person_rounded,
                                        errorText: _fullNameError,
                                        textInputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 22),
                                      AppTextField(
                                        label: l10n.emailAddress,
                                        hintText: l10n.registerEmailHint,
                                        controller: _emailController,
                                        prefixIcon: Icons.email_rounded,
                                        errorText: _emailError,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 22),
                                      AppTextField(
                                        label: l10n.phoneNumber,
                                        hintText: l10n.phoneHint,
                                        controller: _phoneController,
                                        prefixIcon: Icons.phone_rounded,
                                        errorText: _phoneError,
                                        keyboardType: TextInputType.phone,
                                        textInputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 22),
                                      AppTextField(
                                        label: l10n.password,
                                        hintText: l10n.createPassword,
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
                                        hintText: l10n.confirmYourPassword,
                                        controller: _confirmPasswordController,
                                        prefixIcon: Icons.lock_rounded,
                                        obscureText: _obscureConfirmPassword,
                                        errorText: _confirmPasswordError,
                                        textInputAction: TextInputAction.next,
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
                                        text: l10n.createAccount,
                                        isLoading: state.isSubmitting,
                                        onPressed: _submit,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: <Widget>[
                                    Text(
                                      l10n.alreadyHaveAccount,
                                      style: AppTextStyles.bodyMedium,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        _clearFields();
                                        context.goNamed(RouteNames.login);
                                      },
                                      child: Text(l10n.login),
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
