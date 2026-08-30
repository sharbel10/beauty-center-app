import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/core/utils/map_launcher.dart';
import 'package:beauty_center_app/core/widgets/app_bottom_navigation.dart';
import 'package:beauty_center_app/features/book_treatment/models/book_treatment_args.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_details_cubit.dart';
import 'package:beauty_center_app/features/clinic/views/clinic_details_view.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_service_card.dart';
import 'package:beauty_center_app/features/favorites/cubit/favorites_cubit.dart';
import 'package:beauty_center_app/features/favorites/cubit/favorites_state.dart';
import 'package:beauty_center_app/features/favorites/models/favorites_response.dart';
import 'package:beauty_center_app/features/favorites/widgets/favorite_heart_button.dart';
import 'package:beauty_center_app/features/home/widgets/clinic_network_image.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class FavoritesView extends StatefulWidget {
  const FavoritesView({required FavoritesCubit cubit, super.key})
    : _cubit = cubit;

  final FavoritesCubit _cubit;

  @override
  State<FavoritesView> createState() => _FavoritesViewState();
}

class _FavoritesViewState extends State<FavoritesView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final FavoritesCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget._cubit;
    _tabController = TabController(length: 2, vsync: this);
    _cubit.loadFavorites();
  }

  @override
  void didUpdateWidget(FavoritesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget._cubit, _cubit)) {
      widget._cubit.close();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FavoritesCubit>.value(
      value: _cubit,
      child: BlocConsumer<FavoritesCubit, FavoritesState>(
        listenWhen: (FavoritesState previous, FavoritesState current) {
          return previous.message != current.message && current.message != null;
        },
        listener: (BuildContext context, FavoritesState state) {
          if (state.message != null) {
            context.showSnackbar(state.message!, isError: state.isMessageError);
            _cubit.clearMessage();
          }
        },
        builder: (BuildContext context, FavoritesState state) {
          final AppLocalizations l10n = AppLocalizations.of(context);

          return Scaffold(
            backgroundColor: AppColors.scaffold,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () => _cubit.loadFavorites(),
                color: AppColors.primary,
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                      floating: true,
                      pinned: true,
                      snap: false,
                      toolbarHeight: 80,
                      backgroundColor: AppColors.scaffold,
                      surfaceTintColor: Colors.transparent,
                      leading: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                        color: AppColors.primary,
                      ),
                      title: Text(
                        l10n.favorites,
                        style: AppTextStyles.headline.copyWith(fontSize: 24),
                      ),
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(48),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceMuted,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  dividerColor: Colors.transparent,
                                  indicatorSize: TabBarIndicatorSize.tab,
                                  indicator: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  indicatorPadding: const EdgeInsets.all(4),
                                  labelColor: AppColors.surface,
                                  unselectedLabelColor: AppColors.textSecondary,
                                  labelStyle: AppTextStyles.subtitle.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                  unselectedLabelStyle: AppTextStyles.subtitle
                                      .copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                  tabs: <Widget>[
                                    Tab(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          const Icon(
                                            Icons.storefront_rounded,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(l10n.centers),
                                        ],
                                      ),
                                    ),
                                    Tab(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          const Icon(
                                            Icons.spa_rounded,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(l10n.services),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (state.isLoading)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height:
                              MediaQuery.sizeOf(context).height -
                              kToolbarHeight -
                              120,
                          child: TabBarView(
                            controller: _tabController,
                            children: <Widget>[
                              if (state.centers.isEmpty)
                                _EmptyState(
                                  icon: Icons.favorite_border_rounded,
                                  title: l10n.noFavoriteCenters,
                                  subtitle: l10n.noFavoriteCentersSubtitle,
                                  iconData: Icons.storefront_rounded,
                                )
                              else
                                _CentersList(
                                  centers: state.centers,
                                  cubit: _cubit,
                                ),
                              if (state.services.isEmpty)
                                _EmptyState(
                                  icon: Icons.favorite_border_rounded,
                                  title: l10n.noFavoriteServices,
                                  subtitle: l10n.noFavoriteServicesSubtitle,
                                  iconData: Icons.spa_rounded,
                                )
                              else
                                _ServicesList(
                                  services: state.services,
                                  cubit: _cubit,
                                ),
                            ],
                          ),
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

class _TabBadge extends StatelessWidget {
  const _TabBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: count == 0
            ? AppColors.textSecondary.withValues(alpha: 0.15)
            : AppColors.gold.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        count.toString(),
        style: AppTextStyles.smallCaps.copyWith(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: count == 0 ? AppColors.textSecondary : const Color(0xFF4D3800),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconData,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.06),
                  ),
                ),
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.10),
                  ),
                  child: Center(child: Icon(iconData)),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.title.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _CentersList extends StatelessWidget {
  const _CentersList({required this.centers, required this.cubit});

  final List<FavoriteCenter> centers;
  final FavoritesCubit cubit;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
      itemCount: centers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (BuildContext context, int index) {
        final FavoriteCenter center = centers[index];
        return _FavoriteCenterCard(center: center, cubit: cubit);
      },
    );
  }
}

class _ServicesList extends StatelessWidget {
  const _ServicesList({required this.services, required this.cubit});

  final List<FavoriteService> services;
  final FavoritesCubit cubit;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
      itemCount: services.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (BuildContext context, int index) {
        final FavoriteService service = services[index];
        final String? badgeText = service.hasDiscount
            ? l10n.clinicServiceBadgeOffer
            : (service.isFeatured ? l10n.clinicServiceBadgeFeatured : null);
        final bool isDarkBadge = !service.hasDiscount && service.isFeatured;

        return ClinicServiceCard(
          title: service.name,
          description: service.description?.trim() ?? '',
          durationMinutes: service.durationMinutes,
          preparationMinutes: service.preparationMinutes,
          originalPrice: service.price.toDouble(),
          finalPrice: service.finalPrice.toDouble(),
          badge: badgeText,
          darkBadge: isDarkBadge,
          isFavorite: service.isFavorite,
          centerName: service.center?.name,
          onFavoriteToggle: (bool isCurrentlyFavorite) {
            return cubit.toggleServiceFavorite(
              serviceId: service.id,
              isCurrentlyFavorite: isCurrentlyFavorite,
            );
          },
          onTap: () {
            if (service.center?.id != null) {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ClinicDetailsView(
                    centerId: service.centerId,
                    cubit: getIt<ClinicDetailsCubit>(),
                  ),
                ),
              );
            }
          },
        );
      },
    );
  }
}

