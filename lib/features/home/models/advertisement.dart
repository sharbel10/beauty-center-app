import 'package:equatable/equatable.dart';

class Advertisement extends Equatable {
  const Advertisement({
    required this.id,
    required this.title,
    this.body,
    this.imagePath,
    this.linkUrl,
    this.placement,
  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String?,
      imagePath: json['image_path'] as String?,
      linkUrl: json['link_url'] as String?,
      placement: json['placement'] as String?,
    );
  }

  final int id;
  final String title;
  final String? body;
  final String? imagePath;
  final String? linkUrl;
  final String? placement;

  @override
  List<Object?> get props => [id, title, body, imagePath, linkUrl, placement];
}
