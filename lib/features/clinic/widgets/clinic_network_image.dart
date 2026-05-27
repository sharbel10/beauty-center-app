import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ClinicNetworkImage extends StatelessWidget {
  const ClinicNetworkImage({
    required this.imageUrl,
    super.key,
    this.placeholderIcon = Icons.image_not_supported_outlined,
    this.headers,
    this.errorWidget,
  });

  final String imageUrl;
  final IconData placeholderIcon;
  final Map<String, String>? headers;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return errorWidget ?? _placeholder();
    }

    return Image.network(
      imageUrl,
      headers: headers,
      fit: BoxFit.cover,
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            debugPrint('ClinicNetworkImage Error: $error');
            return errorWidget ?? _placeholder();
          },
      loadingBuilder:
          (BuildContext context, Widget child, ImageChunkEvent? progress) {
            if (progress == null) {
              return child;
            }
            return ColoredBox(
              color: AppColors.surfaceMuted,
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            );
          },
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: AppColors.surfaceMuted,
      child: Center(
        child: Icon(placeholderIcon, color: AppColors.textMuted, size: 40),
      ),
    );
  }
}
