import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/features/home/models/category.dart';
import 'package:flutter/material.dart';

class HomeCategoryChips extends StatelessWidget {
  const HomeCategoryChips({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    super.key,
  });

  static const double _chipHeight = 38;

  final List<Category> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _chipHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length + 1,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _CategoryChip(
              label: 'All',
              isActive: selectedCategoryId == null,
              icon: Icons.grid_view_rounded,
              onTap: () => onCategorySelected(null),
            );
          }

          final Category category = categories[index - 1];
          final String? iconUrl = category.iconPath != null
              ? ApiEndpoints.mediaUrl(category.iconPath)
              : null;

          return _CategoryChip(
            label: category.name,
            isActive: selectedCategoryId == category.id,
            iconUrl: iconUrl,
            onTap: () => onCategorySelected(category.id),
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isActive,
    required this.onTap,
    this.icon,
    this.iconUrl,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final IconData? icon;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primarySoft : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: isActive ? null : Border.all(color: AppColors.divider),
            boxShadow: isActive
                ? null
                : const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x080A2A55),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _ChipIcon(isActive: isActive, icon: icon, iconUrl: iconUrl),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.link.copyWith(
                  color: isActive ? AppColors.surface : AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipIcon extends StatelessWidget {
  const _ChipIcon({required this.isActive, this.icon, this.iconUrl});

  final bool isActive;
  final IconData? icon;
  final String? iconUrl;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isActive ? AppColors.surface : AppColors.gold;

    if (iconUrl != null && iconUrl!.isNotEmpty) {
      return Image.network(
        iconUrl!,
        width: 15,
        height: 15,
        fit: BoxFit.contain,
        errorBuilder:
            (BuildContext context, Object error, StackTrace? stackTrace) =>
                Icon(
                  icon ?? Icons.category_outlined,
                  color: iconColor,
                  size: 15,
                ),
      );
    }

    return Icon(icon ?? Icons.category_outlined, color: iconColor, size: 15);
  }
}
