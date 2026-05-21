import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    this.parentId,
    required this.name,
    required this.slug,
    this.description,
    this.iconPath,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      parentId: json['parent_id'] as int?,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      iconPath: json['icon_path'] as String?,
    );
  }

  final int id;
  final int? parentId;
  final String name;
  final String slug;
  final String? description;
  final String? iconPath;

  bool get isTopLevel => parentId == null;

  @override
  List<Object?> get props => [id, parentId, name, slug, description, iconPath];
}
