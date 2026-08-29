import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/features/notifications/models/app_notification.dart';
import 'package:beauty_center_app/features/notifications/utils/notification_time_label.dart';
import 'package:beauty_center_app/features/notifications/utils/notification_visual.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool isRead = notification.isRead;
    final NotificationVisual visual = resolveNotificationVisual(
      notification,
      isRead: isRead,
    );
    final String timeLabel = notificationTimeLabel(
      notification.displayAt,
      l10n,
    );

    return Dismissible(
      key: ValueKey<int>(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 22),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.18),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.delete_outline_rounded,
            color: AppColors.white,
          ),
        ),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: visual.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: visual.iconColor.withValues(alpha: isRead ? 0.12 : 0.2),
              ),
            ),
            child: Stack(
              children: <Widget>[
                PositionedDirectional(
                  start: 0,
                  top: 14,
                  bottom: 14,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      color: visual.iconColor.withValues(
                        alpha: isRead ? 0.48 : 0.9,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 14, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _NotificationIcon(visual: visual, isRead: isRead),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    notification.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontSize: 15,
                                      fontWeight: isRead
                                          ? FontWeight.w600
                                          : FontWeight.w700,
                                    ),
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsetsDirectional.only(
                                      start: 8,
                                      top: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: visual.iconColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              notification.body,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.subtitle.copyWith(
                                fontSize: 13,
                                height: 1.4,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (timeLabel.isNotEmpty) ...<Widget>[
                              const SizedBox(height: 9),
                              Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 14,
                                    color: visual.iconColor.withValues(
                                      alpha: isRead ? 0.6 : 0.78,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      timeLabel,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: visual.iconColor.withValues(
                                          alpha: isRead ? 0.65 : 0.82,
                                        ),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  const _NotificationIcon({required this.visual, required this.isRead});

  final NotificationVisual visual;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: isRead ? 0.66 : 0.9),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: visual.iconColor.withValues(alpha: isRead ? 0.1 : 0.16),
        ),
      ),
      child: Icon(visual.icon, size: 21, color: visual.iconColor),
    );
  }
}
