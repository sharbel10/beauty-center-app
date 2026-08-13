import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:beauty_center_app/features/favorites/cubit/favorites_state.dart';
import 'package:beauty_center_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:beauty_center_app/features/notifications/cubit/notifications_state.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.userName, super.key});

  final String userName;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(l10n.welcomeBack, style: AppTextStyles.smallCaps),
              const SizedBox(height: 8),
              Text(
                userName,
                style: AppTextStyles.headline.copyWith(fontSize: 29),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        BlocBuilder<FavoritesCubit, FavoritesState>(
          builder: (BuildContext context, FavoritesState state) {
            return _HeaderCircleButton(
              icon: Icons.favorite_rounded,
              badgeColor: AppColors.primary,
              onTap: () => context.pushNamed(RouteNames.favorites),
            );
          },
        ),
        const SizedBox(width: 10),
        BlocBuilder<NotificationsCubit, NotificationsState>(
          buildWhen:
              (NotificationsState previous, NotificationsState current) =>
                  previous.unreadCount != current.unreadCount,
          builder: (BuildContext context, NotificationsState state) {
            return _HeaderCircleButton(
              icon: Icons.notifications_rounded,
              badgeCount: state.unreadCount,
              badgeColor: AppColors.danger,
              onTap: () => context.pushNamed(RouteNames.notifications),
            );
          },
        ),
      ],
    );
  }
}

class _HeaderCircleButton extends StatelessWidget {
  const _HeaderCircleButton({
    required this.icon,
    required this.onTap,
    this.badgeCount = 0,
    this.badgeColor,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int badgeCount;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(27),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x120A2A55),
                blurRadius: 12,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(icon, color: AppColors.primary, size: 24),
              if (badgeCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: _CountBadge(
                    count: badgeCount,
                    color: badgeColor ?? AppColors.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final String display = count > 99 ? '99+' : count.toString();
    final double width = display.length > 2 ? 24 : 20;

    return Container(
      width: width,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.surface, width: 1.5),
      ),
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Center(
        child: Text(
          display,
          style: AppTextStyles.smallCaps.copyWith(
            color: AppColors.surface,
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.2,
            height: 1.2,
          ),
        ),
      ),
    );
  }
}

