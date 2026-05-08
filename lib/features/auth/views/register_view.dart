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

  bool _obscurePassword = true;
  String? _fullNameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_validate()) {
      return;
    }

    await widget._cubit.register();

    if (!mounted) {
      return;
    }

    showAuthSnackBar(
      context,
      message: 'Account created. Verification code sent.',
    );
    context.pushNamed(RouteNames.registerOtp);
  }

  bool _validate() {
    final String? fullNameError = AuthValidation.fullName(
      _fullNameController.text,
    );
    final String? emailError = AuthValidation.email(_emailController.text);
    final String? phoneError = AuthValidation.phone(_phoneController.text);
    final String? passwordError = AuthValidation.password(
      _passwordController.text,
    );

    setState(() {
      _fullNameError = fullNameError;
      _emailError = emailError;
      _phoneError = phoneError;
      _passwordError = passwordError;
    });

    final String? firstError =
        fullNameError ?? emailError ?? phoneError ?? passwordError;
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
                padding: const EdgeInsets.fromLTRB(24, 34, 24, 28),
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
                                title: 'Create Account',
                                subtitle: 'Join Beauty Center',
                              ),
                              const SizedBox(height: 34),
                              AuthCard(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    AppTextField(
                                      label: 'Full Name',
                                      hintText: 'Jane Doe',
                                      controller: _fullNameController,
                                      prefixIcon: Icons.person_rounded,
                                      errorText: _fullNameError,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 22),
                                    AppTextField(
                                      label: 'Email Address',
                                      hintText: 'jane@example.com',
                                      controller: _emailController,
                                      prefixIcon: Icons.email_rounded,
                                      errorText: _emailError,
                                      keyboardType: TextInputType.emailAddress,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 22),
                                    AppTextField(
                                      label: 'Phone Number',
                                      hintText: '+1 (555) 000-0000',
                                      controller: _phoneController,
                                      prefixIcon: Icons.phone_rounded,
                                      errorText: _phoneError,
                                      keyboardType: TextInputType.phone,
                                      textInputAction: TextInputAction.next,
                                    ),
                                    const SizedBox(height: 22),
                                    AppTextField(
                                      label: 'Password',
                                      hintText: 'Create a password',
                                      controller: _passwordController,
                                      prefixIcon: Icons.lock_rounded,
                                      obscureText: _obscurePassword,
                                      errorText: _passwordError,
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) {
                                        _submit();
                                      },
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
                                    const SizedBox(height: 28),
                                    AppButton(
                                      text: 'Create Account',
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
                                    'Already have an account? ',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.goNamed(RouteNames.login);
                                    },
                                    child: const Text('Login'),
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
    );
  }
}
