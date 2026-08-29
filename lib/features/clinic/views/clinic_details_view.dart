import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/core/widgets/app_bottom_navigation.dart';
import 'package:beauty_center_app/core/widgets/app_button.dart';
import 'package:beauty_center_app/features/book_treatment/models/book_treatment_args.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_details_response.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_details_header.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_details_skeleton.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_details_tabs.dart';
import 'package:beauty_center_app/features/clinic/widgets/details/clinic_gallery_view.dart';
import 'package:beauty_center_app/features/clinic/widgets/details/clinic_info_view.dart';
import 'package:beauty_center_app/features/clinic/widgets/details/clinic_overview_view.dart';
import 'package:beauty_center_app/features/clinic/widgets/details/clinic_services_view.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/clinic_details_cubit.dart';
import '../cubit/clinic_details_state.dart';

class ClinicDetailsView extends StatefulWidget {
  const ClinicDetailsView({
    required this.centerId,
    required ClinicDetailsCubit cubit,
    super.key,
  }) : _cubit = cubit;

  final int centerId;
  final ClinicDetailsCubit _cubit;

  @override
  State<ClinicDetailsView> createState() => _ClinicDetailsViewState();
}

class _ClinicDetailsViewState extends State<ClinicDetailsView> {
  int _selectedTab = 0;

  // Captured once: the route builder re-runs on navigator rebuilds and
  // creates a fresh cubit from getIt, which would otherwise replace the
  // loaded one with an empty instance.
  late final ClinicDetailsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget._cubit;
    _cubit.loadClinicDetails(widget.centerId);
  }

  @override
  void didUpdateWidget(ClinicDetailsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget._cubit, _cubit)) {
      widget._cubit.close();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return BlocProvider<ClinicDetailsCubit>.value(
      value: _cubit,
      child: BlocConsumer<ClinicDetailsCubit, ClinicDetailsState>(
        listenWhen: (previous, current) =>
            previous.message != current.message &&
            current.message != null &&
            current.status == ClinicDetailsStatus.failure,
        listener: (context, state) {
          context.showSnackbar(state.message!, isError: true);
        },
        builder: (context, state) {
          final bool showBookButton = state.hasData;
          final int? centerId = state.center?.id;

          return Scaffold(
            backgroundColor: AppColors.surface,
            bottomNavigationBar: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (state.isLoading && !state.hasData)
                  const ClinicDetailsBookBarSkeleton(),
                if (showBookButton && centerId != null)
                  _StickyBookAppointmentBar(centerId: centerId),
                AppBottomNavigation(
                  currentItem: AppNavItem.explore,
                  onItemSelected: (AppNavItem item) {
                    _navigateFromDetails(context, item);
                  },
                ),
              ],
            ),
            body: SafeArea(
              child: () {
                if (state.isLoading && !state.hasData) {
                  return const ClinicDetailsSkeleton();
                }

                if (state.status == ClinicDetailsStatus.failure &&
                    !state.hasData) {
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
                                _cubit.loadClinicDetails(widget.centerId),
                            child: Text(l10n.retry),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (!state.hasData) return const SizedBox.shrink();

                final clinic = state.center!;

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: ClinicDetailsTopBar()),
                    SliverToBoxAdapter(
                      child: ClinicDetailsHero(clinic: clinic),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: ClinicDetailsTabs(
                        selectedIndex: _selectedTab,
                        onChanged: (index) {
                          setState(() => _selectedTab = index);
                        },
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 30, 24, 30),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 220),
                          child: _ClinicDetailsTabBody(
                            key: ValueKey(_selectedTab),
                            selectedTab: _selectedTab,
                            clinic: clinic,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                );
              }(),
            ),
          );
        },
      ),
    );
  }

  void _navigateFromDetails(BuildContext context, AppNavItem item) {
    final GoRouter router = GoRouter.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final String routeName = switch (item) {
      AppNavItem.home => RouteNames.home,
      AppNavItem.explore => RouteNames.explore,
      AppNavItem.aiScan => RouteNames.aiRecommendation,
      AppNavItem.bookings => RouteNames.bookings,
      AppNavItem.profile => RouteNames.profile,
    };

    // Details are opened with Navigator.push, outside GoRouter's page stack.
    // Remove that imperative route first so the selected destination is not
    // left hidden behind the details page.
    navigator.pop();
    router.goNamed(routeName);
  }
}

class _StickyBookAppointmentBar extends StatelessWidget {
  const _StickyBookAppointmentBar({required this.centerId});

  final int centerId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Material(
      color: AppColors.surface,
      elevation: 8,
      shadowColor: const Color(0x220A2A55),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: AppButton(
          text: l10n.clinicBookAppointment,
          onPressed: () {
            context.pushNamed(
              RouteNames.bookTreatment,
              extra: BookTreatmentArgs(centerId: centerId),
            );
          },
          height: 58,
        ),
      ),
    );
  }
}

class _ClinicDetailsTabBody extends StatelessWidget {
  const _ClinicDetailsTabBody({
    required this.selectedTab,
    required this.clinic,
    super.key,
  });

  final int selectedTab;
  final ClinicCenterDetail clinic;

  @override
  Widget build(BuildContext context) {
    return switch (selectedTab) {
      1 => ClinicServicesView(clinic: clinic),
      2 => ClinicGalleryView(clinic: clinic),
      3 => ClinicInfoView(clinic: clinic),
      _ => ClinicOverviewView(clinic: clinic),
    };
  }
}
