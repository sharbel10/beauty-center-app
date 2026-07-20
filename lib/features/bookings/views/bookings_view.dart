import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/core/widgets/app_bottom_navigation.dart';
import 'package:beauty_center_app/features/book_treatment/models/book_treatment_args.dart';
import 'package:beauty_center_app/features/bookings/components/appointment_card.dart';
import 'package:beauty_center_app/features/bookings/components/booking_tabs.dart';
import 'package:beauty_center_app/features/bookings/components/bookings_header.dart';
import 'package:beauty_center_app/features/bookings/cubit/bookings_cubit.dart';
import 'package:beauty_center_app/features/bookings/cubit/bookings_state.dart';
import 'package:beauty_center_app/features/bookings/models/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BookingsView extends StatefulWidget {
  const BookingsView({required BookingsCubit cubit, super.key})
    : _cubit = cubit;

  final BookingsCubit _cubit;

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> {
  int _selectedTab = 0;

  // Captured once: the router's builder re-runs on every push/pop and
  // creates a fresh BookingsCubit from getIt, which would otherwise
  // replace the loaded one with an empty instance.
  late final BookingsCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget._cubit;
    _cubit.loadAppointments();
  }

  @override
  void didUpdateWidget(BookingsView oldWidget) {
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
    return BlocProvider<BookingsCubit>.value(
      value: _cubit,
      child: BlocConsumer<BookingsCubit, BookingsState>(
        listenWhen: (BookingsState previous, BookingsState current) =>
            previous.message != current.message && current.message != null,
        listener: (BuildContext context, BookingsState state) {
          if (state.status == BookingsStatus.failure) {
            context.showSnackbar(state.message!, isError: true);
          } else {
            context.showSnackbar(state.message!);
          }
        },
        builder: (BuildContext context, BookingsState state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            bottomNavigationBar: AppBottomNavigation(
              currentItem: AppNavItem.bookings,
              onItemSelected: (AppNavItem item) => _handleNav(context, item),
            ),
            body: SafeArea(
              child: Column(
                children: <Widget>[
                  const BookingsHeader(),
                  BookingTabs(
                    selectedIndex: _selectedTab,
                    onChanged: (int index) =>
                        setState(() => _selectedTab = index),
                  ),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: _selectedTab == 0
                          ? _AppointmentsList(
                              key: const ValueKey<String>('upcoming'),
                              label: 'NEXT 30 DAYS',
                              appointments: state.upcoming,
                              isLoading: state.isLoading && !state.hasData,
                              emptyMessage: 'No upcoming appointments.',
                              onRefresh: _cubit.loadAppointments,
                              onViewDetails: _showAppointmentDetails,
                              onMorePressed: _showAppointmentActions,
                              onRebookPressed: _openBooking,
                            )
                          : _AppointmentsList(
                              key: const ValueKey<String>('past'),
                              label: 'HISTORY',
                              appointments: state.history,
                              isPast: true,
                              isLoading: state.isLoading && !state.hasData,
                              emptyMessage: 'No past appointments.',
                              onRefresh: _cubit.loadAppointments,
                              onViewDetails: _showAppointmentDetails,
                              onMorePressed: _showAppointmentActions,
                              onRebookPressed: _openBooking,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleNav(BuildContext context, AppNavItem item) {
    if (item == AppNavItem.home) {
      context.goNamed(RouteNames.home);
    } else if (item == AppNavItem.explore) {
      context.goNamed(RouteNames.explore);
    } else if (item == AppNavItem.bookings) {
      context.goNamed(RouteNames.bookings);
    }
  }

  void _showAppointmentDetails(AppointmentModel appointment) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _AppointmentDetailsSheet(appointment: appointment);
      },
    );
  }

  void _showAppointmentActions(AppointmentModel appointment) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return _AppointmentActionsSheet(
          appointment: appointment,
          onCancel: appointment.canCancel
              ? () async {
                  Navigator.of(sheetContext).pop();
                  final bool confirmed = await _confirmCancel(
                    context,
                    appointment,
                  );
                  if (confirmed && mounted) {
                    await _cubit.cancelAppointment(appointment.id);
                  }
                }
              : null,
          onReschedule: appointment.canReschedule
              ? () {
                  Navigator.of(sheetContext).pop();
                  _openBooking(appointment);
                }
              : null,
        );
      },
    );
  }

  Future<bool> _confirmCancel(
    BuildContext context,
    AppointmentModel appointment,
  ) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Cancel appointment?'),
              content: Text(
                '${appointment.serviceName}\n${appointment.date} at ${appointment.time}',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Keep'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Cancel Appointment'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _openBooking(AppointmentModel appointment) {
    final int? centerId = appointment.centerId;
    if (centerId == null) {
      context.showSnackbar(
        'Clinic is missing for this appointment.',
        isError: true,
      );
      return;
    }

    context.pushNamed(
      RouteNames.bookTreatment,
      extra: BookTreatmentArgs(
        centerId: centerId,
        initialServiceId: appointment.serviceId,
        appointmentId: appointment.canReschedule ? appointment.id : null,
      ),
    );
  }
}

class _AppointmentsList extends StatelessWidget {
  const _AppointmentsList({
    required this.label,
    required this.appointments,
    required this.isLoading,
    required this.emptyMessage,
    required this.onRefresh,
    required this.onViewDetails,
    required this.onMorePressed,
    required this.onRebookPressed,
    this.isPast = false,
    super.key,
  });

  final String label;
  final List<AppointmentModel> appointments;
  final bool isPast;
  final bool isLoading;
  final String emptyMessage;
  final Future<void> Function() onRefresh;
  final ValueChanged<AppointmentModel> onViewDetails;
  final ValueChanged<AppointmentModel> onMorePressed;
  final ValueChanged<AppointmentModel> onRebookPressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              16 + AppBottomNavigation.contentOverlap(context),
            ),
            sliver: SliverList.list(
              children: <Widget>[
                _SectionLabel(label),
                const SizedBox(height: 12),
                if (appointments.isEmpty)
                  _EmptyAppointments(message: emptyMessage)
                else
                  for (final AppointmentModel appointment
                      in appointments) ...<Widget>[
                    AppointmentCard(
                      appointment: appointment,
                      isPast: isPast || appointment.isPast,
                      onViewDetails: () => onViewDetails(appointment),
                      onMorePressed: () => onMorePressed(appointment),
                      onRebookPressed: () => onRebookPressed(appointment),
                    ),
                    const SizedBox(height: 12),
                  ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.smallCaps.copyWith(
        color: AppColors.textSecondary,
        fontSize: 11,
      ),
    );
  }
}

class _EmptyAppointments extends StatelessWidget {
  const _EmptyAppointments({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.calendar_month_outlined,
            color: AppColors.textMuted,
            size: 28,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _AppointmentDetailsSheet extends StatelessWidget {
  const _AppointmentDetailsSheet({required this.appointment});

  final AppointmentModel appointment;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            appointment.serviceName,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            appointment.clinicName,
            style: AppTextStyles.subtitle.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.calendar_month_rounded,
            text: appointment.date,
          ),
          const SizedBox(height: 10),
          _DetailRow(icon: Icons.schedule_rounded, text: appointment.time),
          if (appointment.employeeName?.isNotEmpty == true) ...<Widget>[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.person_rounded,
              text: appointment.employeeName!,
            ),
          ],
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.payments_rounded,
            text: appointment.totalLabel,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _AppointmentActionsSheet extends StatelessWidget {
  const _AppointmentActionsSheet({
    required this.appointment,
    this.onCancel,
    this.onReschedule,
  });

  final AppointmentModel appointment;
  final VoidCallback? onCancel;
  final VoidCallback? onReschedule;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        12,
        8,
        12,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            dense: true,
            leading: const Icon(Icons.event_repeat_rounded, size: 22),
            title: Text(
              'Reschedule',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            enabled: onReschedule != null,
            onTap: onReschedule,
          ),
          ListTile(
            dense: true,
            leading: const Icon(Icons.cancel_outlined, size: 22),
            title: Text(
              'Cancel Appointment',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            enabled: onCancel != null,
            onTap: onCancel,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
