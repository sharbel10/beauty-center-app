import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class ClinicNetworkImage extends StatefulWidget {
  const ClinicNetworkImage({
    required this.imageUrl,
    super.key,
    this.placeholderIcon = Icons.image_not_supported_outlined,
    this.headers,
    this.errorWidget,
    this.fit = BoxFit.cover,
    this.onLoaded,
    this.onError,
  });

  final String imageUrl;
  final IconData placeholderIcon;
  final Map<String, String>? headers;
  final Widget? errorWidget;
  final BoxFit fit;
  final VoidCallback? onLoaded;
  final VoidCallback? onError;

  @override
  State<ClinicNetworkImage> createState() => _ClinicNetworkImageState();
}

class _ClinicNetworkImageState extends State<ClinicNetworkImage> {
  bool _didNotifyLoaded = false;
  bool _didNotifyError = false;

  @override
  void didUpdateWidget(ClinicNetworkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _didNotifyLoaded = false;
      _didNotifyError = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrl.isEmpty) {
      return widget.errorWidget ?? _placeholder();
    }

    return Image.network(
      widget.imageUrl,
      headers: widget.headers,
      fit: widget.fit,
      frameBuilder:
          (
            BuildContext context,
            Widget child,
            int? frame,
            bool wasSynchronouslyLoaded,
          ) {
            if (frame != null || wasSynchronouslyLoaded) {
              _notifyLoaded();
            }
            return child;
          },
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            debugPrint('ClinicNetworkImage Error: $error');
            _notifyError();
            return widget.errorWidget ?? _placeholder();
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

  void _notifyLoaded() {
    if (_didNotifyLoaded) return;
    _didNotifyLoaded = true;
    _didNotifyError = false;
    final String loadedUrl = widget.imageUrl;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.imageUrl == loadedUrl) {
        widget.onLoaded?.call();
      }
    });
  }

  void _notifyError() {
    if (_didNotifyError) return;
    _didNotifyError = true;
    _didNotifyLoaded = false;
    final String failedUrl = widget.imageUrl;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.imageUrl == failedUrl) {
        widget.onError?.call();
      }
    });
  }

  Widget _placeholder() {
    return ColoredBox(
      color: AppColors.surfaceMuted,
      child: Center(
        child: Icon(
          widget.placeholderIcon,
          color: AppColors.textMuted,
          size: 40,
        ),
      ),
    );
  }
}
