import 'package:equatable/equatable.dart';

class ClinicServicesResponse extends Equatable {
  const ClinicServicesResponse({required this.success, required this.services});

  factory ClinicServicesResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> servicesList =
        json['data']['services'] as List<dynamic>? ?? <dynamic>[];
    return ClinicServicesResponse(
      success: json['success'] as bool? ?? true,
      services: servicesList
          .map(
            (dynamic item) =>
                ClinicServiceItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final bool success;
  final List<ClinicServiceItem> services;

  @override
  List<Object?> get props => [success, services];
}

class ServiceCategory extends Equatable {
  const ServiceCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.iconPath,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      iconPath: json['icon_path'] as String? ?? '',
    );
  }

  final int id;
  final String name;
  final String slug;
  final String iconPath;

  @override
  List<Object?> get props => [id, name, slug, iconPath];
}

class ClinicServiceItem extends Equatable {
  const ClinicServiceItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.salePrice,
    required this.finalPrice,
    required this.durationMinutes,
    required this.preparationMinutes,
    required this.imagePath,
    required this.isFeatured,
    required this.category,
  });

  factory ClinicServiceItem.fromJson(Map<String, dynamic> json) {
    return ClinicServiceItem(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: json['price'] as int? ?? 0,
      salePrice: json['sale_price'] as int?,
      finalPrice: json['final_price'] as int? ?? 0,
      durationMinutes: json['duration_minutes'] as int? ?? 0,
      preparationMinutes: json['preparation_minutes'] as int? ?? 0,
      imagePath: json['image_path'] as String? ?? '',
      isFeatured: json['is_featured'] as bool? ?? false,
      category: ServiceCategory.fromJson(
        json['category'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }

  final int id;
  final String name;
  final String description;
  final int price;
  final int? salePrice;
  final int finalPrice;
  final int durationMinutes;
  final int preparationMinutes;
  final String imagePath;
  final bool isFeatured;
  final ServiceCategory category;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    price,
    salePrice,
    finalPrice,
    durationMinutes,
    imagePath,
    isFeatured,
    category,
  ];
}
