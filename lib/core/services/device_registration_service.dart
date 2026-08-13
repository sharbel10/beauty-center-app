import 'package:beauty_center_app/core/failures/failure.dart';
import 'package:beauty_center_app/core/services/firebase_messaging_service.dart';
import 'package:beauty_center_app/core/storage/preference_manager.dart';
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
    this._preferenceManager,
  );

  final FirebaseMessagingService _firebaseMessagingService;
  final DeviceRepository _deviceRepository;
  final SecureStorage _secureStorage;
  final PreferenceManager _preferenceManager;

  String? _lastDeviceToken;
  bool _tokenRefreshListenerAttached = false;

  void attachTokenRefreshListener() {
    if (_tokenRefreshListenerAttached ||
        !_firebaseMessagingService.isFirebaseAvailable) {
      return;
    }
    _tokenRefreshListenerAttached = true;
    FirebaseMessaging.instance.onTokenRefresh.listen((String token) {
      _lastDeviceToken = token;
      // ignore: unawaited_futures
      syncDeviceToken(deviceToken: token);
    });
  }

  Future<void> syncDeviceToken({String? deviceToken}) async {
    if (!_firebaseMessagingService.isFirebaseAvailable) {
      return;
    }

    final String? accessToken = await _secureStorage.getToken();
    if (accessToken == null || accessToken.isEmpty) {
      return;
    }

    final String? token =
        deviceToken ??
        await _firebaseMessagingService.requestPermissionAndGetToken();
    if (token == null || token.isEmpty) {
      return;
    }

    _lastDeviceToken = token;
    final result = await _deviceRepository.registerDevice(
      deviceToken: token,
      platform: _platformName(),
      deviceName: _deviceName(),
      locale: _preferenceManager.getLanguage() ?? 'ar',
    );
    result.fold(
      (failure) =>
          AppLogger.e('FCM device registration failed: ${failure.message}'),
      (_) => AppLogger.d('FCM device registered with backend'),
    );
  }

  Future<void> unregisterDeviceToken({bool deleteLocalToken = true}) async {
    if (!_firebaseMessagingService.isFirebaseAvailable) {
      return;
    }

    final String? token =
        _lastDeviceToken ?? await FirebaseMessaging.instance.getToken();
    if (token != null && token.isNotEmpty) {
      final result = await _deviceRepository.unregisterDevice(
        deviceToken: token,
      );
      result.fold(
        (Failure failure) {
          if (failure is UnauthorizedFailure) {
            AppLogger.d(
              'FCM device unregister skipped: token already invalid '
              '(${failure.message})',
            );
            return;
          }
          AppLogger.e('FCM device unregister failed: ${failure.message}');
        },
        (_) => AppLogger.d('FCM device unregistered from backend'),
      );
    }

    if (deleteLocalToken) {
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (error, stackTrace) {
        AppLogger.e('Failed to delete local FCM token', error, stackTrace);
      }
      _lastDeviceToken = null;
    }
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

  String _deviceName() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Android Device';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'iOS Device';
    }
    return defaultTargetPlatform.name;
  }
}
