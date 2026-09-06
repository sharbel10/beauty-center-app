import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/core/widgets/app_bottom_navigation.dart';
import 'package:beauty_center_app/core/widgets/root_exit_guard.dart';
import 'package:beauty_center_app/features/book_treatment/models/book_treatment_args.dart';
import 'package:beauty_center_app/features/bookings/components/appointment_card.dart';
import 'package:beauty_center_app/features/bookings/components/appointments_skeleton.dart';
import 'package:beauty_center_app/features/bookings/components/booking_tabs.dart';
import 'package:beauty_center_app/features/bookings/components/bookings_header.dart';
import 'package:beauty_center_app/features/bookings/cubit/bookings_cubit.dart';
import 'package:beauty_center_app/features/bookings/cubit/bookings_state.dart';
import 'package:beauty_center_app/features/bookings/models/appointment_model.dart';
import 'package:beauty_center_app/features/clinic/widgets/clinic_network_image.dart';
import 'package:beauty_center_app/features/reviews/cubit/report_cubit.dart';
import 'package:beauty_center_app/features/reviews/cubit/reviews_cubit.dart';
import 'package:beauty_center_app/features/reviews/widgets/report_submit_sheet.dart';
import 'package:beauty_center_app/features/reviews/widgets/review_submit_sheet.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BookingsView extends StatefulWidget {
  const BookingsView({
    required BookingsCubit cubit,
    required ReviewsCubit reviewsCubit,
    required ReportCubit reportCubit,
    super.key,
  }) : _cubit = cubit,
       _reviewsCubit = reviewsCubit,
       _reportCubit = reportCubit;

  final BookingsCubit _cubit;
  final ReviewsCubit _reviewsCubit;
  final ReportCubit _reportCubit;

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView> {
  int _selectedTab = 0;

  late final BookingsCubit _cubit;
  late final ReviewsCubit _reviewsCubit;
  late final ReportCubit _reportCubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget._cubit;
    _reviewsCubit = widget._reviewsCubit;
    _reportCubit = widget._reportCubit;
    _cubit.loadAppointments();
  }

  @override
  void didUpdateWidget(BookingsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget._cubit, _cubit)) {
      widget._cubit.close();
    }
    if (!identical(widget._reviewsCubit, _reviewsCubit)) {
      widget._reviewsCubit.close();
    }
    if (!identical(widget._reportCubit, _reportCubit)) {
      widget._reportCubit.close();
    }
  }

  @override
  void dispose() {
    _cubit.close();
    _reviewsCubit.close();
    _reportCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<BookingsCubit>.value(value: _cubit),
        BlocProvider<ReviewsCubit>.value(value: _reviewsCubit),
        BlocProvider<ReportCubit>.value(value: _reportCubit),
      ],
      child: MultiBlocListener(
        listeners: <BlocListener<dynamic, dynamic>>[
          BlocListener<BookingsCubit, BookingsState>(
            listenWhen: (BookingsState previous, BookingsState current) =>
                previous.message != current.message && current.message != null,
            listener: (BuildContext context, BookingsState state) {
              if (state.status == BookingsStatus.failure) {
                context.showSnackbar(state.message!, isError: true);
              } else {
                context.showSnackbar(state.message!);
              }
            },
          ),
        ],
        child: BlocBuilder<BookingsCubit, BookingsState>(
          builder: (BuildContext context, BookingsState state) {
            final AppLocalizations l10n = AppLocalizations.of(context);

            return RootExitGuard(
              child: Scaffold(
                backgroundColor: AppColors.background,
                bottomNavigationBar: AppBottomNavigation(
                  currentItem: AppNavItem.bookings,
                  onItemSelected: (AppNavItem item) =>
                      _handleNav(context, item),
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
                                  label: l10n.next30Days,
                                  appointments: state.upcoming,
                                  isLoading: state.isLoading && !state.hasData,
                                  emptyMessage: l10n.noUpcomingAppointments,
                                  onRefresh: _cubit.loadAppointments,
                                  onViewDetails: _showAppointmentDetails,
                                  onMorePressed: _showAppointmentActions,
                                  onRebookPressed: _openRebooking,
                                  onPayPressed: _openPendingPayment,
                                  onRatePressed: _openReviewSheet,
                                  onReportPressed: _openReportSheet,
                                )
                              : _AppointmentsList(
                                  key: const ValueKey<String>('past'),
                                  label: l10n.history,
                                  appointments: state.history,
                                  isPast: true,
                                  isLoading: state.isLoading && !state.hasData,
                                  emptyMessage: l10n.noPastAppointments,
                                  onRefresh: _cubit.loadAppointments,
                                  onViewDetails: _showAppointmentDetails,
                                  onMorePressed: _showAppointmentActions,
                                  onRebookPressed: _openRebooking,
                                  onPayPressed: _openPendingPayment,
                                  onRatePressed: _openReviewSheet,
                                  onReportPressed: _openReportSheet,
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
      ),
    );
  }

  void _showAppointmentDetails(AppointmentModel appointment) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final bool isCompleted =
            appointment.status == AppointmentStatus.completed;
        return _AppointmentDetailsSheet(
          appointment: appointment,
          onPay: appointment.canRetryPayment
              ? () {
                  Navigator.of(context).pop();
                  _openPendingPayment(appointment);
                }
              : null,
          onRebook: appointment.isPast || appointment.startsAtIsPast
              ? () {
                  Navigator.of(context).pop();
                  _openRebooking(appointment);
                }
              : null,
          onRate: isCompleted
              ? () {
                  Navigator.of(context).pop();
                  _openReviewSheet(appointment);
                }
              : null,
          onReport: isCompleted
              ? () {
                  Navigator.of(context).pop();
                  _openReportSheet(appointment);
                }
              : null,
        );
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
                  _openRescheduling(appointment);
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
    final AppLocalizations l10n = AppLocalizations.of(context);

    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(l10n.cancelAppointment),
              content: Text(
                '${l10n.cancelAppointmentConfirm}\n\n'
                '${appointment.serviceName}\n'
                '${appointment.date} · ${appointment.time}',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(l10n.keep),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(l10n.cancelAppointmentAction),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Future<void> _openRebooking(AppointmentModel appointment) async {
    await _openBooking(appointment, isRescheduling: false);
  }

  Future<void> _openRescheduling(AppointmentModel appointment) async {
    await _openBooking(appointment, isRescheduling: true);
  }

  void _openReviewSheet(AppointmentModel appointment) {
    if (appointment.status != AppointmentStatus.completed) {
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return BlocProvider<ReviewsCubit>.value(
          value: _reviewsCubit,
          child: ReviewSubmitSheet(appointment: appointment),
        );
      },
    );
  }

  void _openReportSheet(AppointmentModel appointment) {
    if (appointment.status != AppointmentStatus.completed) {
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return BlocProvider<ReportCubit>.value(
          value: _reportCubit,
          child: ReportSubmitSheet(appointment: appointment),
        );
      },
    );
  }

  void _openPendingPayment(AppointmentModel appointment) {
    final int? centerId = appointment.centerId;
    if (centerId == null || !appointment.canRetryPayment) {
      context.showSnackbar(
        AppLocalizations.of(context).paymentNoLongerAvailable,
        isError: true,
      );
      return;
    }

    context.pushNamed(
      RouteNames.bookTreatment,
      extra: BookTreatmentArgs(
        centerId: centerId,
        paymentAppointmentId: appointment.id,
      ),
    );
  }

  Future<void> _openBooking(
    AppointmentModel appointment, {
    required bool isRescheduling,
  }) async {
    final int? centerId = appointment.centerId;
    if (centerId == null) {
      context.showSnackbar(
        AppLocalizations.of(context).clinicMissingForAppointment,
        isError: true,
      );
      return;
    }

    final bool? shouldRefresh = await context.pushNamed<bool>(
      RouteNames.bookTreatment,
      extra: BookTreatmentArgs(
        centerId: centerId,
        initialServiceId: appointment.serviceId,
        appointmentId: isRescheduling ? appointment.id : null,
      ),
    );

    if (shouldRefresh == true && mounted) {
      await _cubit.loadAppointments();
    }
  }

  void _handleNav(BuildContext context, AppNavItem item) {
    switch (item) {
      case AppNavItem.home:
        context.goNamed(RouteNames.home);
        break;
      case AppNavItem.bookings:
        // Already on bookings page
        break;
      case AppNavItem.explore:
        context.goNamed(RouteNames.explore);
        break;
      case AppNavItem.profile:
        context.goNamed(RouteNames.profile);
        break;
      case AppNavItem.aiScan:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
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
    required this.onPayPressed,
    required this.onRatePressed,
    required this.onReportPressed,
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
  final ValueChanged<AppointmentModel> onPayPressed;
  final ValueChanged<AppointmentModel> onRatePressed;
  final ValueChanged<AppointmentModel> onReportPressed;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return AppointmentsSkeleton(isPast: isPast);
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
                      onPayPressed: () => onPayPressed(appointment),
                      onRatePressed:
                          appointment.status == AppointmentStatus.completed
                          ? () => onRatePressed(appointment)
                          : null,
                      onReportPressed:
                          appointment.status == AppointmentStatus.completed
                          ? () => onReportPressed(appointment)
                          : null,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTextStyles.subtitle.copyWith(fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _AppointmentDetailsSheet extends StatelessWidget {
  const _AppointmentDetailsSheet({
    required this.appointment,
    this.onRebook,
    this.onPay,
    this.onRate,
    this.onReport,
  });

  final AppointmentModel appointment;
  final VoidCallback? onRebook;
  final VoidCallback? onPay;
  final VoidCallback? onRate;
  final VoidCallback? onReport;

  bool get _isCompleted => appointment.status == AppointmentStatus.completed;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final double bottomInset = MediaQuery.paddingOf(context).bottom;
    final String? notes = appointment.customerNotes?.trim();
    final String? cancelReason = appointment.cancellationReason?.trim();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 16 + bottomInset),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          l10n.appointmentDetails,
                          style: AppTextStyles.title.copyWith(fontSize: 20),
                        ),
                      ),
                      AppointmentStatusBadge(status: appointment.status),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.scaffold,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: SizedBox(
                            width: 78,
                            height: 78,
                            child: ClinicNetworkImage(
                              imageUrl: appointment.imageUrl,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                appointment.serviceName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                appointment.clinicName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.subtitle.copyWith(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _DetailsGrid(
                    items: <_DetailTileData>[
                      _DetailTileData(
                        icon: Icons.calendar_month_rounded,
                        label: l10n.dateLabel,
                        value: appointment.date,
                      ),
                      _DetailTileData(
                        icon: Icons.schedule_rounded,
                        label: l10n.timeLabel,
                        value: appointment.time,
                      ),
                      if (appointment.employeeName?.isNotEmpty == true)
                        _DetailTileData(
                          icon: Icons.person_rounded,
                          label: l10n.specialistLabel,
                          value: appointment.employeeName!,
                        ),
                      _DetailTileData(
                        icon: Icons.payments_rounded,
                        label: l10n.estimatedTotal,
                        value: appointment.totalLabel,
                      ),
                      if (appointment.depositRequired > 0)
                        _DetailTileData(
                          icon: Icons.account_balance_wallet_outlined,
                          label: l10n.depositLabel,
                          value:
                              '\$${_formatPrice(appointment.depositRequired)}',
                        ),
                    ],
                  ),
                  if (notes != null && notes.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 16),
                    _InfoBlock(
                      title: l10n.notesLabel,
                      body: notes,
                      icon: Icons.notes_rounded,
                    ),
                  ],
                  if (cancelReason != null &&
                      cancelReason.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 12),
                    _InfoBlock(
                      title: l10n.cancellationReasonLabel,
                      body: cancelReason,
                      icon: Icons.info_outline_rounded,
                      tone: AppColors.danger,
                    ),
                  ],
                  if (_isCompleted &&
                      (onRate != null || onReport != null)) ...<Widget>[
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        if (onRate != null) ...<Widget>[
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: onRate,
                                icon: const Icon(
                                  Icons.star_rounded,
                                  size: 17,
                                  color: Color(0xFFFFB400),
                                ),
                                label: Text(
                                  l10n.rate,
                                  style: AppTextStyles.button.copyWith(
                                    fontSize: 13,
                                    color: const Color(0xFFFFB400),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0x26FFB400),
                                  ),
                                  backgroundColor: const Color(
                                    0xFFFFB400,
                                  ).withValues(alpha: 0.06),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        if (onReport != null)
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton.icon(
                                onPressed: onReport,
                                icon: const Icon(
                                  Icons.flag_rounded,
                                  size: 17,
                                  color: AppColors.danger,
                                ),
                                label: Text(
                                  l10n.report,
                                  style: AppTextStyles.button.copyWith(
                                    fontSize: 13,
                                    color: AppColors.danger,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: AppColors.danger.withValues(
                                      alpha: 0.22,
                                    ),
                                  ),
                                  backgroundColor: AppColors.danger.withValues(
                                    alpha: 0.06,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (onRebook != null) ...<Widget>[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: onRebook,
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          l10n.rebook,
                          style: AppTextStyles.button.copyWith(fontSize: 14),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (onPay != null) ...<Widget>[
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: onPay,
                        icon: const Icon(Icons.payment_rounded, size: 18),
                        label: Text(
                          l10n.completePayment,
                          style: AppTextStyles.button.copyWith(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final String value = price.toStringAsFixed(0);
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return value.replaceAllMapped(reg, (Match match) => '${match[1]},');
  }
}

class _DetailTileData {
  const _DetailTileData({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _DetailsGrid extends StatelessWidget {
  const _DetailsGrid({required this.items});

  final List<_DetailTileData> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: items
          .map(
            (_DetailTileData item) => SizedBox(
              width: (MediaQuery.sizeOf(context).width - 50) / 2,
              child: _DetailTile(data: item),
            ),
          )
          .toList(),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({required this.data});

  final _DetailTileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.scaffold,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            data.label.toUpperCase(),
            style: AppTextStyles.smallCaps.copyWith(
              fontSize: 9,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.subtitle.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({
    required this.title,
    required this.body,
    required this.icon,
    this.tone = AppColors.primary,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tone.withValues(alpha: 0.14)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: tone),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppTextStyles.smallCaps.copyWith(
                    fontSize: 10,
                    color: tone,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
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
    final AppLocalizations l10n = AppLocalizations.of(context);

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
              l10n.reschedule,
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
              l10n.cancelAppointmentAction,
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
