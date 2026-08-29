import 'dart:io';

import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/localization/app_locale_controller.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/storage/preference_manager.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/core/widgets/app_bottom_navigation.dart';
import 'package:beauty_center_app/core/widgets/root_exit_guard.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_cubit.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_state.dart';
import 'package:beauty_center_app/features/auth/models/customer.dart';
import 'package:beauty_center_app/features/profile/cubit/profile_cubit.dart';
import 'package:beauty_center_app/features/profile/cubit/profile_state.dart';
import 'package:beauty_center_app/features/profile/widgets/profile_skeleton.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

String? _profileAvatarUrl(Customer customer) {
  final String? source = customer.avatarUrl?.trim().isNotEmpty == true
      ? customer.avatarUrl!.trim()
      : customer.avatarPath?.trim().isNotEmpty == true
      ? customer.avatarPath!.trim()
      : null;
  return source == null ? null : ApiEndpoints.mediaUrl(source);
}

class ProfileView extends StatefulWidget {
  const ProfileView({
    required AuthCubit authCubit,
    required ProfileCubit profileCubit,
    super.key,
  }) : _authCubit = authCubit,
       _profileCubit = profileCubit;

  final AuthCubit _authCubit;
  final ProfileCubit _profileCubit;

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileCubit _profileCubit;

  @override
  void initState() {
    super.initState();
    _profileCubit = widget._profileCubit;
    _profileCubit.loadProfile();
  }

