import 'package:beauty_center_app/core/payments/stripe_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:injectable/injectable.dart';

enum StripeSheetResult { completed, cancelled }

/// Ready for the backend integration: pass the PaymentIntent client secret
/// returned by the API, then present Stripe's native test PaymentSheet.
@lazySingleton
class StripePaymentService {
  Future<StripeSheetResult> presentPaymentSheet({
    required String clientSecret,
  }) async {
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
    if (!StripeConfig.isInitialized) {
      throw StateError(
        'Stripe native plugin is not initialized. Perform a full app restart.',
      );
    }

    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: 'Lumina',
          returnURL: StripeConfig.returnUrl,
          style: ThemeMode.system,
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      return StripeSheetResult.completed;
    } on StripeException catch (error) {
      if (error.error.code == FailureCode.Canceled) {
        return StripeSheetResult.cancelled;
      }
      rethrow;
    }
  }
}
