import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/core/utils/map_launcher.dart';
import 'package:beauty_center_app/core/widgets/app_bottom_navigation.dart';
import 'package:beauty_center_app/core/widgets/app_button.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_details_cubit.dart';
import 'package:beauty_center_app/features/clinic/views/clinic_details_view.dart';
import 'package:beauty_center_app/features/explore/cubit/explore_cubit.dart';
import 'package:beauty_center_app/features/explore/cubit/explore_state.dart';
import 'package:beauty_center_app/features/home/models/category.dart';
import 'package:beauty_center_app/features/home/models/clinic_center.dart';
import 'package:beauty_center_app/features/home/widgets/clinic_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({required ExploreCubit cubit, super.key}) : _cubit = cubit;

  final ExploreCubit _cubit;

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  final TextEditingController _searchController = TextEditingController();

  // Captured once: the router's builder re-runs on every push/pop and
  // creates a fresh ExploreCubit from getIt, which would otherwise replace
  // the loaded one with an empty instance.
  late final ExploreCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget._cubit;
    _cubit.loadInitial();
  }

  @override
  void didUpdateWidget(ExploreView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget._cubit, _cubit)) {
      widget._cubit.close();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _cubit.close();
    super.dispose();
  }

  Future<void> _submitSearch() async {
    await _cubit.updateSearch(_searchController.text);
  }

  void _showFilters(BuildContext context) {
    final ExploreCubit cubit = context.read<ExploreCubit>();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<ExploreCubit>.value(
        value: cubit,
        child: const _FilterBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ExploreCubit>.value(
      value: _cubit,
      child: BlocConsumer<ExploreCubit, ExploreState>(
        listenWhen: (ExploreState previous, ExploreState current) =>
            previous.message != current.message &&
            current.message != null &&
            current.status == ExploreStatus.failure,
        listener: (BuildContext context, ExploreState state) {
          context.showSnackbar(state.message!, isError: true);
        },
        builder: (BuildContext context, ExploreState state) {
          return Scaffold(
            backgroundColor: AppColors.scaffold,
            extendBody: true,
            bottomNavigationBar: const AppBottomNavigation(
              currentItem: AppNavItem.explore,
            ),
            body: SafeArea(
              bottom: false,
              child: RefreshIndicator(
                onRefresh: _cubit.refreshCenters,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            _SearchAndFilter(
                              controller: _searchController,
                              isLoading: state.isLoading,
                              onSearch: _submitSearch,
                              onFilter: () => _showFilters(context),
                            ),
                            const SizedBox(height: 14),
                            _ActiveFilters(
                              state: state,
                              onClearCategory: () {
                                _cubit.updateCategory(null);
                              },
                              onClearPrice: () {
                                _cubit.resetPriceFilter();
                              },
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'All Clinics',
                              style: AppTextStyles.headline.copyWith(
                                fontSize: 24,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      ),
                    ),
                    if (state.isLoading && !state.hasCenters)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (!state.hasCenters)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _EmptyClinicsState(
                          onRetry: _cubit.loadInitial,
                        ),
                      )
                    else
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(
                          24,
                          0,
                          24,
                          24 + AppBottomNavigation.contentOverlap(context),
                        ),
                        sliver: SliverList.separated(
                          itemCount:
                              state.centers.length +
                              (state.canLoadMore ? 1 : 0),
                          separatorBuilder: (BuildContext context, int index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (BuildContext context, int index) {
                            if (index >= state.centers.length) {
                              return Center(
                                child: SizedBox(
                                  width: 190,
                                  child: AppButton(
                                    text: 'Load More',
                                    isLoading: state.isLoadingMore,
                                    onPressed: _cubit.loadMore,
                                    height: 48,
                                  ),
                                ),
                              );
                            }

                            return _ClinicCard(clinic: state.centers[index]);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SearchAndFilter extends StatelessWidget {
  const _SearchAndFilter({
    required this.controller,
    required this.isLoading,
    required this.onSearch,
    required this.onFilter,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSearch;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x080A2A55),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              enabled: !isLoading,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => onSearch(),
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 14),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 15,
                ),
                hintText: 'Search clinics...',
                hintStyle: AppTextStyles.hint.copyWith(fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.textSecondary,
                  size: 21,
                ),
                suffixIcon: IconButton(
                  onPressed: isLoading ? null : onSearch,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  color: AppColors.primary,
                  iconSize: 19,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 104,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: onFilter,
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: Text(
              'Filters',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.button.copyWith(fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 3,
              shadowColor: AppColors.primary.withValues(alpha: 0.16),
              backgroundColor: AppColors.primarySoft,
              foregroundColor: AppColors.surface,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActiveFilters extends StatelessWidget {
  const _ActiveFilters({
    required this.state,
    required this.onClearCategory,
    required this.onClearPrice,
  });

  final ExploreState state;
  final VoidCallback onClearCategory;
  final VoidCallback onClearPrice;

  @override
  Widget build(BuildContext context) {
    final List<Widget> chips = <Widget>[];
    final int? selectedCategoryId = state.selectedCategoryId;

    if (selectedCategoryId != null) {
      Category? category;
      for (final Category item in state.categories) {
        if (item.id == selectedCategoryId) {
          category = item;
          break;
        }
      }
      if (category != null) {
        chips.add(_FilterChip(label: category.name, onClear: onClearCategory));
      }
    }

    if (state.hasPriceFilter) {
      chips.add(
        _FilterChip(
          label: '\$${state.minPrice} - \$${state.maxPrice}',
          onClear: onClearPrice,
        ),
      );
    }

    if (chips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(spacing: 12, runSpacing: 12, children: chips);
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.onClear});

  final String label;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onClear,
        borderRadius: BorderRadius.circular(26),
        child: Ink(
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                style: AppTextStyles.subtitle.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.close_rounded,
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClinicCard extends StatefulWidget {
  const _ClinicCard({required this.clinic});

  final ClinicCenter clinic;

  @override
  State<_ClinicCard> createState() => _ClinicCardState();
}

class _ClinicCardState extends State<_ClinicCard> {
  ClinicCenter get clinic => widget.clinic;

  Future<void> _openMap() async {
    if (clinic.latitude == null || clinic.longitude == null) {
      context.showSnackbar(
        'Location is not available for this clinic.',
        isError: true,
      );
      return;
    }

    final bool launched = await MapLauncher.openOpenStreetMap(
      latitude: clinic.latitude!,
      longitude: clinic.longitude!,
    );

    if (!launched && mounted) {
      context.showSnackbar('Could not open maps.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String description = clinic.description?.trim().isNotEmpty == true
        ? clinic.description!.trim()
        : 'Clinic center';

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x100A2A55),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 176,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ClinicNetworkImage(imageUrl: _mediaUrl(clinic.coverPath)),
                  Align(
                    alignment: Alignment.topRight,
                    child: Container(
                      margin: const EdgeInsets.all(12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: Color(0x140A2A55),
                            blurRadius: 12,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.gold,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            clinic.averageRating.toStringAsFixed(1),
                            style: AppTextStyles.link.copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    clinic.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(
                      fontSize: 19,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            height: 1.25,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _MapButton(
                        enabled:
                            clinic.latitude != null && clinic.longitude != null,
                        onPressed: _openMap,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ClinicStats(clinic: clinic),
                  const SizedBox(height: 16),
                  AppButton(
                    text: 'View & Book',
                    icon: Icons.chevron_right_rounded,
                    height: 48,
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ClinicDetailsView(
                            centerId: clinic.id,
                            cubit: getIt<ClinicDetailsCubit>(),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _mediaUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }
    if (path.startsWith('http')) {
      return path;
    }
    return ApiEndpoints.mediaUrl(path);
  }
}

class _ClinicStats extends StatelessWidget {
  const _ClinicStats({required this.clinic});

  final ClinicCenter clinic;

  @override
  Widget build(BuildContext context) {
    final String areaValue = clinic.area?.isNotEmpty == true
        ? clinic.area!
        : clinic.city?.isNotEmpty == true
        ? clinic.city!
        : clinic.isFeatured
        ? 'Top Pick'
        : 'Clinic';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _StatItem(label: 'AREA', value: areaValue),
          ),
          Container(width: 1, height: 30, color: AppColors.divider),
          Expanded(
            child: _StatItem(
              label: 'DISTANCE',
              value: clinic.distance != null
                  ? '${clinic.distance!.toStringAsFixed(1)} km'
                  : 'N/A',
            ),
          ),
        ],
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? AppColors.primary.withValues(alpha: 0.08)
          : AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(
            Icons.navigation_rounded,
            color: enabled ? AppColors.primary : AppColors.textMuted,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: AppTextStyles.smallCaps),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.title.copyWith(fontSize: 16)),
        ],
      ),
    );
  }
}

class _EmptyClinicsState extends StatelessWidget {
  const _EmptyClinicsState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.storefront_outlined,
            size: 52,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 14),
          Text('No clinics found.', style: AppTextStyles.titleMedium),
          const SizedBox(height: 18),
          SizedBox(
            width: 180,
            child: AppButton(text: 'Retry', onPressed: onRetry, height: 48),
          ),
        ],
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  bool _initialized = false;
  int? _selectedCategoryId;
  late RangeValues _priceValues;

  void _ensureInitialValues(ExploreState state) {
    if (_initialized) {
      return;
    }
    _selectedCategoryId = state.selectedCategoryId;
    _priceValues = RangeValues(
      state.minPrice.toDouble(),
      state.maxPrice.toDouble(),
    );
    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreCubit, ExploreState>(
      builder: (BuildContext context, ExploreState state) {
        _ensureInitialValues(state);
        final List<Category> topLevelCategories = state.categories
            .where((Category category) => category.isTopLevel)
            .toList();

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.78,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              22,
              10,
              22,
              22 + MediaQuery.paddingOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Filters',
                        style: AppTextStyles.title.copyWith(
                          fontSize: 22,
                          height: 1.1,
                        ),
                      ),
                    ),
                    _SheetIconButton(
                      icon: Icons.close_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _FilterSection(
                  title: 'Categories',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      _FilterChoice(
                        label: 'All',
                        selected: _selectedCategoryId == null,
                        onSelected: () {
                          setState(() => _selectedCategoryId = null);
                        },
                      ),
                      for (final Category category in topLevelCategories)
                        _FilterChoice(
                          label: category.name,
                          selected: _selectedCategoryId == category.id,
                          onSelected: () {
                            setState(() => _selectedCategoryId = category.id);
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _FilterSection(
                  title: 'Pricing',
                  child: _PriceRangeSlider(
                    values: _priceValues,
                    maxLimit: ExploreState.defaultMaxPrice,
                    onChanged: (RangeValues values) {
                      setState(() => _priceValues = values);
                    },
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _selectedCategoryId = null;
                            _priceValues = RangeValues(
                              0.0,
                              ExploreState.defaultMaxPrice.toDouble(),
                            );
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.divider),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          'Reset',
                          style: AppTextStyles.link.copyWith(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'Apply',
                        onPressed: () async {
                          final ExploreCubit cubit = context
                              .read<ExploreCubit>();
                          Navigator.of(context).pop();
                          await cubit.applyFilters(
                            categoryId: _selectedCategoryId,
                            minPrice: _priceValues.start.round(),
                            maxPrice: _priceValues.end.round(),
                          );
                        },
                        height: 46,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: AppTextStyles.smallCaps.copyWith(
                color: AppColors.primary,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _PriceRangeSlider extends StatelessWidget {
  const _PriceRangeSlider({
    required this.values,
    required this.maxLimit,
    required this.onChanged,
  });

  final RangeValues values;
  final int maxLimit;
  final ValueChanged<RangeValues> onChanged;

  @override
  Widget build(BuildContext context) {
    final int min = values.start.round();
    final int max = values.end.round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: _PricePill(label: 'Min', value: min),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _PricePill(label: 'Max', value: max),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.divider,
            thumbColor: AppColors.surface,
            overlayColor: AppColors.primary.withValues(alpha: 0.12),
            rangeThumbShape: const RoundRangeSliderThumbShape(
              enabledThumbRadius: 10,
              elevation: 3,
            ),
            rangeTrackShape: const RoundedRectRangeSliderTrackShape(),
            trackHeight: 4,
            valueIndicatorColor: AppColors.primary,
            valueIndicatorTextStyle: AppTextStyles.bodySmall.copyWith(
              color: AppColors.surface,
              fontWeight: FontWeight.w700,
            ),
          ),
          child: RangeSlider(
            min: 0,
            max: maxLimit.toDouble(),
            divisions: maxLimit ~/ 50,
            values: values,
            labels: RangeLabels('\$$min', '\$$max'),
            onChanged: onChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('\$0', style: AppTextStyles.bodySmall),
            Text('\$$maxLimit', style: AppTextStyles.bodySmall),
          ],
        ),
      ],
    );
  }
}

class _PricePill extends StatelessWidget {
  const _PricePill({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label,
              style: AppTextStyles.smallCaps.copyWith(
                fontSize: 9,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 3),
            Text('\$$value', style: AppTextStyles.link.copyWith(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class _FilterChoice extends StatelessWidget {
  const _FilterChoice({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      labelStyle: AppTextStyles.bodySmall.copyWith(
        color: selected ? AppColors.surface : AppColors.textSecondary,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
      ),
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      side: BorderSide(color: selected ? AppColors.primary : AppColors.divider),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }
}

class _SheetIconButton extends StatelessWidget {
  const _SheetIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceMuted,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
      ),
    );
  }
}