  @override
  void didUpdateWidget(ProfileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget._profileCubit, _profileCubit)) {
      widget._profileCubit.close();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar(
    BuildContext context,
    bool isUpdating,
    bool hasAvatar,
  ) async {
    if (isUpdating) return;

    final AppLocalizations l10n = AppLocalizations.of(context);

    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(l10n.camera),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    await widget._profileCubit.uploadAvatar(File(image.path));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(l10n.gallery),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (image != null) {
                    await widget._profileCubit.uploadAvatar(File(image.path));
                  }
                },
              ),
              if (hasAvatar)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.danger,
                  ),
                  title: Text(
                    l10n.removeAvatar,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await _showDeleteAvatarDialog(this.context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAvatarPreview(
    BuildContext context,
    Customer customer,
  ) async {
    final String? imageUrl = _profileAvatarUrl(customer);
    if (imageUrl == null) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (BuildContext dialogContext) {
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: <Widget>[
              Positioned.fill(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4,
                  child: Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder:
                          (
                            BuildContext context,
                            Widget child,
                            ImageChunkEvent? loadingProgress,
                          ) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return const CircularProgressIndicator(
                              color: AppColors.surface,
                            );
                          },
                      errorBuilder:
                          (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) => const Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.surface,
                            size: 52,
                          ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: IconButton.filled(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.55),
                      foregroundColor: AppColors.surface,
                    ),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteAvatarDialog(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.removeAvatar),
        content: Text(l10n.removeAvatarConfirm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(l10n.removeAvatar),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _profileCubit.deleteAvatar();
    }
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirm),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: Text(l10n.logout),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await widget._authCubit.logout();
    }
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final AppLocalizations l10n = AppLocalizations.of(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.deleteAccount),
          content: Text(l10n.deleteAccountConfirm),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: Text(l10n.deleteAccount),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await widget._profileCubit.deleteAccount();
    }
  }

  Future<void> _showChangePasswordDialog(
    BuildContext context,
    bool isUpdating,
  ) async {
    if (isUpdating) return;

    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool _obscureCurrentPassword = true;
    bool _obscureNewPassword = true;
    bool _obscureConfirmPassword = true;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(l10n.changePassword),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: _obscureCurrentPassword,
                        decoration: InputDecoration(
                          labelText: l10n.currentPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureCurrentPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureCurrentPassword =
                                    !_obscureCurrentPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return l10n.currentPasswordRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: _obscureNewPassword,
                        decoration: InputDecoration(
                          labelText: l10n.newPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return l10n.newPasswordRequired;
                          }
                          if (value.length < 6) {
                            return l10n.passwordTooShort;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: l10n.confirmPassword,
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return l10n.confirmPasswordRequired;
                          }
                          if (value != newPasswordController.text) {
                            return l10n.passwordsDoNotMatch;
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      await widget._profileCubit.changePassword(
                        currentPassword: currentPasswordController.text,
                        newPassword: newPasswordController.text,
                        passwordConfirmation: confirmPasswordController.text,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                  ),
                  child: Text(l10n.changePassword),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showEditProfileDialog(
    BuildContext context,
    Customer customer,
    bool isUpdating,
  ) async {
    if (isUpdating) return;

    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextEditingController nameController = TextEditingController(
      text: customer.name,
    );
    final TextEditingController phoneController = TextEditingController(
      text: customer.phone,
    );
    final TextEditingController cityController = TextEditingController(
      text: customer.city ?? '',
    );
    final TextEditingController addressController = TextEditingController(
      text: customer.address ?? '',
    );
    final TextEditingController birthDateController = TextEditingController(
      text: customer.birthDate ?? '',
    );
    String? selectedGender = customer.gender;
    bool notificationsEnabled = customer.notificationsEnabled ?? true;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text(l10n.editProfile),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: l10n.fullName,
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.validationFullName;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: l10n.phoneNumber,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.validationPhoneRequired;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        decoration: InputDecoration(
                          labelText: l10n.gender,
                          prefixIcon: const Icon(Icons.wc_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const <String>['male', 'female']
                            .map<DropdownMenuItem<String>>(
                              (String item) => DropdownMenuItem<String>(
                                value: item,
                                child: Text(
                                  item == 'male' ? l10n.male : l10n.female,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: birthDateController,
                        readOnly: true,
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: birthDateController.text.isNotEmpty
                                ? DateTime.tryParse(birthDateController.text)
                                : DateTime(2000),
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setState(() {
                              birthDateController.text = picked
                                  .toIso8601String()
                                  .split('T')[0];
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: l10n.birthDate,
                          prefixIcon: const Icon(Icons.cake_outlined),
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            color: AppColors.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: cityController,
                        decoration: InputDecoration(
                          labelText: l10n.city,
                          prefixIcon: const Icon(Icons.location_city_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: addressController,
                        decoration: InputDecoration(
                          labelText: l10n.address,
                          prefixIcon: const Icon(Icons.home_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: <Widget>[
                          Icon(
                            notificationsEnabled
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_none_rounded,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.notificationsEnabled,
                              style: AppTextStyles.subtitle.copyWith(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Switch(
                            value: notificationsEnabled,
                            onChanged: (bool value) {
                              setState(() {
                                notificationsEnabled = value;
                              });
                            },
                            activeTrackColor: AppColors.primary.withValues(
                              alpha: 0.5,
                            ),
                            activeThumbColor: AppColors.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context);
                      await widget._profileCubit.updateProfile(
                        name: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        gender: selectedGender,
                        birthDate: birthDateController.text.trim(),
                        city: cityController.text.trim(),
                        address: addressController.text.trim(),
                        preferredLocale: customer.preferredLocale,
                        notificationsEnabled: notificationsEnabled,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.surface,
                  ),
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _translateMessage(AppLocalizations l10n, String message) {
    // Map of localization keys to their corresponding l10n methods
    final Map<String, String> messageMap = <String, String>{
      'profileUpdatedSuccessfully': l10n.profileUpdatedSuccessfully,
      'avatarUpdatedSuccessfully': l10n.avatarUpdatedSuccessfully,
      'avatarRemovedSuccessfully': l10n.avatarRemovedSuccessfully,
      'accountDeletedSuccessfully': l10n.accountDeletedSuccessfully,
      'passwordChangedSuccessfully': l10n.passwordChangedSuccessfully,
      'passwordChangedReLogin': l10n.passwordChangedReLogin,
    };

    // Return translated message if key exists, otherwise return original message
    return messageMap[message] ?? message;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthCubit>.value(value: widget._authCubit),
        BlocProvider<ProfileCubit>.value(value: _profileCubit),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (AuthState previous, AuthState current) =>
            previous.isAuthenticated != current.isAuthenticated &&
            !current.isAuthenticated,
        listener: (BuildContext context, AuthState state) {
          context.goNamed(RouteNames.login);
        },
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listenWhen: (ProfileState previous, ProfileState current) =>
              previous.message != current.message &&
              current.message != null &&
              (current.status == ProfileStatus.failure ||
                  current.status == ProfileStatus.success),
          listener: (BuildContext context, ProfileState state) {
            final AppLocalizations l10n = AppLocalizations.of(context);
            if (state.status == ProfileStatus.failure) {
              context.showSnackbar(state.message!, isError: true);
            } else if (state.status == ProfileStatus.success &&
                state.message != null) {
              // Translate the message if it's a localization key
              String message = state.message!;
              message = _translateMessage(l10n, message);
              context.showSnackbar(message);
            }
          },
          builder: (BuildContext context, ProfileState state) {
            return RootExitGuard(
              child: Stack(
                children: <Widget>[
                  Scaffold(
                    backgroundColor: AppColors.scaffold,
                    extendBody: true,
                    bottomNavigationBar: const AppBottomNavigation(
                      currentItem: AppNavItem.profile,
                    ),
                    body: SafeArea(
                      bottom: false,
                      child: _buildBody(context, state),
                    ),
                  ),
                  if (state.isUpdating)
                    Container(
                      color: Colors.black.withValues(alpha: 0.3),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProfileState state) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (state.isLoading && !state.hasCustomer) {
      return const ProfileSkeleton();
    }

    if (!state.hasCustomer) {
      return _ProfileErrorBody(
        message: state.message ?? l10n.unableToLoadProfile,
        onRetry: _profileCubit.loadProfile,
      );
    }

    return RefreshIndicator(
      onRefresh: _profileCubit.loadProfile,
      child: ListView(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          96 + AppBottomNavigation.contentOverlap(context),
        ),
        children: <Widget>[
          Text(
            l10n.profileTitle,
            style: AppTextStyles.title.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 24),
          _ProfileHeroCard(
            customer: state.customer!,
            onAvatarTap: () => _showAvatarPreview(context, state.customer!),
            onEditAvatarTap: () => _pickAndUploadAvatar(
              context,
              state.isUpdating,
              _profileAvatarUrl(state.customer!) != null,
            ),
            appointmentsTotal: state.stats != null
                ? state.stats!.appointmentsTotal.toString()
                : '0',
            appointmentsUpcoming: state.stats != null
                ? state.stats!.appointmentsUpcoming.toString()
                : '0',
          ),
          const SizedBox(height: 36),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _ProfileStatCard(
                      value: state.stats != null
                          ? state.stats!.appointmentsTotal.toString()
                          : '0',
                      label: l10n.appointmentsTotal.toUpperCase(),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _ProfileStatCard(
                      value: state.stats != null
                          ? state.stats!.appointmentsUpcoming.toString()
                          : '0',
                      label: l10n.appointmentsUpcoming.toUpperCase(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _ProfileInfoCard(customer: state.customer!),
          // const SizedBox(height: 16),
          // if (state.stats != null) _ProfileStatsCard(stats: state.stats!),
          const SizedBox(height: 28),
          Text(
            l10n.settings,
            style: AppTextStyles.title.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 14),
          _SettingsCard(
            locationLabel: state.locationLabel(l10n),
            isLocationLoading: state.isLocationLoading,
            onLocationTap: _profileCubit.refreshLocation,
            onLogout: () => _showLogoutDialog(context),
            onEditProfile: () => _showEditProfileDialog(
              context,
              state.customer!,
              state.isUpdating,
            ),
            onDeleteAccount: () => _showDeleteAccountDialog(context),
            onChangePassword: () =>
                _showChangePasswordDialog(context, state.isUpdating),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.customer,
    required this.onAvatarTap,
    required this.onEditAvatarTap,
    required this.appointmentsTotal,
    required this.appointmentsUpcoming,
  });

  final Customer customer;
  final VoidCallback onAvatarTap;
  final VoidCallback onEditAvatarTap;
  final String appointmentsTotal;
  final String appointmentsUpcoming;

  String get _initials {
    final List<String> parts = customer.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final String? avatarUrl = _profileAvatarUrl(customer);

    return Column(
      children: <Widget>[
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            GestureDetector(
              onTap: avatarUrl == null ? null : onAvatarTap,
              child: Semantics(
                button: avatarUrl != null,
                child: Container(
                  width: 154,
                  height: 154,
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.secondary.withValues(alpha: 0.3),
                      width: 6,
                    ),
                  ),
                  child: ClipOval(
                    child: avatarUrl != null
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            loadingBuilder:
                                (
                                  BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress,
                                ) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                              null
                                          ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                          : null,
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  );
                                },
                            errorBuilder:
                                (
                                  BuildContext context,
                                  Object error,
                                  StackTrace? stackTrace,
                                ) {
                                  return Container(
                                    color: AppColors.surfaceMuted,
                                    child: Center(
                                      child: Text(
                                        _initials,
                                        style: AppTextStyles.headline.copyWith(
                                          fontSize: 48,
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                          )
                        : Container(
                            color: AppColors.surfaceMuted,
                            child: Center(
                              child: Text(
                                _initials,
                                style: AppTextStyles.headline.copyWith(
                                  fontSize: 48,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: -2,
              bottom: 5,
              child: Material(
                color: AppColors.secondary,
                shape: CircleBorder(
                  side: BorderSide(color: AppColors.surface, width: 6),
                ),
                child: InkWell(
                  onTap: onEditAvatarTap,
                  customBorder: const CircleBorder(),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Icon(
                      avatarUrl != null
                          ? Icons.edit_rounded
                          : Icons.camera_alt_rounded,
                      color: AppColors.surface,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          customer.name,
          textAlign: TextAlign.center,
          style: AppTextStyles.headline.copyWith(
            color: AppColors.primary,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          customer.email,
          textAlign: TextAlign.center,
          style: AppTextStyles.subtitle.copyWith(
            color: AppColors.textMuted,
            fontSize: 16,
          ),
        ),

        // const SizedBox(height: 24),
        // Wrap(
        //   spacing: 8,
        //   runSpacing: 8,
        //   alignment: WrapAlignment.center,
        //   children: <Widget>[
        //     _StatusChip(
        //       label: customer.emailVerified ? l10n.verified : l10n.unverified,
        //       icon: customer.emailVerified
        //           ? Icons.verified_rounded
        //           : Icons.mark_email_unread_outlined,
        //     ),
        //     _StatusChip(
        //       label: customer.isActive ? l10n.active : l10n.inactive,
        //       icon: customer.isActive
        //           ? Icons.check_circle_outline_rounded
        //           : Icons.pause_circle_outline_rounded,
        //     ),
        //   ],
        // ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 14, color: AppColors.surface),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.smallCaps.copyWith(
              color: AppColors.surface,
              fontSize: 10,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  const _ProfileInfoCard({required this.customer});

  final Customer customer;

  String _formatBirthDate(String? birthDate) {
    if (birthDate == null || birthDate.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(birthDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return birthDate;
    }
  }

  String _formatLastLogin(String? lastLoginAt) {
    if (lastLoginAt == null || lastLoginAt.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(lastLoginAt);
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return lastLoginAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: <Widget>[
          _InfoRow(
            icon: Icons.phone_outlined,
            label: l10n.phone,
            value: customer.phone,
          ),
          if (customer.email.isNotEmpty) ...<Widget>[
            const Divider(height: 1),
            _InfoRow(
              icon: Icons.email_outlined,
              label: l10n.clinicEmail,
              value: customer.email,
            ),
          ],
          if (customer.gender != null &&
              customer.gender!.isNotEmpty) ...<Widget>[
            const Divider(height: 1),
            _InfoRow(
              icon: Icons.wc_outlined,
              label: l10n.gender,
              value: customer.gender == 'male' ? l10n.male : l10n.female,
            ),
          ],
          if (customer.birthDate != null &&
              customer.birthDate!.isNotEmpty) ...<Widget>[
            const Divider(height: 1),
            _InfoRow(
              icon: Icons.cake_outlined,
              label: l10n.birthDate,
              value: _formatBirthDate(customer.birthDate),
            ),
          ],
          if (customer.city != null && customer.city!.isNotEmpty) ...<Widget>[
            const Divider(height: 1),
            _InfoRow(
              icon: Icons.location_city_outlined,
              label: l10n.city,
              value: customer.city!,
            ),
          ],
          if (customer.address != null &&
              customer.address!.isNotEmpty) ...<Widget>[
            const Divider(height: 1),
            _InfoRow(
              icon: Icons.home_outlined,
              label: l10n.address,
              value: customer.address!,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label.toUpperCase(),
                  style: AppTextStyles.smallCaps.copyWith(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.locationLabel,
    required this.isLocationLoading,
    required this.onLocationTap,
    required this.onLogout,
    required this.onEditProfile,
    required this.onDeleteAccount,
    required this.onChangePassword,
  });

  final String locationLabel;
  final bool isLocationLoading;
  final VoidCallback onLocationTap;
  final VoidCallback onLogout;
  final VoidCallback onEditProfile;
  final VoidCallback onDeleteAccount;
  final VoidCallback onChangePassword;

  static const Locale _english = Locale('en');
  static const Locale _arabic = Locale('ar');

  Future<void> _setLocale(Locale locale) async {
    await AppLocaleController.instance.setLocale(
      getIt<PreferenceManager>(),
      locale,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AppLocaleController controller = AppLocaleController.instance;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onLocationTap,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.yourLocation,
                            style: AppTextStyles.smallCaps.copyWith(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (isLocationLoading)
                            Row(
                              children: <Widget>[
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.6,
                                    color: AppColors.primary.withValues(
                                      alpha: 0.7,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    locationLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.subtitle.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          else
                            Text(
                              locationLabel,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.subtitle.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.refresh_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, indent: 18, endIndent: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            child: Row(
              children: <Widget>[
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.changeLanguage,
                        style: AppTextStyles.smallCaps.copyWith(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ValueListenableBuilder<Locale?>(
                        valueListenable: controller.locale,
                        builder: (BuildContext context, Locale? locale, _) {
                          final Locale activeLocale =
                              locale ?? Localizations.localeOf(context);
                          final bool isArabic =
                              activeLocale.languageCode == _arabic.languageCode;
                          return Text(
                            isArabic
                                ? l10n.languageArabic
                                : l10n.languageEnglish,
                            style: AppTextStyles.subtitle.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                ValueListenableBuilder<Locale?>(
                  valueListenable: controller.locale,
                  builder: (BuildContext context, Locale? locale, _) {
                    final Locale activeLocale =
                        locale ?? Localizations.localeOf(context);
                    final bool isArabic =
                        activeLocale.languageCode == _arabic.languageCode;
                    return TextButton(
                      onPressed: () =>
                          _setLocale(isArabic ? _english : _arabic),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceMuted,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        isArabic ? 'EN' : 'AR',
                        style: AppTextStyles.link.copyWith(fontSize: 12),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 18, endIndent: 18),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onEditProfile,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.editProfile,
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, indent: 18, endIndent: 18),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onChangePassword,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceMuted,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.changePassword,
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, indent: 18, endIndent: 18),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onDeleteAccount,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        size: 18,
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.deleteAccount,
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.danger.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, indent: 18, endIndent: 18),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onLogout,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.logout,
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.danger.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              fontSize: 20,
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.smallCaps.copyWith(
              fontSize: 9,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.7)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            value,
            style: AppTextStyles.headline.copyWith(
              fontSize: 28,
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.smallCaps.copyWith(
              fontSize: 11,
              color: AppColors.textMuted,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileErrorBody extends StatelessWidget {
  const _ProfileErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}
