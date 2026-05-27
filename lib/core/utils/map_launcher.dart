import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens map URLs in the browser or an external maps app.
abstract final class MapLauncher {
  static Uri openStreetMapUri(double latitude, double longitude) {
    return Uri.parse(
      'https://www.openstreetmap.org/?mlat=$latitude&mlon=$longitude'
      '#map=16/$latitude/$longitude',
    );
  }

  static Future<bool> openOpenStreetMap({
    required double latitude,
    required double longitude,
  }) {
    return launchExternalUrl(openStreetMapUri(latitude, longitude));
  }

  static Future<bool> launchExternalUrl(Uri uri) async {
    try {
      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.inAppBrowserView,
      );
      if (launched) {
        return true;
      }

      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException catch (error, stackTrace) {
      debugPrint('url_launcher PlatformException: $error\n$stackTrace');
      if (!kIsWeb && Platform.isAndroid) {
        return _launchAndroidViewIntent(uri);
      }
      return false;
    } catch (error, stackTrace) {
      debugPrint('url_launcher error: $error\n$stackTrace');
      if (!kIsWeb && Platform.isAndroid) {
        return _launchAndroidViewIntent(uri);
      }
      return false;
    }
  }

  static Future<bool> _launchAndroidViewIntent(Uri uri) async {
    try {
      final AndroidIntent intent = AndroidIntent(
        action: 'action_view',
        data: uri.toString(),
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
      return true;
    } on PlatformException catch (error, stackTrace) {
      debugPrint('AndroidIntent PlatformException: $error\n$stackTrace');
      return false;
    } catch (error, stackTrace) {
      debugPrint('AndroidIntent error: $error\n$stackTrace');
      return false;
    }
  }
}
