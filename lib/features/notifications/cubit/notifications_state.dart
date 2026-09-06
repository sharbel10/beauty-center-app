import 'package:beauty_center_app/features/explore/models/pagination_meta.dart';
import 'package:beauty_center_app/features/notifications/models/app_notification.dart';
import 'package:equatable/equatable.dart';

enum NotificationsStatus { initial, loading, loadingMore, success, failure }

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const <AppNotification>[],
    this.meta,
    this.unreadCount = 0,
    this.totalCount = 0,
    this.message,
    this.isMessageError = false,
    this.actionNotificationId,
  });

  final NotificationsStatus status;
  final List<AppNotification> notifications;
  final PaginationMeta? meta;
  final int unreadCount;
  final int totalCount;
  final String? message;
  final bool isMessageError;
  final int? actionNotificationId;

  bool get isLoading => status == NotificationsStatus.loading;
  bool get isLoadingMore => status == NotificationsStatus.loadingMore;
  bool get hasData => notifications.isNotEmpty;
  bool get canLoadMore => meta?.hasNextPage ?? false;
  int get nextPage => meta?.nextPage ?? 1;
  bool get hasUnread => unreadCount > 0;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? notifications,
    PaginationMeta? meta,
    int? unreadCount,
    int? totalCount,
    String? message,
    bool? isMessageError,
    int? actionNotificationId,
    bool clearNotifications = false,
    bool clearMeta = false,
    bool clearMessage = false,
    bool clearAction = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: clearNotifications
          ? const <AppNotification>[]
          : (notifications ?? this.notifications),
      meta: clearMeta ? null : (meta ?? this.meta),
      unreadCount: unreadCount ?? this.unreadCount,
      totalCount: totalCount ?? this.totalCount,
      message: clearMessage ? null : (message ?? this.message),
      isMessageError: isMessageError ?? this.isMessageError,
      actionNotificationId: clearAction
          ? null
          : (actionNotificationId ?? this.actionNotificationId),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    notifications,
    meta,
    unreadCount,
    totalCount,
    message,
    isMessageError,
    actionNotificationId,
  ];
}
