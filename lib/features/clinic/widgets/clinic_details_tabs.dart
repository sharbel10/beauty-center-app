import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ClinicDetailsTabs extends SliverPersistentHeaderDelegate {
  ClinicDetailsTabs({required this.selectedIndex, required this.onChanged});

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<String> tabs = <String>[
      l10n.clinicTabOverview,
      l10n.clinicTabServices,
      l10n.clinicTabGallery,
      l10n.clinicTabInfo,
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isActive = index == selectedIndex;

          return Expanded(
            child: InkWell(
              onTap: () => onChanged(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        tabs[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subtitle.copyWith(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: 2,
                    width: isActive ? 64 : 0,
                    color: AppColors.gold,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant ClinicDetailsTabs oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex;
  }
}
