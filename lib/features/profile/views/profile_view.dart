import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/localization/app_locale_controller.dart';
import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/storage/preference_manager.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/core/widgets/app_bottom_navigation.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_cubit.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_state.dart';
import 'package:beauty_center_app/features/auth/models/customer.dart';
import 'package:beauty_center_app/features/profile/cubit/profile_cubit.dart';
import 'package:beauty_center_app/features/profile/cubit/profile_state.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    _profileCubit.close();
    super.dispose();
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
              current.status == ProfileStatus.failure,
          listener: (BuildContext context, ProfileState state) {
            context.showSnackbar(state.message!, isError: true);
          },
          builder: (BuildContext context, ProfileState state) {
            return Scaffold(
              backgroundColor: AppColors.scaffold,
              extendBody: true,
              bottomNavigationBar: const AppBottomNavigation(
                currentItem: AppNavItem.profile,
              ),
              body: SafeArea(
                bottom: false,
                child: _buildBody(context, state),
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
      return const Center(child: CircularProgressIndicator());
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
          _ProfileHeroCard(customer: state.customer!),
          const SizedBox(height: 16),
          _ProfileInfoCard(customer: state.customer!),
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
            onLogout: () => widget._authCubit.logout(),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({required this.customer});

  final Customer customer;

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
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              _initials,
              style: AppTextStyles.headline.copyWith(
                fontSize: 28,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            customer.name,
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(
              fontSize: 22,
              color: AppColors.surface,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            customer.email,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle.copyWith(
              fontSize: 14,
              color: AppColors.surface.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: <Widget>[
              _StatusChip(
                label: customer.emailVerified ? l10n.verified : l10n.unverified,
                icon: customer.emailVerified
                    ? Icons.verified_rounded
                    : Icons.mark_email_unread_outlined,
              ),
              _StatusChip(
                label: customer.isActive ? l10n.active : l10n.inactive,
                icon: customer.isActive
                    ? Icons.check_circle_outline_rounded
                    : Icons.pause_circle_outline_rounded,
              ),
            ],
          ),
        ],
      ),
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
          const Divider(height: 1),
          _InfoRow(
            icon: Icons.email_outlined,
            label: l10n.clinicEmail,
            value: customer.email,
          ),
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
  });

  final String locationLabel;
  final bool isLocationLoading;
  final VoidCallback onLocationTap;
  final VoidCallback onLogout;

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
                        builder:
                            (BuildContext context, Locale? locale, _) {
                          final Locale activeLocale =
                              locale ?? Localizations.localeOf(context);
                          final bool isArabic =
                              activeLocale.languageCode ==
                              _arabic.languageCode;
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
