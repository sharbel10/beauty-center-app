import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

abstract final class StripeConfig {
  static const String publishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  );
  static const String urlScheme = 'lumina';
  static const String returnUrl = '$urlScheme://stripe-redirect';

  static bool get hasPublishableKey => publishableKey.startsWith('pk_');

  static Future<void> initialize() async {
    final bool isMobile =
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
    if (kIsWeb || !isMobile || !hasPublishableKey) {
      return;
    }

    Stripe.publishableKey = publishableKey;
    Stripe.urlScheme = urlScheme;
    await Stripe.instance.applySettings();
  }
}
