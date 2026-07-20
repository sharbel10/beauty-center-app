import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/features/book_treatment/components/book_treatment_header.dart';
import 'package:beauty_center_app/features/book_treatment/components/booking_progress_indicator.dart';
import 'package:beauty_center_app/features/book_treatment/components/booking_summary_bar.dart';
import 'package:beauty_center_app/features/book_treatment/components/date_step.dart';
import 'package:beauty_center_app/features/book_treatment/components/service_step.dart';
import 'package:beauty_center_app/features/book_treatment/components/time_step.dart';
import 'package:beauty_center_app/features/book_treatment/cubit/book_treatment_cubit.dart';
import 'package:beauty_center_app/features/book_treatment/cubit/book_treatment_state.dart';
import 'package:beauty_center_app/features/book_treatment/models/available_slots_response.dart';
import 'package:beauty_center_app/features/book_treatment/models/book_treatment_args.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_employees_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_services_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BookTreatmentView extends StatefulWidget {
  const BookTreatmentView({
    required this.args,
    required BookTreatmentCubit cubit,
    super.key,
  }) : _cubit = cubit;

  final BookTreatmentArgs args;
  final BookTreatmentCubit _cubit;

  @override
  State<BookTreatmentView> createState() => _BookTreatmentViewState();
}

class _BookTreatmentViewState extends State<BookTreatmentView> {
  // Captured once: the router's builder re-runs on every push/pop and
  // creates a fresh cubit from getIt; we keep the initialized one and
  // discard orphans.
  late final BookTreatmentCubit _cubit;

  @override
  void initState() {
    super.initState();
    _cubit = widget._cubit;
    _cubit.initialize(widget.args);
  }

