import 'dart:async';

import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/router/app_router.dart';
import 'package:beauty_center_app/core/services/local_notifications_service.dart';
import 'package:beauty_center_app/core/utils/app_logger.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_cubit.dart';
import 'package:beauty_center_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:beauty_center_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.d('Background FCM message: ${message.messageId}');
  } catch (_) {
    // Firebase config is not available until project files are added.
  }
}

@singleton
class FirebaseMessagingService {
  final LocalNotificationsService _localNotifications =
      LocalNotificationsService();

  bool _isInitialized = false;
  bool _isFirebaseAvailable = false;
  Map<String, dynamic>? _pendingNavigation;

  bool get isFirebaseAvailable => _isFirebaseAvailable;

  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }
    _isInitialized = true;

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _isFirebaseAvailable = true;

      await _localNotifications.initialize(
        onTap: _handleNotificationNavigation,
      );

      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpened);

      final RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        _onMessageOpened(initialMessage);
      }
    } catch (error, stackTrace) {
      _isFirebaseAvailable = false;
      AppLogger.e(
        'Firebase is not configured yet. Add google-services.json and run '
        'flutterfire configure. See docs/FIREBASE_ANDROID_SETUP.md',
        error,
        stackTrace,
      );
    }
  }

  Future<String?> requestPermissionAndGetToken() async {
    if (!_isFirebaseAvailable) {
      return null;
    }

    final NotificationSettings settings = await FirebaseMessaging.instance
        .requestPermission(alert: true, badge: true, sound: true);
    final bool allowed =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!allowed) {
      return null;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      await FirebaseMessaging.instance.getAPNSToken();
    }

    return FirebaseMessaging.instance.getToken();
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    AppLogger.d(
      'Foreground FCM message: ${message.messageId} '
      'data=${message.data}',
    );
    await _localNotifications.showFromRemoteMessage(message);
    if (getIt.isRegistered<NotificationsCubit>()) {
      await getIt<NotificationsCubit>().onPushReceived();
    }
  }

  void _onMessageOpened(RemoteMessage message) {
    AppLogger.d('Opened FCM message: ${message.messageId} data=${message.data}');
    _handleNotificationNavigation(message.data);
  }

  void consumePendingNavigation() {
    final Map<String, dynamic>? pending = _pendingNavigation;
    if (pending == null) {
      return;
    }
    _pendingNavigation = null;
    _openNotification(pending);
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    if (!getIt.isRegistered<AuthCubit>() ||
        !getIt<AuthCubit>().state.isAuthenticated) {
      _pendingNavigation = data;
      return;
    }
    _openNotification(data);
  }

  void _openNotification(Map<String, dynamic> data) {
    final String type = data['type']?.toString() ?? '';
    final String? notificationId =
        data['notification_id']?.toString() ?? data['id']?.toString();
    final int? parsedId = int.tryParse(notificationId ?? '');

    if (parsedId != null && getIt.isRegistered<NotificationsCubit>()) {
      // ignore: unawaited_futures
      getIt<NotificationsCubit>().markAsRead(parsedId);
    }

    AppRouter.navigateFromNotification(
      type: type.isEmpty ? 'notifications' : type,
      id: notificationId,
      appointmentId: data['appointment_id']?.toString(),
      centerId: data['center_id']?.toString(),
    );
  }
}
