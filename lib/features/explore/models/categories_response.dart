import 'package:beauty_center_app/features/home/models/category.dart';
import 'package:equatable/equatable.dart';

class CategoriesResponse extends Equatable {
  const CategoriesResponse({
    required this.success,
    required this.categories,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? data = json['data'] as Map<String, dynamic>?;

    return CategoriesResponse(
      success: json['success'] as bool? ?? true,
      categories: (data?['categories'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic item) => Category.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final bool success;
  final List<Category> categories;

  @override
  List<Object?> get props => [success, categories];
}
