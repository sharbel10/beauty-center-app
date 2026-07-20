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
    } catch (error, stackTrace) {
      debugPrint('url_launcher error: $error\n$stackTrace');
    }

    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException catch (error, stackTrace) {
      debugPrint(
        'url_launcher external PlatformException: $error\n$stackTrace',
      );
      return false;
    } catch (error, stackTrace) {
      debugPrint('url_launcher external error: $error\n$stackTrace');
      return false;
    }
  }
}
