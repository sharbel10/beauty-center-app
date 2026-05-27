import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/core/widgets/app_bottom_navigation.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_details_response.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_details_header.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_details_tabs.dart';
import 'package:beauty_center_app/features/clinic/widgets/details/clinic_gallery_view.dart';
import 'package:beauty_center_app/features/clinic/widgets/details/clinic_info_view.dart';
import 'package:beauty_center_app/features/clinic/widgets/details/clinic_overview_view.dart';
import 'package:beauty_center_app/features/clinic/widgets/details/clinic_services_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  @override
  void initState() {
    super.initState();
    widget._cubit.loadClinicDetails(widget.centerId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClinicDetailsCubit>.value(
      value: widget._cubit,
      child: BlocConsumer<ClinicDetailsCubit, ClinicDetailsState>(
        listenWhen: (previous, current) =>
            previous.message != current.message &&
            current.message != null &&
            current.status == ClinicDetailsStatus.failure,
        listener: (context, state) {
          context.showSnackbar(state.message!, isError: true);
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.surface,
            bottomNavigationBar: const AppBottomNavigation(
              currentItem: AppNavItem.explore,
            ),
            body: SafeArea(
              child: () {
                if (state.isLoading && !state.hasData) {
                  return const Center(child: CircularProgressIndicator());
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
                            state.message ?? 'Failed to load clinic details.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => widget._cubit.loadClinicDetails(
                              widget.centerId,
                            ),
                            child: const Text('Retry'),
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
                  ],
                );
              }(),
            ),
          );
        },
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
