import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/features/favorites/widgets/favorite_heart_button.dart';
import 'package:beauty_center_app/features/home/models/category.dart';
import 'package:beauty_center_app/features/home/models/home_clinic_ui.dart';
import 'package:beauty_center_app/features/home/models/search_response.dart';
import 'package:beauty_center_app/features/home/widgets/nearby_clinic_card.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

class SearchResultsView extends StatelessWidget {
  const SearchResultsView({
    required this.searchData,
    required this.onBookPressed,
    required this.onCardTap,
    required this.onServiceTap,
    required this.onFavoriteToggle,
    required this.onServiceFavoriteToggle,
    required this.onCategoryTap,
    super.key,
  });

  final SearchData searchData;
  final ValueChanged<int> onBookPressed;
  final ValueChanged<int> onCardTap;
  final void Function(int centerId, int serviceId) onServiceTap;
  final Future<void> Function(int centerId, bool isCurrentlyFavorite)
  onFavoriteToggle;
  final Future<void> Function(int serviceId, bool isCurrentlyFavorite)
  onServiceFavoriteToggle;
  final ValueChanged<int> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    if (!searchData.hasResults) {
      return _EmptySearchResults(query: searchData.query);
    }

    return CustomScrollView(
      slivers: <Widget>[
        if (searchData.centers.isNotEmpty) ...<Widget>[
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: l10n.centers,
              count: searchData.centers.length,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                final CenterSearchResult center = searchData.centers[index];
                final HomeClinicUiModel clinic =
                    HomeClinicUiModel.fromSearchCenter(center);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NearbyClinicCard(
                    clinic: clinic,
                    onBookPressed: () => onBookPressed(center.id),
                    onCardTap: () => onCardTap(center.id),
                    onFavoriteToggle: (bool isFavorite) =>
                        onFavoriteToggle(center.id, isFavorite),
                  ),
                );
              }, childCount: searchData.centers.length),
            ),
          ),
        ],
        if (searchData.services.isNotEmpty) ...<Widget>[
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: l10n.services,
              count: searchData.services.length,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                final ServiceSearchResult service = searchData.services[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SearchServiceCard(
                    service: service,
                    onTap: () => onServiceTap(service.centerId, service.id),
                    onFavoriteToggle: (bool isFavorite) =>
                        onServiceFavoriteToggle(service.id, isFavorite),
                  ),
                );
              }, childCount: searchData.services.length),
            ),
          ),
        ],
        if (searchData.categories.isNotEmpty) ...<Widget>[
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: l10n.categories,
              count: searchData.categories.length,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                final category = searchData.categories[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SearchCategoryCard(
                    category: category,
                    onTap: () => onCategoryTap(category.id),
                  ),
                );
              }, childCount: searchData.categories.length),
            ),
          ),
        ],
        if (searchData.offers.isNotEmpty) ...<Widget>[
          SliverToBoxAdapter(
            child: _SectionHeader(
              title: l10n.offers,
              count: searchData.offers.length,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                final offer = searchData.offers[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SearchOfferCard(offer: offer),
                );
              }, childCount: searchData.offers.length),
            ),
          ),
        ],
        SliverToBoxAdapter(child: SizedBox(height: 96 + 24)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 14),
      child: Row(
        children: <Widget>[
          Text(title, style: AppTextStyles.title.copyWith(fontSize: 18)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchServiceCard extends StatelessWidget {
  const _SearchServiceCard({
    required this.service,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final ServiceSearchResult service;
  final VoidCallback onTap;
  final Future<void> Function(bool isCurrentlyFavorite) onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String imageUrl = service.imageUrl?.trim() ?? '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 104,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: <Widget>[
            SizedBox(width: 82, child: _ServiceImage(imageUrl: imageUrl)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            service.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.title.copyWith(fontSize: 14),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FavoriteHeartButton(
                          isFavorite: service.isFavorite,
                          size: 17,
                          padding: const EdgeInsets.all(5),
                          backgroundColor: AppColors.surfaceMuted,
                          onToggle: onFavoriteToggle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      service.center?.name ?? service.category?.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        if (service.hasDiscount) ...<Widget>[
                          Text(
                            l10n.priceSp(service.finalPrice.toStringAsFixed(0)),
                            style: AppTextStyles.link.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.priceSp(service.price.toStringAsFixed(0)),
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 12,
                              color: AppColors.textMuted,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ] else
                          Text(
                            l10n.priceSp(service.finalPrice.toStringAsFixed(0)),
                            style: AppTextStyles.link.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        const Spacer(),
                        Text(
                          '${service.durationMinutes} min',
                          style: AppTextStyles.subtitle.copyWith(
                            fontSize: 11,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
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

class _ServiceImage extends StatelessWidget {
  const _ServiceImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return Container(
        color: AppColors.surfaceMuted,
        child: const Icon(
          Icons.spa_rounded,
          size: 28,
          color: AppColors.textMuted,
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder:
          (BuildContext context, Object error, StackTrace? stackTrace) {
            return Container(
              height: 188,
              color: AppColors.surfaceMuted,
              child: const Icon(
                Icons.spa_rounded,
                size: 40,
                color: AppColors.textMuted,
              ),
            );
          },
    );
  }
}

class _SearchCategoryCard extends StatelessWidget {
  const _SearchCategoryCard({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String iconUrl = category.iconUrl?.trim() ?? '';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            _CategoryIcon(iconUrl: iconUrl),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title.copyWith(fontSize: 14),
                  ),
                  if (category.description != null &&
                      category.description!.isNotEmpty)
                    Text(
                      category.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.subtitle.copyWith(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  const _CategoryIcon({required this.iconUrl});

  final String iconUrl;

  @override
  Widget build(BuildContext context) {
    if (iconUrl.isEmpty) {
      return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          Icons.category_rounded,
          size: 24,
          color: AppColors.primary,
        ),
      );
    }

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          iconUrl,
          fit: BoxFit.cover,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) {
                return const Icon(
                  Icons.category_rounded,
                  size: 24,
                  color: AppColors.primary,
                );
              },
        ),
      ),
    );
  }
}

class _SearchOfferCard extends StatelessWidget {
  const _SearchOfferCard({required this.offer});

  final OfferSearchResult offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              offer.discountLabel,
              style: AppTextStyles.button.copyWith(
                fontSize: 11,
                color: AppColors.surface,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  offer.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title.copyWith(fontSize: 14),
                ),
                if (offer.center != null)
                  Text(
                    offer.center!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.subtitle.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.local_offer_rounded,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _EmptySearchResults extends StatelessWidget {
  const _EmptySearchResults({required this.query});

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
