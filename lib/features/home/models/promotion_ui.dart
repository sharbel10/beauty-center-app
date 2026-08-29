import 'package:beauty_center_app/features/home/models/offer.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';

class PromotionUiModel {
  const PromotionUiModel({
    required this.centerId,
    this.serviceId,
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.oldPrice,
    required this.cta,
    required this.isDark,
  });

  factory PromotionUiModel.fromOffer(
    Offer offer, {
    required bool isDark,
    required String badge,
    required String cta,
    required String price,
  }) {
    return PromotionUiModel(
      centerId: offer.centerId,
      serviceId: offer.serviceId,
      badge: badge,
      title: offer.title,
      subtitle: offer.center?.name ?? '',
      description: offer.description ?? '',
      price: price,
      oldPrice: '',
      cta: cta,
      isDark: isDark,
    );
  }

  final int centerId;
  final int? serviceId;
  final String badge;
  final String title;
  final String subtitle;
  final String description;
  final String price;
  final String oldPrice;
  final String cta;
  final bool isDark;

  static String formatPrice(Offer offer, AppLocalizations l10n) {
    if (offer.discountType == 'percentage') {
      return l10n.offerDiscountPercent(offer.discountValue.round());
    }
    return l10n.offerDiscountAmount(offer.discountValue.round());
  }
}
