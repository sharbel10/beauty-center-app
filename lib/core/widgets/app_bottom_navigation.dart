import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppNavItem { home, explore, aiScan, bookings, profile }

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.currentItem,
    this.onItemSelected,
    super.key,
  });

  final AppNavItem currentItem;
  final ValueChanged<AppNavItem>? onItemSelected;

  static const double _barHeight = 60;
  static const double _centerButtonSize = 52;
  static const double _centerButtonLift = 20;

  /// Extra scroll padding so list content clears the elevated center button.
  static double contentOverlap(BuildContext context) {
    return _centerButtonLift + MediaQuery.paddingOf(context).bottom;
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: _barHeight + bottomInset + _centerButtonLift,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Color(0x140A2A55),
                    blurRadius: 20,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: SizedBox(
                  height: _barHeight,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: _NavItem(
                          icon: Icons.home_rounded,
                          label: l10n.home,
                          isActive: currentItem == AppNavItem.home,
                          onTap: () => _handleTap(context, AppNavItem.home),
                        ),
                      ),
                      Expanded(
                        child: _NavItem(
                          icon: Icons.explore_outlined,
                          label: l10n.explore,
                          isActive: currentItem == AppNavItem.explore,
                          onTap: () => _handleTap(context, AppNavItem.explore),
                        ),
                      ),
                      const SizedBox(width: _centerButtonSize + 8),
                      Expanded(
                        child: _NavItem(
                          icon: Icons.calendar_month_outlined,
                          label: l10n.bookings,
                          isActive: currentItem == AppNavItem.bookings,
                          onTap: () => _handleTap(context, AppNavItem.bookings),
                        ),
                      ),
                      Expanded(
                        child: _NavItem(
                          icon: Icons.person_outline_rounded,
                          label: l10n.profile,
                          isActive: currentItem == AppNavItem.profile,
                          onTap: () => _handleTap(context, AppNavItem.profile),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: bottomInset + (_barHeight - _centerButtonSize) / 2,
            child: _CenterScanButton(
              isActive: currentItem == AppNavItem.aiScan,
              onTap: () => _handleTap(context, AppNavItem.aiScan),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context, AppNavItem item) {
    if (onItemSelected != null) {
      onItemSelected!(item);
      return;
    }

    if (item == currentItem) {
      return;
    }

    if (item == AppNavItem.home) {
      context.goNamed(RouteNames.home);
    } else if (item == AppNavItem.explore) {
      context.goNamed(RouteNames.explore);
    } else if (item == AppNavItem.bookings) {
      context.goNamed(RouteNames.bookings);
    } else if (item == AppNavItem.profile) {
      context.goNamed(RouteNames.profile);
    }
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? AppColors.primary : AppColors.textMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: color, size: 23),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.smallCaps.copyWith(
                  color: color,
                  fontSize: 8,
                  letterSpacing: 0.8,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterScanButton extends StatelessWidget {
  const _CenterScanButton({required this.isActive, required this.onTap});

  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Material(
          elevation: isActive ? 10 : 8,
          shadowColor: AppColors.primary.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          color: AppColors.primarySoft,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: const SizedBox(
              width: AppBottomNavigation._centerButtonSize,
              height: AppBottomNavigation._centerButtonSize,
              child: Icon(
                Icons.document_scanner_outlined,
                color: AppColors.surface,
                size: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.aiScan,
          style: AppTextStyles.smallCaps.copyWith(
            color: isActive ? AppColors.primary : AppColors.textMuted,
            fontSize: 8,
            letterSpacing: 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
