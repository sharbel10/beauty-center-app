import 'package:beauty_center_app/core/services/firebase_messaging_service.dart';
import 'package:beauty_center_app/core/storage/secure_storage.dart';
import 'package:beauty_center_app/core/utils/app_logger.dart';
import 'package:beauty_center_app/features/device/repository/device_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@singleton
class DeviceRegistrationService {
  DeviceRegistrationService(
    this._firebaseMessagingService,
    this._deviceRepository,
    this._secureStorage,
  );

  final FirebaseMessagingService _firebaseMessagingService;
  final DeviceRepository _deviceRepository;
  final SecureStorage _secureStorage;

  String? _lastFcmToken;
  bool _tokenRefreshListenerAttached = false;

  void attachTokenRefreshListener() {
    if (_tokenRefreshListenerAttached ||
        !_firebaseMessagingService.isFirebaseAvailable) {
      return;
    }
    _tokenRefreshListenerAttached = true;
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      _lastFcmToken = token;
      // ignore: unawaited_futures
      syncDeviceToken(fcmToken: token);
    });
  }

  Future<void> syncDeviceToken({String? fcmToken}) async {
    if (!_firebaseMessagingService.isFirebaseAvailable) {
      return;
    }

    final String? accessToken = await _secureStorage.getToken();
    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    final String? token =
        fcmToken ?? await _firebaseMessagingService.requestPermissionAndGetToken();
    if (token == null || token.isEmpty) {
      return;
    }

    _lastFcmToken = token;
    final String platform = _platformName();
    final result = await _deviceRepository.registerDevice(
      fcmToken: token,
      platform: platform,
    );
    result.fold(
      (failure) => AppLogger.e('FCM device registration failed: ${failure.message}'),
      (_) => AppLogger.d('FCM device registered with backend'),
    );
  }

  Future<void> unregisterDeviceToken() async {
    if (!_firebaseMessagingService.isFirebaseAvailable) {
      return;
    }

    final String? token =
        _lastFcmToken ?? await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      final result = await _deviceRepository.unregisterDevice(fcmToken: token);
      result.fold(
        (failure) =>
            AppLogger.e('FCM device unregister failed: ${failure.message}'),
        (_) => AppLogger.d('FCM device unregistered from backend'),
      );
    }

    try {
      await FirebaseMessaging.instance.deleteToken();
    } catch (error, stackTrace) {
      AppLogger.e('Failed to delete local FCM token', error, stackTrace);
    }
    _lastFcmToken = null;
  }

  String _platformName() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'android';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ios';
    }
    return defaultTargetPlatform.name;
  }
}
