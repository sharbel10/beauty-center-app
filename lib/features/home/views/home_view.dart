import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/services/device_registration_service.dart';
import 'package:beauty_center_app/core/services/firebase_messaging_service.dart';
import 'package:beauty_center_app/core/services/location_service.dart';
import 'package:beauty_center_app/features/notifications/cubit/notifications_cubit.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/core/widgets/app_bottom_navigation.dart';
import 'package:beauty_center_app/core/widgets/center_card_skeleton.dart';
import 'package:beauty_center_app/core/widgets/root_exit_guard.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_cubit.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_state.dart';
import 'package:beauty_center_app/features/book_treatment/models/book_treatment_args.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_details_cubit.dart';
import 'package:beauty_center_app/features/clinic/views/clinic_details_view.dart';
import 'package:beauty_center_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:beauty_center_app/features/favorites/cubit/favorites_state.dart';
import 'package:beauty_center_app/features/home/cubit/home_cubit.dart';
import 'package:beauty_center_app/features/home/cubit/home_state.dart';
import 'package:beauty_center_app/features/home/models/home_clinic_ui.dart';
import 'package:beauty_center_app/features/home/models/home_data.dart';
import 'package:beauty_center_app/features/home/models/offer.dart';
import 'package:beauty_center_app/features/home/models/promotion_ui.dart';
import 'package:beauty_center_app/features/home/widgets/home_category_chips.dart';
import 'package:beauty_center_app/features/home/widgets/home_header.dart';
import 'package:beauty_center_app/features/home/widgets/home_search_bar.dart';
import 'package:beauty_center_app/features/home/widgets/nearby_clinic_card.dart';
import 'package:beauty_center_app/features/home/widgets/promotion_card.dart';
import 'package:beauty_center_app/features/home/widgets/search_results_view.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatefulWidget {
  const HomeView({
    required AuthCubit authCubit,
    required HomeCubit homeCubit,
    super.key,
  }) : _authCubit = authCubit,
       _homeCubit = homeCubit;

  final AuthCubit _authCubit;
  final HomeCubit _homeCubit;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  static const double _nearbyRadiusKm = 25;

  int? _selectedCategoryId;
  UserLocation? _userLocation;
  bool _didTryResolveLocation = false;

  // Captured once: the router's builder re-runs on every push/pop and
  // creates a fresh Cubit from getIt, which would otherwise replace
  // the loaded one with an empty instance.
  late final HomeCubit _homeCubit;
  late final FavoritesCubit _favoritesCubit;
  late final LocationService _locationService;

  @override
  void initState() {
    super.initState();
    _homeCubit = widget._homeCubit;
    _locationService = getIt<LocationService>();
    WidgetsBinding.instance.addObserver(this);
    _initializeHome();
    _favoritesCubit = getIt<FavoritesCubit>();
    _favoritesCubit.loadFavorites();
    _bootstrapNotifications();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      getIt<NotificationsCubit>().loadCounts();
    }
  }

  void _bootstrapNotifications() {
    final DeviceRegistrationService devices =
        getIt<DeviceRegistrationService>();
    devices.attachTokenRefreshListener();
    // ignore: unawaited_futures
    devices.syncDeviceToken();
    // ignore: unawaited_futures
    getIt<NotificationsCubit>().loadCounts();
    getIt<FirebaseMessagingService>().consumePendingNavigation();
  }

  @override
  void didUpdateWidget(HomeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget._homeCubit, _homeCubit)) {
      widget._homeCubit.close();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _homeCubit.close();
    _favoritesCubit.close();
    super.dispose();
  }

  Future<void> _initializeHome() async {
    // Location improves nearby ordering, but it must never block the rest of
    // Home from loading when permission is denied or GPS is unavailable.
    await _loadHomeForCurrentFilters();

    if (!mounted || _homeCubit.isClosed || _didTryResolveLocation) {
      return;
    }

    _didTryResolveLocation = true;
    final LocationResult locationResult = await _locationService
        .getCurrentLocation();

    if (!mounted || _homeCubit.isClosed || !locationResult.isSuccess) {
      return;
    }

    _userLocation = locationResult.location;
    await _loadHomeForCurrentFilters();
  }

  Future<void> _loadHomeForCurrentFilters() async {
    if (!mounted || _homeCubit.isClosed) {
      return;
    }

    await _homeCubit.loadHome(
      latitude: _userLocation?.latitude,
      longitude: _userLocation?.longitude,
      radiusKm: _userLocation == null ? null : _nearbyRadiusKm,
      categoryId: _selectedCategoryId,
    );
  }

  void _navigateToExploreWithCategory(BuildContext context, int categoryId) {
    context.go(
      Uri(
        path: RouteNames.explorePath,
        queryParameters: <String, String>{'category_id': categoryId.toString()},
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthCubit>.value(value: widget._authCubit),
        BlocProvider<HomeCubit>.value(value: _homeCubit),
        BlocProvider<FavoritesCubit>.value(value: _favoritesCubit),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (AuthState previous, AuthState current) =>
            previous.isAuthenticated != current.isAuthenticated &&
            !current.isAuthenticated,
        listener: (BuildContext context, AuthState state) {
          context.goNamed(RouteNames.login);
        },
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
          child: BlocConsumer<HomeCubit, HomeState>(
            listenWhen: (HomeState previous, HomeState current) =>
                previous.message != current.message &&
                current.message != null &&
                current.status == HomeStatus.failure,
            listener: (BuildContext context, HomeState state) {
              context.showSnackbar(state.message!, isError: true);
            },
            builder: (BuildContext context, HomeState state) {
              return RootExitGuard(
                isHomeRoute: true,
                child: Scaffold(
                  backgroundColor: AppColors.scaffold,
                  extendBody: true,
                  bottomNavigationBar: const AppBottomNavigation(
                    currentItem: AppNavItem.home,
                  ),
                  body: SafeArea(
                    bottom: false,
                    child: _buildBody(context, state),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            children: <Widget>[
              BlocBuilder<AuthCubit, AuthState>(
                buildWhen: (AuthState previous, AuthState current) =>
                    previous.customer?.name != current.customer?.name ||
                    previous.isAuthenticated != current.isAuthenticated,
                builder: (BuildContext context, AuthState authState) {
                  return HomeHeader(
                    userName: widget._authCubit.userDisplayName(
                      guestLabel: l10n.guest,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              HomeSearchBar(initialQuery: state.searchQuery),
            ],
          ),
        ),
        Expanded(
          child: state.isSearching
              ? _SearchContent(
                  state: state,
                  onRetry: () {
                    _homeCubit.performSearch(state.searchQuery);
                  },
                  onCategoryTap: (int categoryId) {
                    _navigateToExploreWithCategory(context, categoryId);
                  },
                )
              : _buildHomeContent(context, state, l10n),
        ),
      ],
    );
  }

  Widget _buildHomeContent(
    BuildContext context,
    HomeState state,
    AppLocalizations l10n,
  ) {
    if (state.isLoading && !state.hasData) {
      return _HomeCentersSkeleton(title: l10n.nearbyClinics);
    }

    if (!state.hasData) {
      return _HomeErrorBody(
        message: state.message ?? l10n.unableToLoadHomeData,
        onRetry: () {
          _loadHomeForCurrentFilters();
        },
      );
    }

    final HomeData data = state.data!;
    final List<HomeClinicUiModel> clinics = data.previewNearbyCenters
        .map(HomeClinicUiModel.fromCenter)
        .toList();
    final List<PromotionUiModel> promotions = data.previewOffers
        .asMap()
        .entries
        .map(
          (MapEntry<int, Offer> entry) => PromotionUiModel.fromOffer(
            entry.value,
            isDark: entry.key.isEven,
            badge: entry.key == 0 ? l10n.exclusive : l10n.hotDeal,
            cta: l10n.claimOffer,
            price: PromotionUiModel.formatPrice(entry.value, l10n),
          ),
        )
        .toList();

    return RefreshIndicator(
      onRefresh: _loadHomeForCurrentFilters,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            sliver: SliverList.list(
              children: <Widget>[
                _SectionHeader(title: l10n.nearbyClinics),
                const SizedBox(height: 14),
                HomeCategoryChips(
                  categories: data.topLevelCategories,
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: (int? categoryId) {
                    setState(() => _selectedCategoryId = categoryId);
                    _loadHomeForCurrentFilters();
                  },
                ),
                const SizedBox(height: 16),
                for (final HomeClinicUiModel clinic in clinics) ...<Widget>[
                  NearbyClinicCard(
                    clinic: clinic,
                    onBookPressed: () {
                      context.pushNamed(
                        RouteNames.bookTreatment,
                        extra: BookTreatmentArgs(centerId: clinic.id),
                      );
                    },
                    onCardTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ClinicDetailsView(
                            centerId: clinic.id,
                            cubit: getIt<ClinicDetailsCubit>(),
                          ),
                        ),
                      );
                    },
                    onFavoriteToggle: (bool isCurrentlyFavorite) async {
                      await context.read<FavoritesCubit>().toggleCenterFavorite(
                        centerId: clinic.id,
                        isCurrentlyFavorite: isCurrentlyFavorite,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
                const _DiscoverMoreButton(),
                const SizedBox(height: 32),
                _SectionHeader(title: l10n.specialPromotions),
                const SizedBox(height: 14),
                _PromotionsCarousel(promotions: promotions),
                SizedBox(
                  height: 96 + AppBottomNavigation.contentOverlap(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCentersSkeleton extends StatelessWidget {
  const _HomeCentersSkeleton({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            24 + AppBottomNavigation.contentOverlap(context),
          ),
          sliver: SliverList.list(
            children: <Widget>[
              _SectionHeader(title: title),
              const SizedBox(height: 14),
              for (int index = 0; index < 3; index++) ...<Widget>[
                const CenterCardSkeleton.compact(),
                if (index < 2) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SearchContent extends StatelessWidget {
  const _SearchContent({
    required this.state,
    required this.onRetry,
    required this.onCategoryTap,
  });

  final HomeState state;
  final VoidCallback onRetry;
  final ValueChanged<int> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    if (state.isSearchLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.searchStatus == SearchStatus.failure) {
      return _SearchErrorState(message: state.message, onRetry: onRetry);
    }

    if (state.hasSearchResults) {
      return SearchResultsView(
        searchData: state.searchData!,
        onBookPressed: (int centerId) {
          context.pushNamed(
            RouteNames.bookTreatment,
            extra: BookTreatmentArgs(centerId: centerId),
          );
        },
        onCardTap: (int centerId) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => ClinicDetailsView(
                centerId: centerId,
                cubit: getIt<ClinicDetailsCubit>(),
              ),
            ),
          );
        },
        onServiceTap: (int centerId, int serviceId) {
          context.pushNamed(
            RouteNames.bookTreatment,
            extra: BookTreatmentArgs(
              centerId: centerId,
              initialServiceId: serviceId,
            ),
          );
        },
        onFavoriteToggle: (int centerId, bool isCurrentlyFavorite) async {
          final HomeCubit homeCubit = context.read<HomeCubit>();
          try {
            await context.read<FavoritesCubit>().toggleCenterFavorite(
              centerId: centerId,
              isCurrentlyFavorite: isCurrentlyFavorite,
            );
            homeCubit.setSearchCenterFavorite(
              centerId: centerId,
              isFavorite: !isCurrentlyFavorite,
            );
          } catch (_) {
            homeCubit.setSearchCenterFavorite(
              centerId: centerId,
              isFavorite: isCurrentlyFavorite,
            );
            rethrow;
          }
        },
        onServiceFavoriteToggle:
            (int serviceId, bool isCurrentlyFavorite) async {
              final HomeCubit homeCubit = context.read<HomeCubit>();
              try {
                await context.read<FavoritesCubit>().toggleServiceFavorite(
                  serviceId: serviceId,
                  isCurrentlyFavorite: isCurrentlyFavorite,
                );
                homeCubit.setSearchServiceFavorite(
                  serviceId: serviceId,
                  isFavorite: !isCurrentlyFavorite,
                );
              } catch (_) {
                homeCubit.setSearchServiceFavorite(
                  serviceId: serviceId,
                  isFavorite: isCurrentlyFavorite,
                );
                rethrow;
              }
            },
        onCategoryTap: onCategoryTap,
      );
    }

    return _EmptySearchState(query: state.searchQuery);
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.title.copyWith(fontSize: 22));
  }
}

class _DiscoverMoreButton extends StatelessWidget {
  const _DiscoverMoreButton();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SizedBox(
      height: 52,
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => context.goNamed(RouteNames.explore),
        iconAlignment: IconAlignment.end,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: Text(
          l10n.discoverMoreClinics,
          style: AppTextStyles.link.copyWith(fontSize: 13),
        ),
        style: TextButton.styleFrom(
          backgroundColor: AppColors.surfaceMuted,
          foregroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      ),
    );
  }
}

class _PromotionsCarousel extends StatefulWidget {
  const _PromotionsCarousel({required this.promotions});

  final List<PromotionUiModel> promotions;

  @override
  State<_PromotionsCarousel> createState() => _PromotionsCarouselState();
}

class _PromotionsCarouselState extends State<_PromotionsCarousel> {
  static const double _cardHeight = 220;

  final PageController _controller = PageController(viewportFraction: 0.82);
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.promotions.isEmpty) {
      return const _PromotionsEmptyPlaceholder();
    }

    return Column(
      children: <Widget>[
        SizedBox(
          height: _cardHeight,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.promotions.length,
            padEnds: false,
            onPageChanged: (int index) => setState(() => _index = index),
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: PromotionCard(
                  promotion: widget.promotions[index],
                  height: _cardHeight,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(widget.promotions.length, (
            int index,
          ) {
            final bool isActive = index == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: isActive ? 30 : 8,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : AppColors.divider,
                borderRadius: BorderRadius.circular(8),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _PromotionsEmptyPlaceholder extends StatelessWidget {
  const _PromotionsEmptyPlaceholder();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.7)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noSpecialPromotionsTitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.title.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noSpecialPromotionsSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle.copyWith(
              fontSize: 13,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeErrorBody extends StatelessWidget {
  const _HomeErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

class _SearchWaitingState extends StatelessWidget {
  const _SearchWaitingState();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.manage_search_rounded,
                color: AppColors.textMuted,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.searchClinicsOrTreatments,
              style: AppTextStyles.title.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchErrorState extends StatelessWidget {
  const _SearchErrorState({required this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.textMuted,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? l10n.unableToLoadHomeData,
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.textMuted,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.noResultsFound,
              style: AppTextStyles.title.copyWith(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.noResultsFor} "$query"',
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
