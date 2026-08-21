import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/services/location_service.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/core/utils/map_launcher.dart';
import 'package:beauty_center_app/core/widgets/app_bottom_navigation.dart';
import 'package:beauty_center_app/core/widgets/app_button.dart';
import 'package:beauty_center_app/core/widgets/root_exit_guard.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_details_cubit.dart';
import 'package:beauty_center_app/features/clinic/views/clinic_details_view.dart';
import 'package:beauty_center_app/features/explore/cubit/explore_cubit.dart';
import 'package:beauty_center_app/features/explore/cubit/explore_state.dart';
import 'package:beauty_center_app/features/explore/models/center_filters.dart';
import 'package:beauty_center_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:beauty_center_app/features/favorites/cubit/favorites_state.dart';
import 'package:beauty_center_app/features/favorites/widgets/favorite_heart_button.dart';
import 'package:beauty_center_app/features/home/models/category.dart';
import 'package:beauty_center_app/features/home/models/clinic_center.dart';
import 'package:beauty_center_app/features/home/widgets/clinic_network_image.dart';
import 'package:beauty_center_app/features/home/widgets/home_category_chips.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExploreView extends StatefulWidget {
  const ExploreView({
    required ExploreCubit cubit,
    this.initialCategoryId,
    super.key,
  }) : _cubit = cubit;

  final ExploreCubit _cubit;
  final int? initialCategoryId;

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
    if (widget.initialCategoryId != null) {
      _cubit.loadInitialWithCategory(widget.initialCategoryId);
    } else {
      _cubit.loadInitial();
    }
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
    await _cubit.submitSearch(_searchController.text);
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
      child: BlocProvider<FavoritesCubit>(
        create: (_) => getIt<FavoritesCubit>(),
        child: BlocListener<FavoritesCubit, FavoritesState>(
          listenWhen: (FavoritesState previous, FavoritesState current) {
            return previous.message != current.message &&
                current.message != null;
          },
          listener: (BuildContext context, FavoritesState state) {
            if (state.message != null) {
              context.showSnackbar(
                state.message!,
                isError: state.isMessageError,
              );
              context.read<FavoritesCubit>().clearMessage();
            }
          },
          child: BlocConsumer<ExploreCubit, ExploreState>(
            listenWhen: (ExploreState previous, ExploreState current) =>
                previous.message != current.message &&
                current.message != null &&
                current.status == ExploreStatus.failure,
            listener: (BuildContext context, ExploreState state) {
              context.showSnackbar(state.message!, isError: true);
            },
            builder: (BuildContext context, ExploreState state) {
              final AppLocalizations l10n = AppLocalizations.of(context);

              return RootExitGuard(
                child: Scaffold(
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
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                22,
                                24,
                                20,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  _SearchAndFilter(
                                    controller: _searchController,
                                    isLoading: state.isLoading,
                                    onSearch: _submitSearch,
                                    onChanged: _cubit.onSearchChanged,
                                    onFilter: () => _showFilters(context),
                                  ),
                                  const SizedBox(height: 14),
                                  _ActiveFilters(
                                    state: state,
                                    onClearPrice: () {
                                      _cubit.clearPrice();
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    l10n.allClinics,
                                    style: AppTextStyles.headline.copyWith(
                                      fontSize: 24,
                                      height: 1.1,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  HomeCategoryChips(
                                    categories: state.categories
                                        .where(
                                          (Category category) =>
                                              category.isTopLevel,
                                        )
                                        .toList(),
                                    selectedCategoryId:
                                        state.filters.categoryId,
                                    onCategorySelected: (int? categoryId) {
                                      _cubit.applyFilters(
                                        CenterFilters(
                                          categoryId: categoryId,
                                          governorate:
                                              state.filters.governorate,
                                          isFeatured: state.filters.isFeatured,
                                          requiresDeposit:
                                              state.filters.requiresDeposit,
                                          minPrice: state.filters.minPrice,
                                          maxPrice: state.filters.maxPrice,
                                          latitude: state.filters.latitude,
                                          longitude: state.filters.longitude,
                                          sortBy: state.filters.sortBy,
                                        ),
                                      );
                                    },
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
                                24 +
                                    AppBottomNavigation.contentOverlap(context),
                              ),
                              sliver: SliverList.separated(
                                itemCount:
                                    state.centers.length +
                                    (state.canLoadMore ? 1 : 0),
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        const SizedBox(height: 16),
                                itemBuilder: (BuildContext context, int index) {
                                  if (index >= state.centers.length) {
                                    return Center(
                                      child: SizedBox(
                                        width: 190,
                                        child: AppButton(
                                          text: l10n.loadMore,
                                          isLoading: state.isLoadingMore,
                                          onPressed: _cubit.loadMore,
                                          height: 48,
                                        ),
                                      ),
                                    );
                                  }

                                  return _ClinicCard(
                                    clinic: state.centers[index],
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SearchAndFilter extends StatelessWidget {
  const _SearchAndFilter({
    required this.controller,
    required this.isLoading,
    required this.onSearch,
    required this.onChanged,
    required this.onFilter,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSearch;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

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
              maxLength: 255,
              onChanged: onChanged,
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
                counterText: '',
                hintText: l10n.searchClinics,
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
              l10n.filters,
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
  const _ActiveFilters({required this.state, required this.onClearPrice});

  final ExploreState state;
  final VoidCallback onClearPrice;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final List<Widget> chips = <Widget>[];
    final CenterFilters filters = state.filters;
    if (filters.minPrice != null || filters.maxPrice != null) {
      chips.add(
        _FilterChip(
          label: '${filters.minPrice ?? 0}–${filters.maxPrice ?? '∞'}',
          onClear: onClearPrice,
        ),
      );
    }

    if (filters.governorate != null ||
        filters.isFeatured != null ||
        filters.requiresDeposit != null ||
        filters.sortBy != 'rating') {
      chips.add(
        _FilterChip(
          label: l10n.filters,
          onClear: () => context.read<ExploreCubit>().resetFilters(),
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
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (clinic.latitude == null || clinic.longitude == null) {
      context.showSnackbar(l10n.locationUnavailableForClinic, isError: true);
      return;
    }

    final bool launched = await MapLauncher.openOpenStreetMap(
      latitude: clinic.latitude!,
      longitude: clinic.longitude!,
    );

    if (!launched && mounted) {
      context.showSnackbar(l10n.couldNotOpenMaps, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String description = clinic.description?.trim().isNotEmpty == true
        ? clinic.description!.trim()
        : l10n.clinicCenter;

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
                  Positioned(
                    top: 12,
                    left: 12,
                    child: FavoriteHeartButton(
                      isFavorite: clinic.isFavorite,
                      size: 18,
                      padding: const EdgeInsets.all(8),
                      onToggle: (bool isCurrentlyFavorite) async {
                        await context
                            .read<FavoritesCubit>()
                            .toggleCenterFavorite(
                              centerId: clinic.id,
                              isCurrentlyFavorite: isCurrentlyFavorite,
                            );
                      },
                    ),
                  ),
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
                    text: l10n.viewAndBook,
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String areaValue = clinic.area?.isNotEmpty == true
        ? clinic.area!
        : clinic.city?.isNotEmpty == true
        ? clinic.city!
        : clinic.isFeatured
        ? l10n.topPick
        : l10n.clinic;

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
            child: _StatItem(label: l10n.area, value: areaValue),
          ),
          Container(width: 1, height: 30, color: AppColors.divider),
          Expanded(
            child: _StatItem(
              label: l10n.distance,
              value: clinic.distance != null
                  ? '${clinic.distance!.toStringAsFixed(1)} km'
                  : l10n.notAvailable,
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
    final AppLocalizations l10n = AppLocalizations.of(context);

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
          Text(l10n.noClinicsFound, style: AppTextStyles.titleMedium),
          const SizedBox(height: 18),
          SizedBox(
            width: 180,
            child: AppButton(text: l10n.retry, onPressed: onRetry, height: 48),
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
  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  String? _governorate;
  bool? _isFeatured;
  bool? _requiresDeposit;
  String _sortBy = 'rating';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _ensureInitialValues(ExploreState state) {
    if (_initialized) {
      return;
    }
    final CenterFilters filters = state.filters;
    _selectedCategoryId = filters.categoryId;
    _minPriceController = TextEditingController(
      text: _number(filters.minPrice),
    );
    _maxPriceController = TextEditingController(
      text: _number(filters.maxPrice),
    );
    _governorate = filters.governorate;
    _isFeatured = filters.isFeatured;
    _requiresDeposit = filters.requiresDeposit;
    _sortBy = filters.sortBy;
    _initialized = true;
  }

  @override
  void dispose() {
    if (_initialized) {
      _minPriceController.dispose();
      _maxPriceController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExploreCubit, ExploreState>(
      builder: (BuildContext context, ExploreState state) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        _ensureInitialValues(state);
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.78,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Form(
            key: _formKey,
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
                          l10n.filters,
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
                  _FilterDropdown<String>(
                    label: l10n.sortBy,
                    value: _sortBy,
                    items: centerSortOptions,
                    itemLabel: (value) => _centerSortLabel(l10n, value),
                    onChanged: (value) => setState(() => _sortBy = value!),
                  ),
                  _FilterDropdown<String?>(
                    label: l10n.governorate,
                    value: _governorate,
                    items: <String?>[null, ...centerGovernorates],
                    itemLabel: (value) => value == null
                        ? l10n.anyOption
                        : value.replaceAll('_', ' '),
                    onChanged: (value) => setState(() => _governorate = value),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _FilterDropdown<bool?>(
                          label: l10n.featuredOnly,
                          value: _isFeatured,
                          items: const <bool?>[null, true, false],
                          itemLabel: (value) => value == null
                              ? l10n.anyOption
                              : value
                              ? l10n.yesOption
                              : l10n.noOption,
                          onChanged: (value) =>
                              setState(() => _isFeatured = value),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FilterDropdown<bool?>(
                          label: l10n.requiresDeposit,
                          value: _requiresDeposit,
                          items: const <bool?>[null, true, false],
                          itemLabel: (value) => value == null
                              ? l10n.anyOption
                              : value
                              ? l10n.yesOption
                              : l10n.noOption,
                          onChanged: (value) =>
                              setState(() => _requiresDeposit = value),
                        ),
                      ),
                    ],
                  ),
                  _FilterSection(
                    title: l10n.priceRange,
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _FilterNumberField(
                                label: l10n.minimumPrice,
                                controller: _minPriceController,
                                min: 0,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _FilterNumberField(
                                label: l10n.maximumPrice,
                                controller: _maxPriceController,
                                min: 0,
                                validator: (_) => _validatePrices(l10n),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          l10n.currency,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const SizedBox(height: 22),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            context.read<ExploreCubit>().resetFilters();
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
                            l10n.reset,
                            style: AppTextStyles.link.copyWith(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: l10n.apply,
                          onPressed: _apply,
                          height: 46,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String? _validatePrices(AppLocalizations l10n) {
    final double? min = _parse(_minPriceController.text);
    final double? max = _parse(_maxPriceController.text);
    return min != null && max != null && max < min
        ? l10n.invalidPriceRange
        : null;
  }

  Future<void> _apply() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    double? latitude;
    double? longitude;
    if (_sortBy == 'nearest') {
      final LocationResult result = await getIt<LocationService>()
          .getCurrentLocation();
      if (!mounted) return;
      if (!result.isSuccess) {
        context.showSnackbar(
          AppLocalizations.of(context).locationPermissionRequired,
          isError: true,
        );
        return;
      }
      latitude = result.location!.latitude;
      longitude = result.location!.longitude;
    }
    final CenterFilters filters = CenterFilters(
      categoryId: _selectedCategoryId,
      governorate: _governorate,
      isFeatured: _isFeatured,
      requiresDeposit: _requiresDeposit,
      minPrice: _parse(_minPriceController.text),
      maxPrice: _parse(_maxPriceController.text),
      latitude: latitude,
      longitude: longitude,
      sortBy: _sortBy,
    );
    if (!mounted) return;
    final ExploreCubit cubit = context.read<ExploreCubit>();
    Navigator.of(context).pop();
    await cubit.applyFilters(filters);
  }

  static String _number(double? value) => value == null ? '' : value.toString();
  static double? _parse(String value) =>
      value.trim().isEmpty ? null : double.tryParse(value.trim());
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

class _FilterNumberField extends StatelessWidget {
  const _FilterNumberField({
    required this.label,
    required this.controller,
    required this.min,
    this.validator,
  });
  final String label;
  final TextEditingController controller;
  final double min;
  final FormFieldValidator<String>? validator;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final String input = value?.trim() ?? '';
        if (input.isNotEmpty) {
          final double? number = double.tryParse(input);
          if (number == null || number < min) {
            return AppLocalizations.of(context).invalidFilterValue;
          }
        }
        return validator?.call(value);
      },
    ),
  );
}

class _FilterDropdown<T> extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });
  final String label;
  final T value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: items
          .map(
            (item) => DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
    ),
  );
}

String _centerSortLabel(AppLocalizations l10n, String value) => switch (value) {
  'nearest' => l10n.sortNearest,
  'name' => l10n.sortName,
  'latest' => l10n.sortLatest,
  'price_asc' => l10n.sortPriceAsc,
  'price_desc' => l10n.sortPriceDesc,
  _ => l10n.sortRating,
};

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
