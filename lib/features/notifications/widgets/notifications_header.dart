import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsHeader extends StatelessWidget {
  const NotificationsHeader({
    required this.unreadCount,
    required this.onMarkAllRead,
    super.key,
  });

  final int unreadCount;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
      ),
      child: Row(
        children: <Widget>[
          Material(
            color: AppColors.surfaceMuted,
            shape: const CircleBorder(),
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded, size: 21),
              color: AppColors.primary,
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    l10n.notifications,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (unreadCount > 0) ...<Widget>[
                  const SizedBox(width: 9),
                  Container(
                    constraints: const BoxConstraints(minWidth: 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      unreadCount > 99 ? '99+' : '$unreadCount',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (unreadCount > 0)
            Tooltip(
              message: l10n.markAllAsRead,
              child: IconButton(
                onPressed: onMarkAllRead,
                style: IconButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  backgroundColor: AppColors.secondary.withValues(alpha: 0.18),
                ),
                icon: const Icon(Icons.done_all_rounded, size: 21),
              ),
            ),
        ],
      ),
    );
  }
}