class _FavoriteCenterCard extends StatefulWidget {
  const _FavoriteCenterCard({required this.center, required this.cubit});

  final FavoriteCenter center;
  final FavoritesCubit cubit;

  @override
  State<_FavoriteCenterCard> createState() => _FavoriteCenterCardState();
}

class _FavoriteCenterCardState extends State<_FavoriteCenterCard> {
  static const double cardHeight = 188;
  static const double imageWidth = 108;

  FavoriteCenter get center => widget.center;

  String? get _shortDescription {
    final String? text = center.description?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  Future<void> _openInOpenStreetMap(double latitude, double longitude) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    try {
      final bool launched = await MapLauncher.openOpenStreetMap(
        latitude: latitude,
        longitude: longitude,
      );

      if (!launched && mounted) {
        context.showSnackbar(l10n.couldNotOpenMapsForLocation, isError: true);
      }
    } catch (_) {
      if (mounted) {
        context.showSnackbar(l10n.couldNotOpenMapsForLocation, isError: true);
      }
    }
  }

  Future<void> _onNavigationPressed() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (!center.hasCoordinates) {
      context.showSnackbar(l10n.locationUnavailableForClinic, isError: true);
      return;
    }

    await _openInOpenStreetMap(center.latitude!, center.longitude!);
  }

  void _onCardTap() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ClinicDetailsView(
          centerId: center.id,
          cubit: getIt<ClinicDetailsCubit>(),
        ),
      ),
    );
  }

  void _onBookPressed() {
    context.pushNamed(
      RouteNames.bookTreatment,
      extra: BookTreatmentArgs(centerId: center.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? description = _shortDescription;
    final String? region = center.cityAreaLabel;

    return InkWell(
      onTap: _onCardTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Color(0x080A2A55),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: imageWidth,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ClinicNetworkImage(imageUrl: center.displayCoverUrl),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: FavoriteHeartButton(
                      isFavorite: center.isFavorite,
                      size: 16,
                      padding: const EdgeInsets.all(7),
                      onToggle: (bool isCurrentlyFavorite) {
                        return widget.cubit.toggleCenterFavorite(
                          centerId: center.id,
                          isCurrentlyFavorite: isCurrentlyFavorite,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: _RatingBadge(rating: center.averageRating),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      center.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.title.copyWith(
                        fontSize: 16,
                        height: 1.2,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (description != null) ...<Widget>[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 11,
                          height: 1.3,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      l10n.reviewsCount(center.ratingsCount),
                      style: AppTextStyles.smallCaps.copyWith(
                        fontSize: 9,
                        color: AppColors.textMuted,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (region != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          region,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.subtitle.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    Row(
                      children: <Widget>[
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            center.locationLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ),
                        _NavigationButton(
                          enabled: center.hasCoordinates,
                          onPressed: _onNavigationPressed,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          center.distanceKm != null
                              ? '${center.distanceKm!.toStringAsFixed(1)} km'
                              : '—',
                          style: AppTextStyles.link.copyWith(
                            fontSize: 11,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: 36,
                        width: 92,
                        child: ElevatedButton(
                          onPressed: _onBookPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            l10n.book,
                            style: AppTextStyles.button.copyWith(
                              fontSize: 12,
                              color: AppColors.surface,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.star_rounded, color: AppColors.gold, size: 14),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: AppTextStyles.link.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(
            Icons.navigation_rounded,
            size: 16,
            color: enabled
                ? AppColors.primary
                : AppColors.textMuted.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }
}
