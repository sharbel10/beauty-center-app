import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/network/base_repository.dart';
import 'package:beauty_center_app/features/notifications/models/notification_action_response.dart';
import 'package:beauty_center_app/features/notifications/models/notification_counts_response.dart';
import 'package:beauty_center_app/features/notifications/models/notifications_list_response.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class NotificationsRepository extends BaseRepository {
  NotificationsRepository(super.dioClient);

  Future<Either<Failure, NotificationsListResponse>> getNotifications({
    int page = 1,
    int perPage = 15,
    bool unreadOnly = false,
  }) {
    return callApiWithErrorParser(
      dio.get(
        ApiEndpoints.notifications,
        queryParameters: <String, dynamic>{
          'page': page,
          'per_page': perPage,
          if (unreadOnly) 'unread_only': true,
        },
      ),
      NotificationsListResponse.fromJson,
    );
  }

  Future<Either<Failure, NotificationCountsResponse>> getCounts() {
    return callApiWithErrorParser(
      dio.get(ApiEndpoints.notificationCounts),
      NotificationCountsResponse.fromJson,
    );
  }

  Future<Either<Failure, NotificationActionResponse>> markAsRead(int id) {
    return callApiWithErrorParser(
      dio.patch(ApiEndpoints.notificationRead(id)),
      NotificationActionResponse.fromJson,
    );
  }

  Future<Either<Failure, NotificationActionResponse>> markAllAsRead() {
    return callApiWithErrorParser(
      dio.patch(ApiEndpoints.notificationsReadAll),
      NotificationActionResponse.fromJson,
    );
  }

  Future<Either<Failure, NotificationActionResponse>> deleteNotification(
    int id,
  ) {
    return callApiWithErrorParser(
      dio.delete(ApiEndpoints.notificationById(id)),
      NotificationActionResponse.fromJson,
    );
  }
}
