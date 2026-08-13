import 'dart:convert';

import 'package:beauty_center_app/core/utils/app_logger.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef NotificationTapHandler = void Function(Map<String, dynamic> data);

class LocalNotificationsService {
  static const String channelId = 'lumina_high_importance';
  static const String channelName = 'Notifications';
  static const String channelDescription = 'App alerts and updates';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize({required NotificationTapHandler onTap}) async {
    if (_isInitialized) {
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      ),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleTap(response, onTap);
      },
    );

    if (defaultTargetPlatform == TargetPlatform.android) {
      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              channelId,
              channelName,
              description: channelDescription,
              importance: Importance.high,
            ),
          );

      await _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    }

    _isInitialized = true;
  }

  Future<void> showFromRemoteMessage(RemoteMessage message) async {
    if (!_isInitialized) {
      return;
    }

    final RemoteNotification? notification = message.notification;
    final String title =
        notification?.title ?? message.data['title']?.toString() ?? 'Lumina';
    final String body =
        notification?.body ??
        message.data['body']?.toString() ??
        'You have a new notification';

    final int notificationId =
        message.messageId?.hashCode ?? message.hashCode;

    try {
      await _plugin.show(
        notificationId,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelName,
            channelDescription: channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/launcher_icon',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (error, stackTrace) {
      AppLogger.e('Failed to show local notification', error, stackTrace);
    }
  }

  void _handleTap(
    NotificationResponse response,
    NotificationTapHandler onTap,
  ) {
    final String? payload = response.payload;
    if (payload == null || payload.isEmpty) {
      return;
    }
    try {
      final Map<String, dynamic> data =
          jsonDecode(payload) as Map<String, dynamic>;
      onTap(data);
    } catch (error, stackTrace) {
      AppLogger.e('Invalid notification payload', error, stackTrace);
    }
  }
}
