import 'package:beauty_center_app/features/favorites/widgets/favorite_heart_button.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ClinicServiceCard extends StatelessWidget {
  const ClinicServiceCard({
    required this.title,
    required this.description,
    required this.durationMinutes,
    required this.preparationMinutes,
    required this.originalPrice,
    required this.finalPrice,
    this.badge,
    this.darkBadge = false,
    this.isFavorite = false,
    this.onFavoriteToggle,
    this.centerName,
    this.onTap,
    super.key,
  });

  final String title;
  final String description;
  final int durationMinutes;
  final int preparationMinutes;
  final double originalPrice;
  final double finalPrice;
  final String? badge;
  final bool darkBadge;
  final bool isFavorite;
  final Future<void> Function(bool isCurrentlyFavorite)? onFavoriteToggle;
  final String? centerName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool hasDiscount = originalPrice > finalPrice;
    final Widget card = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x100A2A55),
            blurRadius: 16,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (centerName != null) ...<Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.storefront_outlined,
                  size: 12,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    centerName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.link.copyWith(
                    color: AppColors.primary,
                    fontSize: 16,
                  ),
                ),
              ),
              if (badge != null) ...[
                const SizedBox(width: 12),
                _ServiceBadge(label: badge!, isDark: darkBadge),
              ],
              if (onFavoriteToggle != null) ...<Widget>[
                const SizedBox(width: 8),
                FavoriteHeartButton(
                  isFavorite: isFavorite,
                  size: 19,
                  padding: const EdgeInsets.all(4),
                  backgroundColor: Colors.transparent,
                  onToggle: (bool isCurrentlyFavorite) async {
                    if (onFavoriteToggle != null) {
                      await onFavoriteToggle!(isCurrentlyFavorite);
                    }
                  },
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          _ExpandableDescription(description),
          const SizedBox(height: 22),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.schedule_rounded,
                size: 16,
                color: Color(0xFF806221),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.clinicDurationMinutes(durationMinutes),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle.copyWith(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (preparationMinutes > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        l10n.clinicPrepMinutes(preparationMinutes),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subtitle.copyWith(
                          color: const Color(0xFF9EA6B0),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    if (hasDiscount) ...<Widget>[
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerEnd,
                        child: Text(
                          l10n.priceSp(_formatPriceWithCommas(originalPrice)),
                          maxLines: 1,
                          style: const TextStyle(
                            color: Color(0xFF9EA6B0),
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerEnd,
                      child: Text(
                        l10n.priceSp(_formatPriceWithCommas(finalPrice)),
                        maxLines: 1,
                        style: AppTextStyles.title.copyWith(
                          fontSize: 18,
                          color: hasDiscount
                              ? const Color(0xFFD32F2F)
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: card,
      );
    }
    return card;
  }

  String _formatPriceWithCommas(double price) {
    String val = price.toStringAsFixed(0);
    RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return val.replaceAllMapped(reg, (Match match) => '${match[1]},');
  }
}

class _ExpandableDescription extends StatefulWidget {
  const _ExpandableDescription(this.text);

  static const int collapsedMaxLines = 3;

  final String text;

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _isExpanded = false;

  @override
  void didUpdateWidget(_ExpandableDescription oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _isExpanded = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextStyle style = AppTextStyles.subtitle.copyWith(
      fontSize: 13,
      height: 1.45,
      color: const Color(0xFF4D5560),
    );

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final TextPainter painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: _ExpandableDescription.collapsedMaxLines,
          textDirection: Directionality.of(context),
        )..layout(maxWidth: constraints.maxWidth);
        final bool canExpand = painter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: Text(
                widget.text,
                maxLines: _isExpanded
                    ? null
                    : _ExpandableDescription.collapsedMaxLines,
                overflow: _isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: style,
              ),
            ),
            if (canExpand) ...<Widget>[
              const SizedBox(height: 4),
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Text(
                    _isExpanded ? l10n.readLess : l10n.readMore,
                    style: AppTextStyles.link.copyWith(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ServiceBadge extends StatelessWidget {
  const _ServiceBadge({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primarySoft : const Color(0xFFFFD996),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: AppTextStyles.smallCaps.copyWith(
          color: isDark ? AppColors.surface : const Color(0xFF6B4D17),
          fontSize: 8,
        ),
      ),
    );
  }
}
