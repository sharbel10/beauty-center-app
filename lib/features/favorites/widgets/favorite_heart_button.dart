import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FavoriteHeartButton extends StatefulWidget {
  const FavoriteHeartButton({
    required this.isFavorite,
    required this.onToggle,
    this.size = 22,
    this.padding = const EdgeInsets.all(8),
    this.backgroundColor,
    this.tooltip,
    this.showLoading = true,
    this.enableFeedback = true,
    this.activeColor = const Color(0xFFFF4D4D),
    this.inactiveColor,
    super.key,
  });

  final bool isFavorite;
  final Future<void> Function(bool isCurrentlyFavorite) onToggle;
  final double size;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final String? tooltip;
  final bool showLoading;
  final bool enableFeedback;
  final Color activeColor;
  final Color? inactiveColor;

  @override
  State<FavoriteHeartButton> createState() => _FavoriteHeartButtonState();
}

class _FavoriteHeartButtonState extends State<FavoriteHeartButton>
    with SingleTickerProviderStateMixin {
  late bool _localIsFavorite;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _localIsFavorite = widget.isFavorite;
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      value: 1.0,
    );
    _scaleAnimation =
        TweenSequence<double>(<TweenSequenceItem<double>>[
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.0, end: 1.35),
            weight: 0.5,
          ),
          TweenSequenceItem<double>(
            tween: Tween<double>(begin: 1.35, end: 1.0),
            weight: 0.5,
          ),
        ]).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
        );
  }

  @override
  void didUpdateWidget(FavoriteHeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      _localIsFavorite = widget.isFavorite;
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isLoading) {
      return;
    }

    if (widget.enableFeedback) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        HapticFeedback.lightImpact();
      });
    }

    final bool oldValue = _localIsFavorite;
    final bool newValue = !oldValue;

    setState(() {
      _localIsFavorite = newValue;
      _isLoading = true;
      _scaleController.forward();
    });

    bool success = true;
    try {
      await widget.onToggle(oldValue);
    } catch (_) {
      success = false;
    } finally {
      if (mounted) {
        setState(() {
          if (!success) {
            _localIsFavorite = oldValue;
          }
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color resolvedInactive =
        widget.inactiveColor ?? const Color(0xFFFF4D4D).withValues(alpha: 0.6);

    Widget icon = AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (_, __) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(
            _localIsFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: _isLoading && widget.showLoading
                ? AppColors.textMuted.withValues(alpha: 0.5)
                : _localIsFavorite
                ? widget.activeColor
                : resolvedInactive,
            size: widget.size,
          ),
        );
      },
    );

    if (_isLoading && widget.showLoading) {
      icon = Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Opacity(opacity: 0, child: icon),
          SizedBox(
            width: widget.size,
            height: widget.size,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF4D4D)),
            ),
          ),
        ],
      );
    }

    final Widget result = Material(
      color:
          widget.backgroundColor ?? AppColors.surface.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      elevation: widget.backgroundColor == null ? 2 : 0,
      shadowColor: widget.backgroundColor == null
          ? const Color(0x140A2A55)
          : Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        borderRadius: BorderRadius.circular(999),
        customBorder: const CircleBorder(),
        child: Padding(padding: widget.padding, child: icon),
      ),
    );

    if (widget.tooltip != null) {
      return Tooltip(
        message: widget.tooltip,
        preferBelow: false,
        child: result,
      );
    }

    return result;
  }
}
