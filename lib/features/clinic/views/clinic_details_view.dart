import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/core/widgets/app_bottom_navigation.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_details_cubit.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_details_state.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_employees_cubit.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_offers_cubit.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_portfolio_cubit.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_services_cubit.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_details_response.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_details_header.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_details_tabs.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_sticky_book_bar.dart';
import 'package:beauty_center_app/features/clinic/widgets/details/clinic_gallery_view.dart';
import 'package:beauty_center_app/features/clinic/widgets/details/clinic_info_view.dart';
import 'package:beauty_center_app/features/clinic/widgets/details/clinic_overview_view.dart';
import 'package:beauty_center_app/features/clinic/widgets/details/clinic_services_view.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ClinicDetailsView extends StatefulWidget {
  const ClinicDetailsView({
    required this.centerId,
    required ClinicDetailsCubit cubit,
    this.entryNavItem = AppNavItem.explore,
    super.key,
  }) : _cubit = cubit;

  final int centerId;
  final ClinicDetailsCubit _cubit;
  final AppNavItem entryNavItem;

  @override
  State<ClinicDetailsView> createState() => _ClinicDetailsViewState();
}

class _ClinicDetailsViewState extends State<ClinicDetailsView> {
  @override
  void initState() {
    super.initState();
    widget._cubit.loadClinicDetails(widget.centerId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClinicDetailsCubit>.value(
      value: widget._cubit,
      child: BlocListener<ClinicDetailsCubit, ClinicDetailsState>(
        listenWhen: (previous, current) =>
            previous.message != current.message &&
            current.message != null &&
            current.status == ClinicDetailsStatus.failure,
        listener: (context, state) {
          context.showSnackbar(state.message!, isError: true);
        },
        child: BlocBuilder<ClinicDetailsCubit, ClinicDetailsState>(
          buildWhen: (previous, current) =>
              previous.status != current.status ||
              previous.center != current.center ||
              previous.hasData != current.hasData,
          builder: (context, state) {
            return Scaffold(
              backgroundColor: AppColors.surface,
              extendBody: true,
              bottomNavigationBar: AppBottomNavigation(
                currentItem: widget.entryNavItem,
                onItemSelected: (AppNavItem item) =>
                    _onBottomNavSelected(context, item),
              ),
              body: SafeArea(child: _buildBody(context, state)),
            );
          },
        ),
      ),
    );
  }

  void _onBottomNavSelected(BuildContext context, AppNavItem item) {
    if (item == widget.entryNavItem) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pop();
    switch (item) {
      case AppNavItem.home:
        context.goNamed(RouteNames.home);
      case AppNavItem.explore:
        context.goNamed(RouteNames.explore);
      case AppNavItem.bookings:
      case AppNavItem.profile:
      case AppNavItem.aiScan:
        break;
    }
  }

  Widget _buildBody(BuildContext context, ClinicDetailsState state) {
    if (state.isLoading && !state.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == ClinicDetailsStatus.failure && !state.hasData) {
      final AppLocalizations l10n = AppLocalizations.of(context);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                state.message ?? l10n.clinicDetailsLoadFailed,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    widget._cubit.loadClinicDetails(widget.centerId),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (!state.hasData) return const SizedBox.shrink();

    return _ClinicDetailsLoadedBody(
      key: ValueKey<int>(state.center!.id),
      clinic: state.center!,
      centerId: widget.centerId,
    );
  }
}

class _ClinicDetailsLoadedBody extends StatefulWidget {
  const _ClinicDetailsLoadedBody({
    required this.clinic,
    required this.centerId,
    super.key,
  });

  final ClinicCenterDetail clinic;
  final int centerId;

  @override
  State<_ClinicDetailsLoadedBody> createState() => _ClinicDetailsLoadedBodyState();
}

class _ClinicDetailsLoadedBodyState extends State<_ClinicDetailsLoadedBody> {
  int _selectedTab = 0;

  late final ClinicOffersCubit _offersCubit;
  late final ClinicEmployeesCubit _employeesCubit;
  late final ClinicServicesCubit _servicesCubit;
  late final ClinicPortfolioCubit _portfolioCubit;

  @override
  void initState() {
    super.initState();
    _offersCubit = getIt<ClinicOffersCubit>();
    _employeesCubit = getIt<ClinicEmployeesCubit>();
    _servicesCubit = getIt<ClinicServicesCubit>();
    _portfolioCubit = getIt<ClinicPortfolioCubit>();
    _fetchDataForTab(_selectedTab);
  }

  /// Loads tab-specific data on first visit only (`fetchIfNeeded` on each cubit).
  void _fetchDataForTab(int tabIndex) {
    final int centerId = widget.centerId;
    switch (tabIndex) {
      case 0:
        _offersCubit.fetchClinicOffersIfNeeded(centerId);
        _employeesCubit.fetchClinicEmployeesIfNeeded(centerId);
      case 1:
        _servicesCubit.fetchClinicServicesIfNeeded(centerId);
      case 2:
        _portfolioCubit.fetchClinicPortfolioIfNeeded(centerId);
        _servicesCubit.fetchClinicServicesIfNeeded(centerId);
      case 3:
        break;
    }
  }

  void _onTabChanged(int index) {
    if (_selectedTab != index) {
      setState(() => _selectedTab = index);
    }
    _fetchDataForTab(index);
  }

  /// Only the visible tab is built so scroll height matches content (IndexedStack
  /// would always use the tallest tab's height).
  Widget _buildActiveTab() {
    return switch (_selectedTab) {
      1 => ClinicServicesView(clinic: widget.clinic),
      2 => ClinicGalleryView(clinic: widget.clinic),
      3 => ClinicInfoView(clinic: widget.clinic),
      _ => ClinicOverviewView(clinic: widget.clinic),
    };
  }

  @override
  void dispose() {
    _offersCubit.close();
    _employeesCubit.close();
    _servicesCubit.close();
    _portfolioCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider<ClinicOffersCubit>.value(value: _offersCubit),
        BlocProvider<ClinicEmployeesCubit>.value(value: _employeesCubit),
        BlocProvider<ClinicServicesCubit>.value(value: _servicesCubit),
        BlocProvider<ClinicPortfolioCubit>.value(value: _portfolioCubit),
      ],
      child: Column(
        children: <Widget>[
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                const SliverToBoxAdapter(child: ClinicDetailsTopBar()),
                SliverToBoxAdapter(
                  child: ClinicDetailsHero(clinic: widget.clinic),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: ClinicDetailsTabs(
                    selectedIndex: _selectedTab,
                    onChanged: _onTabChanged,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
                    child: _buildActiveTab(),
                  ),
                ),
              ],
            ),
          ),
          ClinicStickyBookBar(
            label: l10n.clinicBookAppointment,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
