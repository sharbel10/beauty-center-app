import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ClinicNetworkImage extends StatelessWidget {
  const ClinicNetworkImage({required this.imageUrl, super.key});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _placeholder();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) =>
              _placeholder(),
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
      child: const Icon(
        Icons.storefront_outlined,
        color: AppColors.textMuted,
        size: 40,
      ),
    );
  }
}
