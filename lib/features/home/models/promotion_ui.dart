import 'package:beauty_center_app/features/home/models/offer.dart';

class PromotionUiModel {
  const PromotionUiModel({
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
  }) {
    return PromotionUiModel(
      badge: badge,
      title: offer.title,
      subtitle: offer.center?.name ?? '',
      description: offer.description ?? '',
      price: _formatPrice(offer),
      oldPrice: '',
      cta: 'CLAIM OFFER',
      isDark: isDark,
    );
  }

  final String badge;
  final String title;
  final String subtitle;
  final String description;
  final String price;
  final String oldPrice;
  final String cta;
  final bool isDark;

  static String _formatPrice(Offer offer) {
    if (offer.discountType == 'percentage') {
      final String value = offer.discountValue.truncateToDouble() ==
              offer.discountValue
          ? offer.discountValue.toStringAsFixed(0)
          : offer.discountValue.toStringAsFixed(1);
      return '$value% OFF';
    }
    return '${offer.discountValue.toStringAsFixed(0)} OFF';
  }
}
