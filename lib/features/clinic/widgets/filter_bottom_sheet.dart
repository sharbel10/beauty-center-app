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
                        'Filters',
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
                        'CLEAR ALL',
                        style: AppTextStyles.smallCaps.copyWith(
                          color: const Color(0xFF7B5A21),
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 38),
                const _FilterSectionTitle('Service Type'),
                const SizedBox(height: 24),
                const Wrap(
                  spacing: 14,
                  runSpacing: 18,
                  children: [
                    _FilterOptionChip(
                      label: 'Facial Treatment',
                      isSelected: true,
                      showClose: true,
                    ),
                    _FilterOptionChip(label: 'Botox & Fillers'),
                    _FilterOptionChip(label: 'Laser Hair Removal'),
                    _FilterOptionChip(label: 'Body Contouring'),
                    _FilterOptionChip(label: 'Chemical Peel'),
                  ],
                ),
                const SizedBox(height: 48),
                const _FilterSectionTitle('Price Range'),
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
                      '\$${_priceRange.start.round()}',
                      '\$${_priceRange.end.round()}',
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
                      label: 'Min',
                      value: '\$${_priceRange.start.round()}',
                    ),
                    _PriceBox(
                      label: 'Max',
                      value: '\$${_priceRange.end.round()}',
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                const _FilterSectionTitle('Location'),
                const SizedBox(height: 24),
                const _LocationDropdown(label: 'Beverly Hills, CA'),
                const SizedBox(height: 18),
                const Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: [
                    _LocationChip('Santa Monica'),
                    _LocationChip('West Hollywood'),
                    _LocationChip('Downtown LA'),
                    _LocationChip('Malibu'),
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
