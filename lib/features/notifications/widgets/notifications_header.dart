import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsHeader extends StatelessWidget {
  const NotificationsHeader({
    required this.hasUnread,
    required this.onMarkAllRead,
    super.key,
  });

  final bool hasUnread;
  final VoidCallback onMarkAllRead;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.primary,
          ),
          Expanded(
            child: Text(
              l10n.notifications,
              style: AppTextStyles.headline.copyWith(fontSize: 24),
            ),
          ),
          if (hasUnread)
            TextButton(
              onPressed: onMarkAllRead,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.markAllAsRead,
                style: AppTextStyles.link.copyWith(fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
