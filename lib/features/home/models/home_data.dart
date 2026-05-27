import 'package:beauty_center_app/features/home/models/advertisement.dart';
import 'package:beauty_center_app/features/home/models/category.dart';
import 'package:beauty_center_app/features/home/models/clinic_center.dart';
import 'package:beauty_center_app/features/home/models/offer.dart';
import 'package:equatable/equatable.dart';

class HomeData extends Equatable {
  static const int featuredPreviewLimit = 3;
  static const int promotionsPreviewLimit = 6;

  const HomeData({
    required this.categories,
    required this.featuredCenters,
    required this.offers,
    required this.advertisements,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      categories: (json['categories'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (dynamic item) => Category.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      featuredCenters:
          (json['featured_centers'] as List<dynamic>? ?? <dynamic>[])
              .map(
                (dynamic item) =>
                    ClinicCenter.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      offers: (json['offers'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => Offer.fromJson(item as Map<String, dynamic>))
          .toList(),
      advertisements: (json['advertisements'] as List<dynamic>? ?? <dynamic>[])
          .map(
            (dynamic item) =>
                Advertisement.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final List<Category> categories;
  final List<ClinicCenter> featuredCenters;
  final List<Offer> offers;
  final List<Advertisement> advertisements;

  List<Category> get topLevelCategories =>
      categories.where((Category c) => c.isTopLevel).toList();

  List<ClinicCenter> get previewFeaturedCenters =>
      featuredCenters.take(featuredPreviewLimit).toList();

  List<Offer> get previewOffers => offers.take(promotionsPreviewLimit).toList();

  @override
  List<Object?> get props => [
    categories,
    featuredCenters,
    offers,
    advertisements,
  ];
}
