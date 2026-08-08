import 'package:equatable/equatable.dart';

class ToggleFavoriteResponse extends Equatable {
  const ToggleFavoriteResponse({
    required this.success,
    required this.message,
    required this.favorite,
  });

  factory ToggleFavoriteResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};

    return ToggleFavoriteResponse(
      success: json['success'] as bool? ?? true,
      message: json['message'] as String? ?? '',
      favorite: FavoriteData.fromJson(
        data['favorite'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }

  final bool success;
  final String message;
  final FavoriteData favorite;

  @override
  List<Object?> get props => [success, message, favorite];
}

class FavoriteData extends Equatable {
  const FavoriteData({
    this.id,
    required this.type,
    this.favoritableId,
    required this.isFavorite,
    this.createdAt,
  });

  factory FavoriteData.fromJson(Map<String, dynamic> json) {
    return FavoriteData(
      id: json['id'] as int?,
      type: json['type'] as String? ?? '',
      favoritableId: json['favoritable_id'] as int?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
    );
  }

  final int? id;
  final String type;
  final int? favoritableId;
  final bool isFavorite;
  final String? createdAt;

  @override
  List<Object?> get props => [id, type, favoritableId, isFavorite, createdAt];
}
