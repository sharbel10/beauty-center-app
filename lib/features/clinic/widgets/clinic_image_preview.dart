import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_network_image.dart';
import 'package:flutter/material.dart';

bool hasClinicImageUrl(String? imageUrl) => imageUrl?.trim().isNotEmpty == true;

typedef ClinicPreviewImageBuilder =
    Widget Function(VoidCallback onLoaded, VoidCallback onError);

class ClinicPreviewableImage extends StatefulWidget {
  const ClinicPreviewableImage({
    required this.imageUrl,
    required this.builder,
    super.key,
  });

  final String imageUrl;
  final ClinicPreviewImageBuilder builder;

  @override
  State<ClinicPreviewableImage> createState() => _ClinicPreviewableImageState();
}

class _ClinicPreviewableImageState extends State<ClinicPreviewableImage> {
  bool _isLoaded = false;

  @override
  void didUpdateWidget(ClinicPreviewableImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _isLoaded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget image = widget.builder(_markLoaded, _markFailed);
    if (!_isLoaded || !hasClinicImageUrl(widget.imageUrl)) {
      return image;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showClinicImagePreview(context, imageUrl: widget.imageUrl),
      child: image,
    );
  }

  void _markLoaded() {
    if (mounted && !_isLoaded) {
      setState(() => _isLoaded = true);
    }
  }

  void _markFailed() {
    if (mounted && _isLoaded) {
      setState(() => _isLoaded = false);
    }
  }
}

Future<void> showClinicImagePreview(
  BuildContext context, {
  required String imageUrl,
}) async {
  if (!hasClinicImageUrl(imageUrl)) {
    return;
  }

  await showDialog<void>(
    context: context,
    barrierColor: Colors.black,
    builder: (BuildContext dialogContext) {
      return Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: ClinicNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.contain,
                    errorWidget: const Icon(
                      Icons.broken_image_outlined,
                      color: AppColors.surface,
                      size: 52,
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: IconButton.filled(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.55),
                    foregroundColor: AppColors.surface,
                  ),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
