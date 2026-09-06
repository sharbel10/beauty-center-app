import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/features/book_treatment/components/book_treatment_header.dart';
import 'package:beauty_center_app/features/book_treatment/components/book_treatment_skeleton.dart';
import 'package:beauty_center_app/features/book_treatment/components/booking_progress_indicator.dart';
import 'package:beauty_center_app/features/book_treatment/components/booking_summary_bar.dart';
import 'package:beauty_center_app/features/book_treatment/components/date_step.dart';
import 'package:beauty_center_app/features/book_treatment/components/payment_step.dart';
import 'package:beauty_center_app/features/book_treatment/components/service_step.dart';
import 'package:beauty_center_app/features/book_treatment/components/time_step.dart';
import 'package:beauty_center_app/features/book_treatment/cubit/book_treatment_cubit.dart';
import 'package:beauty_center_app/features/book_treatment/cubit/book_treatment_state.dart';
import 'package:beauty_center_app/features/book_treatment/models/available_slots_response.dart';
import 'package:beauty_center_app/features/book_treatment/models/book_treatment_args.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_employees_response.dart';
import 'package:beauty_center_app/features/clinic/models/clinics_services_response.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
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
    if (cubit.state.currentStep == BookingSteps.payment &&
        cubit.state.appointment != null) {
      context.goNamed(RouteNames.bookings);
      return;
    }
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

  String _localizeMessage(AppLocalizations l10n, String? message) {
    switch (message) {
      case BookTreatmentMessageKeys.pleaseChooseServiceDateTime:
        return l10n.pleaseChooseServiceDateTime;
      case BookTreatmentMessageKeys.appointmentBookedSuccessfully:
        return l10n.appointmentBookedSuccessfully;
      case BookTreatmentMessageKeys.paymentFailed:
        return l10n.paymentFailed;
      case BookTreatmentMessageKeys.paymentVerificationPending:
        return l10n.paymentVerificationPending;
      case BookTreatmentMessageKeys.stripeNotConfigured:
        return l10n.stripeNotConfigured;
      case BookTreatmentMessageKeys.stripeGatewayUnavailable:
        return l10n.stripeGatewayUnavailable;
      case BookTreatmentMessageKeys.paymentNoLongerAvailable:
        return l10n.paymentNoLongerAvailable;
      default:
        return message ?? l10n.appointmentBookedSuccessfully;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BookTreatmentCubit>.value(
      value: _cubit,
      child: BlocListener<BookTreatmentCubit, BookTreatmentState>(
        listenWhen: (BookTreatmentState previous, BookTreatmentState current) =>
            previous.status != current.status ||
            previous.paymentMessage != current.paymentMessage,
        listener: (BuildContext context, BookTreatmentState state) {
          final AppLocalizations l10n = AppLocalizations.of(context);
          if (state.status == BookTreatmentStatus.failure &&
              state.message != null) {
            context.showSnackbar(
              _localizeMessage(l10n, state.message),
              isError: true,
            );
          }
          if (state.paymentMessage != null) {
            context.showSnackbar(
              _localizeMessage(l10n, state.paymentMessage),
              isError: state.paymentStatus == BookingPaymentStatus.failure,
            );
          }
          if (state.status == BookTreatmentStatus.success) {
            context.showSnackbar(_localizeMessage(l10n, state.message));
            final bool isRescheduling = context
                .read<BookTreatmentCubit>()
                .state
                .isRescheduling;
            if (isRescheduling && context.canPop()) {
              context.pop(true);
            } else {
              context.goNamed(RouteNames.bookings);
            }
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
    return BlocSelector<
      BookTreatmentCubit,
      BookTreatmentState,
      (BookTreatmentStatus, bool, String?)
    >(
      selector: (BookTreatmentState state) =>
          (state.status, state.hasData, state.message),
      builder:
          (BuildContext context, (BookTreatmentStatus, bool, String?) phase) {
            final (BookTreatmentStatus status, bool hasData, String? message) =
                phase;

            if (!hasData &&
                (status == BookTreatmentStatus.initial ||
                    status == BookTreatmentStatus.loading)) {
              return const BookTreatmentSkeleton();
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
    return BlocSelector<BookTreatmentCubit, BookTreatmentState, (int, bool)>(
      selector: (BookTreatmentState state) =>
          (state.currentStep, state.requiresDeposit),
      builder: (BuildContext context, (int, bool) stepData) {
        final (int currentStep, bool includePayment) = stepData;
        return Column(
          children: <Widget>[
            if (!context.read<BookTreatmentCubit>().state.isPaymentContinuation)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: BookingProgressIndicator(
                  currentStep: currentStep,
                  includePayment: includePayment,
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
                  BookingSteps.time => const _TimeStepSection(
                    key: ValueKey<int>(BookingSteps.time),
                  ),
                  _ => const _PaymentStepSection(
                    key: ValueKey<int>(BookingSteps.payment),
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
    final AppLocalizations l10n = AppLocalizations.of(context);

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
          specialistName:
              state.selectedEmployee?.name ?? l10n.anySpecialistName,
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

class _PaymentStepSection extends StatelessWidget {
  const _PaymentStepSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return BlocBuilder<BookTreatmentCubit, BookTreatmentState>(
      buildWhen: (BookTreatmentState previous, BookTreatmentState current) =>
          previous.selectedServiceId != current.selectedServiceId ||
          previous.selectedEmployeeId != current.selectedEmployeeId ||
          previous.selectedDate != current.selectedDate ||
          previous.selectedSlotStartsAt != current.selectedSlotStartsAt ||
          previous.appointment != current.appointment ||
          previous.payment != current.payment,
      builder: (BuildContext context, BookTreatmentState state) {
        return PaymentStep(
          serviceName:
              state.selectedService?.name ??
              state.appointment?.serviceName ??
              '—',
          specialistName:
              state.selectedEmployee?.name ??
              state.appointment?.employeeName ??
              l10n.anySpecialistName,
          dateLabel: state.selectedDateLabel,
          timeLabel: state.selectedTimeLabel,
          amountDueLabel: state.depositAmountLabel,
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return BlocSelector<
      BookTreatmentCubit,
      BookTreatmentState,
      (int, bool, bool, bool, String, String, bool, BookTreatmentStatus)
    >(
      selector: (BookTreatmentState state) => (
        state.currentStep,
        state.isLastStep ? state.canConfirm : state.canContinue,
        state.isSubmitting || state.isPaymentBusy,
        state.hasData,
        state.currentStep == BookingSteps.payment
            ? state.depositAmountLabel
            : state.totalLabel,
        state.selectedTimeLabel,
        state.paymentSheetCompleted,
        state.status,
      ),
      builder: (BuildContext context, data) {
        final (
          int currentStep,
          bool isEnabled,
          bool isSubmitting,
          bool hasData,
          String total,
          String time,
          bool paymentSheetCompleted,
          BookTreatmentStatus status,
        ) = data;

        if (!hasData) {
          if (status == BookTreatmentStatus.initial ||
              status == BookTreatmentStatus.loading) {
            return const BookTreatmentBottomBarSkeleton();
          }
          return const SizedBox.shrink();
        }

        final BookTreatmentCubit cubit = context.read<BookTreatmentCubit>();
        final bool isLastStep = cubit.state.isLastStep;
        final bool isPaymentStep = currentStep == BookingSteps.payment;

        return BookingSummaryBar(
          isLastStep: isLastStep,
          isEnabled: isEnabled,
          isLoading: isSubmitting,
          total: total,
          time: time,
          confirmText: isPaymentStep
              ? paymentSheetCompleted
                    ? l10n.checkPaymentStatus
                    : l10n.payWithStripe
              : (cubit.state.args?.isRescheduling ?? false)
              ? l10n.confirmReschedule
              : l10n.confirmBooking,
          onPressed: isPaymentStep
              ? cubit.payDeposit
              : currentStep == BookingSteps.time
              ? cubit.confirmBooking
              : cubit.nextStep,
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
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String? localizedMessage =
        message == BookTreatmentMessageKeys.paymentNoLongerAvailable
        ? l10n.paymentNoLongerAvailable
        : message;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              localizedMessage ?? l10n.noServicesAvailable,
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
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