  @override
  void didUpdateWidget(BookTreatmentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget._cubit, _cubit)) {
      widget._cubit.close();
    }
  }

  @override
  void dispose() {
    // The cubit is created per-navigation by the router (injectable
    // factory), so this view owns its lifecycle.
    _cubit.close();
    super.dispose();
  }

  void _handleBack(BuildContext context) {
    final BookTreatmentCubit cubit = context.read<BookTreatmentCubit>();
    if (cubit.state.currentStep > BookingSteps.service) {
      cubit.previousStep();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.goNamed(RouteNames.explore);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookTreatmentCubit>.value(
      value: _cubit,
      child: BlocListener<BookTreatmentCubit, BookTreatmentState>(
        listenWhen: (BookTreatmentState previous, BookTreatmentState current) =>
            previous.status != current.status,
        listener: (BuildContext context, BookTreatmentState state) {
          if (state.status == BookTreatmentStatus.failure &&
              state.message != null) {
            context.showSnackbar(state.message!, isError: true);
          }
          if (state.status == BookTreatmentStatus.success) {
            context.showSnackbar(
              state.message ?? 'Appointment booked successfully.',
            );
            context.goNamed(RouteNames.bookings);
          }
        },
        child: Builder(
          builder: (BuildContext context) {
            return Scaffold(
              backgroundColor: AppColors.background,
              bottomNavigationBar: const _BottomBar(),
              body: SafeArea(
                child: Column(
                  children: <Widget>[
                    BookTreatmentHeader(
                      onBackPressed: () => _handleBack(context),
                    ),
                    const Expanded(child: _Body()),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Handles the initial load / fatal error phases, then hands over to the
/// stepper. Rebuilds only when the init phase actually changes.
class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BookTreatmentCubit, BookTreatmentState,
        (BookTreatmentStatus, bool, String?)>(
      selector: (BookTreatmentState state) =>
          (state.status, state.hasData, state.message),
      builder: (BuildContext context, (BookTreatmentStatus, bool, String?) phase) {
        final (BookTreatmentStatus status, bool hasData, String? message) =
            phase;

        if (!hasData &&
            (status == BookTreatmentStatus.initial ||
                status == BookTreatmentStatus.loading)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!hasData) {
          return _EmptyServicesState(message: message);
        }

        return const _Stepper();
      },
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BookTreatmentCubit, BookTreatmentState, int>(
      selector: (BookTreatmentState state) => state.currentStep,
      builder: (BuildContext context, int currentStep) {
        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: BookingProgressIndicator(
                currentStep: currentStep,
                onStepTapped: context.read<BookTreatmentCubit>().goToStep,
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: switch (currentStep) {
                  BookingSteps.service => const _ServiceStepSection(
                    key: ValueKey<int>(BookingSteps.service),
                  ),
                  BookingSteps.date => const _DateStepSection(
                    key: ValueKey<int>(BookingSteps.date),
                  ),
                  _ => const _TimeStepSection(
                    key: ValueKey<int>(BookingSteps.time),
                  ),
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ServiceStepSection extends StatelessWidget {
  const _ServiceStepSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      BookTreatmentCubit,
      BookTreatmentState,
      (List<ClinicServiceItem>, int?, List<ClinicEmployeeItem>, int?)
    >(
      selector: (BookTreatmentState state) => (
        state.services,
        state.selectedServiceId,
        state.employees,
        state.selectedEmployeeId,
      ),
      builder: (BuildContext context, data) {
        final (
          List<ClinicServiceItem> services,
          int? selectedServiceId,
          List<ClinicEmployeeItem> employees,
          int? selectedEmployeeId,
        ) = data;
        final BookTreatmentCubit cubit = context.read<BookTreatmentCubit>();

        return ServiceStep(
          services: services,
          selectedServiceId: selectedServiceId,
          onServiceSelected: cubit.selectService,
          employees: employees,
          selectedEmployeeId: selectedEmployeeId,
          onEmployeeSelected: cubit.selectEmployee,
        );
      },
    );
  }
}

class _DateStepSection extends StatelessWidget {
  const _DateStepSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BookTreatmentCubit, BookTreatmentState, DateTime?>(
      selector: (BookTreatmentState state) => state.selectedDate,
      builder: (BuildContext context, DateTime? selectedDate) {
        return DateStep(
          selectedDate: selectedDate,
          onDateSelected: context.read<BookTreatmentCubit>().selectDate,
        );
      },
    );
  }
}

class _TimeStepSection extends StatelessWidget {
  const _TimeStepSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      BookTreatmentCubit,
      BookTreatmentState,
      (List<AvailableSlot>, SlotsStatus, String?, String?, int?)
    >(
      selector: (BookTreatmentState state) => (
        state.slots,
        state.slotsStatus,
        state.slotsMessage,
        state.selectedSlotStartsAt,
        state.selectedEmployeeId,
      ),
      builder: (BuildContext context, data) {
        final (
          List<AvailableSlot> slots,
          SlotsStatus slotsStatus,
          String? slotsMessage,
          String? selectedStartsAt,
          int? selectedEmployeeId,
        ) = data;
        final BookTreatmentCubit cubit = context.read<BookTreatmentCubit>();
        final BookTreatmentState state = cubit.state;

        return TimeStep(
          slots: slots,
          slotsStatus: slotsStatus,
          slotsMessage: slotsMessage,
          selectedStartsAt: selectedStartsAt,
          dateLabel: state.selectedDateLabel,
          serviceName: state.selectedService?.name ?? '—',
          specialistName: state.selectedEmployee?.name ?? 'Any specialist',
          hasSpecificSpecialist: selectedEmployeeId != null,
          totalLabel: state.totalLabel,
          onSlotSelected: cubit.selectSlot,
          onRetry: cubit.loadSlots,
          onChangeDate: () => cubit.goToStep(BookingSteps.date),
          onTryAnySpecialist: () => cubit.selectEmployee(null),
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<
      BookTreatmentCubit,
      BookTreatmentState,
      (int, bool, bool, bool, String, String)
    >(
      selector: (BookTreatmentState state) => (
        state.currentStep,
        state.isLastStep ? state.canConfirm : state.canContinue,
        state.isSubmitting,
        state.hasData,
        state.totalLabel,
        state.selectedTimeLabel,
      ),
      builder: (BuildContext context, data) {
        final (
          int currentStep,
          bool isEnabled,
          bool isSubmitting,
          bool hasData,
          String total,
          String time,
        ) = data;

        if (!hasData) {
          return const SizedBox.shrink();
        }

        final BookTreatmentCubit cubit = context.read<BookTreatmentCubit>();
        final bool isLastStep = currentStep == BookingSteps.time;

        return BookingSummaryBar(
          isLastStep: isLastStep,
          isEnabled: isEnabled,
          isLoading: isSubmitting,
          total: total,
          time: time,
          confirmText: cubit.state.args?.isRescheduling ?? false
              ? 'Confirm Reschedule'
              : 'Confirm Booking',
          onPressed: isLastStep ? cubit.confirmBooking : cubit.nextStep,
        );
      },
    );
  }
}

class _EmptyServicesState extends StatelessWidget {
  const _EmptyServicesState({required this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              message ?? 'No services available for this clinic.',
              textAlign: TextAlign.center,
              style: AppTextStyles.subtitle.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final BookTreatmentCubit cubit = context
                    .read<BookTreatmentCubit>();
                final BookTreatmentArgs? args = cubit.state.args;
                if (args != null) {
                  cubit.initialize(args);
                }
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
