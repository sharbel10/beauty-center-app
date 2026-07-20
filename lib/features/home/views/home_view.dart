import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/core/widgets/app_bottom_navigation.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_cubit.dart';
import 'package:beauty_center_app/features/auth/cubit/auth_state.dart';
import 'package:beauty_center_app/features/book_treatment/models/book_treatment_args.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_details_cubit.dart';
import 'package:beauty_center_app/features/clinic/views/clinic_details_view.dart';
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

class _HomeViewState extends State<HomeView> {
  int? _selectedCategoryId;

  // Captured once: the router's builder re-runs on every push/pop and
  // creates a fresh HomeCubit from getIt, which would otherwise replace
  // the loaded one with an empty instance.
  late final HomeCubit _homeCubit;

  @override
  void initState() {
    super.initState();
    _homeCubit = widget._homeCubit;
    _homeCubit.loadHome();
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
    _homeCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<AuthCubit>.value(value: widget._authCubit),
        BlocProvider<HomeCubit>.value(value: _homeCubit),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (AuthState previous, AuthState current) =>
            previous.isAuthenticated != current.isAuthenticated &&
            !current.isAuthenticated,
        listener: (BuildContext context, AuthState state) {
          context.goNamed(RouteNames.login);
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
            return Scaffold(
              backgroundColor: AppColors.scaffold,
              extendBody: true,
              bottomNavigationBar: const AppBottomNavigation(
                currentItem: AppNavItem.home,
              ),
              body: SafeArea(bottom: false, child: _buildBody(context, state)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeState state) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (state.isLoading && !state.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!state.hasData) {
      return _HomeErrorBody(
        message: state.message ?? l10n.unableToLoadHomeData,
        onRetry: _homeCubit.loadHome,
      );
    }

    final HomeData data = state.data!;
    final List<HomeClinicUiModel> clinics = data.previewFeaturedCenters
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
      onRefresh: _homeCubit.loadHome,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            sliver: SliverList.list(
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
                const HomeSearchBar(),
                const SizedBox(height: 28),
                _SectionHeader(title: l10n.nearbyClinics),
                const SizedBox(height: 14),
                HomeCategoryChips(
                  categories: data.topLevelCategories,
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: (int? categoryId) {
                    setState(() => _selectedCategoryId = categoryId);
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
