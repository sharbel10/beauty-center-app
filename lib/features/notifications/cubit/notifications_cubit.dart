import 'package:beauty_center_app/features/notifications/cubit/notifications_state.dart';
import 'package:beauty_center_app/features/notifications/models/app_notification.dart';
import 'package:beauty_center_app/features/notifications/repository/notifications_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState());

  static const int defaultPerPage = 15;

  final NotificationsRepository _repository;

  Future<void> loadCounts() async {
    final result = await _repository.getCounts();
    if (isClosed) {
      return;
    }

    result.fold(
      (_) {},
      (response) => emit(
        state.copyWith(
          unreadCount: response.unreadCount,
          totalCount: response.totalCount,
        ),
      ),
    );
  }

  Future<void> onPushReceived() async {
    emit(state.copyWith(unreadCount: state.unreadCount + 1));
    await loadCounts();
    if (state.status == NotificationsStatus.success) {
      await loadNotifications();
    }
  }

  Future<void> loadNotifications() async {
    emit(
      state.copyWith(
        status: NotificationsStatus.loading,
        clearMessage: true,
        clearNotifications: true,
        clearMeta: true,
      ),
    );

    final result = await _repository.getNotifications(
      page: 1,
      perPage: defaultPerPage,
    );
    if (isClosed) {
      return;
    }

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotificationsStatus.failure,
          message: failure.message,
          isMessageError: true,
        ),
      ),
      (response) => emit(
        state.copyWith(
          status: NotificationsStatus.success,
          notifications: response.notifications,
          meta: response.meta,
          unreadCount: response.unreadCount,
          clearMessage: true,
        ),
      ),
    );
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore || state.isLoadingMore || state.isLoading) {
      return;
    }

    emit(
      state.copyWith(
        status: NotificationsStatus.loadingMore,
        clearMessage: true,
      ),
    );

    final result = await _repository.getNotifications(
      page: state.nextPage,
      perPage: defaultPerPage,
    );
    if (isClosed) {
      return;
    }

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: NotificationsStatus.failure,
          message: failure.message,
          isMessageError: true,
        ),
      ),
      (response) {
        final List<AppNotification> merged = <AppNotification>[
          ...state.notifications,
          ...response.notifications.where(
            (AppNotification item) => !state.notifications.any(
              (AppNotification existing) => existing.id == item.id,
            ),
          ),
        ];
        emit(
          state.copyWith(
            status: NotificationsStatus.success,
            notifications: merged,
            meta: response.meta,
            unreadCount: response.unreadCount,
          ),
        );
      },
    );
  }

  Future<void> markAsRead(int id) async {
    final AppNotification? current = _findById(id);
    if (current == null || current.isRead) {
      return;
    }

    emit(state.copyWith(actionNotificationId: id, clearMessage: true));

    final result = await _repository.markAsRead(id);
    if (isClosed) {
      return;
    }

    result.fold(
      (failure) => emit(
        state.copyWith(
          message: failure.message,
          isMessageError: true,
          clearAction: true,
        ),
      ),
      (response) {
        final AppNotification updated =
            response.notification ??
            current.copyWith(isRead: true, readAt: DateTime.now());
        emit(
          state.copyWith(
            notifications: _replace(updated),
            unreadCount: response.unreadCount,
            clearAction: true,
          ),
        );
      },
    );
  }

  Future<void> markAllAsRead() async {
    if (!state.hasUnread) {
      return;
    }

    emit(state.copyWith(clearMessage: true));

    final result = await _repository.markAllAsRead();
    if (isClosed) {
      return;
    }

    result.fold(
      (failure) =>
          emit(state.copyWith(message: failure.message, isMessageError: true)),
      (response) {
        final List<AppNotification> updated = state.notifications
            .map(
              (AppNotification item) => item.isRead
                  ? item
                  : item.copyWith(isRead: true, readAt: DateTime.now()),
            )
            .toList();

        emit(
          state.copyWith(
            notifications: updated,
            unreadCount: response.unreadCount,
            message: response.message,
            isMessageError: false,
          ),
        );
      },
    );
  }

  Future<void> deleteNotification(int id) async {
    emit(state.copyWith(actionNotificationId: id, clearMessage: true));

    final result = await _repository.deleteNotification(id);
    if (isClosed) {
      return;
    }

    result.fold(
      (failure) => emit(
        state.copyWith(
          message: failure.message,
          isMessageError: true,
          clearAction: true,
        ),
      ),
      (response) {
        emit(
          state.copyWith(
            notifications: state.notifications
                .where((AppNotification item) => item.id != id)
                .toList(),
            unreadCount: response.unreadCount,
            message: response.message,
            isMessageError: false,
            clearAction: true,
          ),
        );
      },
    );
  }

  void clearMessage() {
    if (state.message != null) {
      emit(state.copyWith(clearMessage: true));
    }
  }

  void reset() {
    emit(const NotificationsState());
  }

  AppNotification? _findById(int id) {
    for (final AppNotification item in state.notifications) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  List<AppNotification> _replace(AppNotification updated) {
    return state.notifications
        .map((AppNotification item) => item.id == updated.id ? updated : item)
        .toList();
  }
}
