import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/localization/app_locale_controller.dart';
import 'package:beauty_center_app/core/storage/preference_manager.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_cubit.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserSettingsMenuButton extends StatelessWidget {
  const UserSettingsMenuButton({required this.userName, super.key});

  final String userName;

  static const Locale _english = Locale('en');
  static const Locale _arabic = Locale('ar');

  Future<void> _setLocale(Locale locale) async {
    await AppLocaleController.instance.setLocale(
      getIt<PreferenceManager>(),
      locale,
    );
  }

  void _openMenu(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final RenderBox button = context.findRenderObject()! as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);
    final Size size = button.size;
    final Locale activeLocale = AppLocaleController.instance.locale.value ??
        Localizations.localeOf(context);

    showMenu<void>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + size.height + 8,
        offset.dx + size.width,
        offset.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      items: <PopupMenuEntry<void>>[
        PopupMenuItem<void>(
          enabled: false,
          child: Text(
            userName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.link.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          enabled: false,
          height: 36,
          child: Text(
            l10n.changeLanguage,
            style: AppTextStyles.smallCaps.copyWith(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ),
        _LanguageMenuItem(
          label: l10n.languageEnglish,
          isSelected: activeLocale.languageCode == _english.languageCode,
          onSelected: () => _setLocale(_english),
        ),
        _LanguageMenuItem(
          label: l10n.languageArabic,
          isSelected: activeLocale.languageCode == _arabic.languageCode,
          onSelected: () => _setLocale(_arabic),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.read<AuthCubit>().logout();
              }
            });
          },
          child: Text(
            l10n.logout,
            style: AppTextStyles.link.copyWith(
              color: AppColors.danger,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: const CircleBorder(),
      elevation: 0,
      shadowColor: const Color(0x120A2A55),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => _openMenu(context),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x120A2A55),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(
            Icons.settings_rounded,
            color: AppColors.primary,
            size: 26,
          ),
        ),
      ),
    );
  }
}

class _LanguageMenuItem extends PopupMenuEntry<void> {
  const _LanguageMenuItem({
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  @override
  double get height => 44;

  @override
  bool represents(Object? value) => false;

  @override
  State<_LanguageMenuItem> createState() => _LanguageMenuItemState();
}

class _LanguageMenuItemState extends State<_LanguageMenuItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        widget.onSelected();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                widget.label,
                style: AppTextStyles.subtitle.copyWith(
                  fontSize: 14,
                  fontWeight:
                      widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: widget.isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            if (widget.isSelected)
              const Icon(
                Icons.check_rounded,
                color: AppColors.gold,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
