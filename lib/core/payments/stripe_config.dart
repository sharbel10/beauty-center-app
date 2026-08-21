import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

abstract final class StripeConfig {
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_test_51S4fU42LRHIDfiQ3zgSYkUanqgCpFBcf5ij9aEpOvEaq9fX6QxgYAwUQCTtLZSl8MRJaXCqOftVWUlxtrEXLO45500X3tcPha5',
  );
  static const String urlScheme = 'lumina';
  static const String returnUrl = '$urlScheme://stripe-redirect';

  static bool _isInitialized = false;

  static bool get hasPublishableKey => publishableKey.startsWith('pk_');
  static bool get isInitialized => _isInitialized;

  static Future<void> initialize() async {
    final bool isMobile =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    if (kIsWeb || !isMobile || !hasPublishableKey) {
      return;
    }

    Stripe.publishableKey = publishableKey;
    Stripe.urlScheme = urlScheme;
    try {
      await Stripe.instance.applySettings();
      _isInitialized = true;
    } on MissingPluginException catch (error) {
      // Native plugins are unavailable in stale hot-reload engines and on
      // unsupported runners. Stripe must not prevent the app from starting.
      _isInitialized = false;
      debugPrint('Stripe native plugin is unavailable: $error');
    }
  }
}
