import 'package:beauty_center_app/core/router/app_router.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:beauty_center_app/features/notifications/cubit/notifications_state.dart';
import 'package:beauty_center_app/features/notifications/models/app_notification.dart';
import 'package:beauty_center_app/features/notifications/widgets/notification_card.dart';
import 'package:beauty_center_app/features/notifications/widgets/notifications_header.dart';
import 'package:beauty_center_app/features/notifications/widgets/notifications_skeleton.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationsCubit>().loadNotifications();
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }
    final double threshold = _scrollController.position.maxScrollExtent - 240;
    if (_scrollController.position.pixels >= threshold) {
      context.read<NotificationsCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationsCubit, NotificationsState>(
      listenWhen: (NotificationsState previous, NotificationsState current) =>
          previous.message != current.message && current.message != null,
      listener: (BuildContext context, NotificationsState state) {
        context.showSnackbar(state.message!, isError: state.isMessageError);
        context.read<NotificationsCubit>().clearMessage();
      },
      builder: (BuildContext context, NotificationsState state) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        final NotificationsCubit cubit = context.read<NotificationsCubit>();

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: <Widget>[
                NotificationsHeader(
                  hasUnread: state.hasUnread,
                  onMarkAllRead: cubit.markAllAsRead,
                ),
                Expanded(child: _buildList(context, state, cubit, l10n)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildList(
    BuildContext context,
    NotificationsState state,
    NotificationsCubit cubit,
    AppLocalizations l10n,
  ) {
    if (state.isLoading && !state.hasData) {
      return const NotificationsSkeleton();
    }

    if (state.status == NotificationsStatus.failure && !state.hasData) {
      return _EmptyNotifications(
        title: l10n.unableToLoadNotifications,
        subtitle: state.message ?? l10n.errorUnexpected,
        icon: Icons.wifi_off_rounded,
        actionLabel: l10n.retry,
        onAction: cubit.loadNotifications,
      );
    }

    return RefreshIndicator(
      onRefresh: cubit.loadNotifications,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          if (!state.hasData)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                child: _EmptyNotifications(
                  title: l10n.noNotifications,
                  subtitle: l10n.noNotificationsSubtitle,
                  icon: Icons.notifications_none_rounded,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              sliver: SliverList.separated(
                itemCount:
                    state.notifications.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (BuildContext context, int index) {
                  if (index >= state.notifications.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final AppNotification notification =
                      state.notifications[index];
                  return NotificationCard(
                    notification: notification,
                    onTap: () =>
                        _onNotificationTap(context, cubit, notification),
                    onDelete: () =>
                        _confirmDelete(context, cubit, notification),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _onNotificationTap(
    BuildContext context,
    NotificationsCubit cubit,
    AppNotification notification,
  ) async {
    if (!notification.isRead) {
      await cubit.markAsRead(notification.id);
    }
    if (!context.mounted) {
      return;
    }
    AppRouter.navigateFromNotification(
      type: notification.type,
      id: notification.id.toString(),
      appointmentId: notification.payload.appointmentId?.toString(),
      centerId: notification.payload.centerId?.toString(),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    NotificationsCubit cubit,
    AppNotification notification,
  ) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(l10n.deleteNotification),
              content: Text(l10n.deleteNotificationConfirm),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.deleteNotification),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmed && context.mounted) {
      await cubit.deleteNotification(notification.id);
    }
  }
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle.copyWith(fontSize: 13, height: 1.4),
            ),
            if (onAction != null && actionLabel != null) ...<Widget>[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
