import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _priceRange = const RangeValues(100, 850);

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return FractionallySizedBox(
      heightFactor: 0.74,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(42)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(34, 26, 34, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 76,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 34),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.filters,
                        style: AppTextStyles.headline.copyWith(fontSize: 34),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(
                          () => _priceRange = const RangeValues(100, 850),
                        );
                      },
                      child: Text(
                        l10n.clearAll,
                        style: AppTextStyles.smallCaps.copyWith(
                          color: const Color(0xFF7B5A21),
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 38),
                _FilterSectionTitle(l10n.filterServiceType),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 14,
                  runSpacing: 18,
                  children: [
                    _FilterOptionChip(
                      label: l10n.filterFacialTreatment,
                      isSelected: true,
                      showClose: true,
                    ),
                    _FilterOptionChip(label: l10n.filterBotoxFillers),
                    _FilterOptionChip(label: l10n.filterLaserHairRemoval),
                    _FilterOptionChip(label: l10n.filterBodyContouring),
                    _FilterOptionChip(label: l10n.filterChemicalPeel),
                  ],
                ),
                const SizedBox(height: 48),
                _FilterSectionTitle(l10n.filterPriceRange),
                const SizedBox(height: 42),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.primarySoft,
                    thumbColor: AppColors.surface,
                    overlayColor: AppColors.primary.withValues(alpha: 0.1),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 13,
                      elevation: 2,
                    ),
                    trackHeight: 5,
                  ),
                  child: RangeSlider(
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    values: _priceRange,
                    labels: RangeLabels(
                      l10n.priceUsd(_priceRange.start.round()),
                      l10n.priceUsd(_priceRange.end.round()),
                    ),
                    onChanged: (values) {
                      setState(() => _priceRange = values);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _PriceBox(
                      label: l10n.min,
                      value: l10n.priceUsd(_priceRange.start.round()),
                    ),
                    _PriceBox(
                      label: l10n.max,
                      value: l10n.priceUsd(_priceRange.end.round()),
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                _FilterSectionTitle(l10n.clinicLocation),
                const SizedBox(height: 24),
                _LocationDropdown(label: l10n.filterLocationBeverlyHills),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    _LocationChip(l10n.filterLocationSantaMonica),
                    _LocationChip(l10n.filterLocationWestHollywood),
                    _LocationChip(l10n.filterLocationDowntownLa),
                    _LocationChip(l10n.filterLocationMalibu),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterSectionTitle extends StatelessWidget {
  const _FilterSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.title.copyWith(fontSize: 27));
  }
}

class _FilterOptionChip extends StatelessWidget {
  const _FilterOptionChip({
    required this.label,
    this.isSelected = false,
    this.showClose = false,
  });

  final String label;
  final bool isSelected;
  final bool showClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.subtitle.copyWith(
              color: isSelected ? AppColors.surface : AppColors.primary,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (showClose) ...[
            const SizedBox(width: 10),
            Icon(
              Icons.close_rounded,
              color: isSelected ? AppColors.surface : AppColors.primary,
              size: 24,
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceBox extends StatelessWidget {
  const _PriceBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104,
      height: 92,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: AppTextStyles.subtitle.copyWith(
              color: AppColors.textSecondary,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.link.copyWith(fontSize: 22)),
        ],
      ),
    );
  }
}

class _LocationDropdown extends StatelessWidget {
  const _LocationDropdown({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.subtitle.copyWith(
                color: AppColors.primary,
                fontSize: 22,
              ),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.primary,
            size: 30,
          ),
        ],
      ),
    );
  }
}

class _LocationChip extends StatelessWidget {
  const _LocationChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.primarySoft),
      ),
      child: Text(
        label,
        style: AppTextStyles.subtitle.copyWith(
          color: AppColors.primary,
          fontSize: 18,
        ),
      ),
    );
  }
}
