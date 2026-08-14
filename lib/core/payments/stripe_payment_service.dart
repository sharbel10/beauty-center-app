import 'package:beauty_center_app/core/payments/stripe_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

/// Ready for the backend integration: pass the PaymentIntent client secret
/// returned by the API, then present Stripe's native test PaymentSheet.
class StripePaymentService {
  Future<void> presentPaymentSheet({required String clientSecret}) async {
    if (clientSecret.trim().isEmpty) {
      throw ArgumentError.value(
        clientSecret,
        'clientSecret',
        'Cannot be empty',
      );
    }
    if (!StripeConfig.hasPublishableKey) {
      throw StateError('STRIPE_PUBLISHABLE_KEY is not configured.');
    }

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'Lumina',
        returnURL: StripeConfig.returnUrl,
        style: ThemeMode.system,
      ),
    );
    await Stripe.instance.presentPaymentSheet();
  }
}
