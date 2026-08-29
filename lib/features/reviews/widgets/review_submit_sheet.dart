import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/utils/extensions.dart';
import 'package:beauty_center_app/features/bookings/models/appointment_model.dart';
import 'package:beauty_center_app/features/reviews/cubit/reviews_cubit.dart';
import 'package:beauty_center_app/features/reviews/cubit/reviews_state.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewSubmitSheet extends StatefulWidget {
  const ReviewSubmitSheet({required this.appointment, super.key});

  final AppointmentModel appointment;

  @override
  State<ReviewSubmitSheet> createState() => _ReviewSubmitSheetState();
}

class _ReviewSubmitSheetState extends State<ReviewSubmitSheet> {
  final TextEditingController _commentController = TextEditingController();
  int _rating = 0;
  int _hoveredRating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double bottomInset = mediaQuery.viewInsets.bottom > 0
        ? mediaQuery.viewInsets.bottom
        : mediaQuery.viewPadding.bottom;
    final ReviewsCubit cubit = context.read<ReviewsCubit>();

    return BlocConsumer<ReviewsCubit, ReviewsState>(
      bloc: cubit,
      listenWhen: (ReviewsState previous, ReviewsState current) =>
          previous.submitStatus != current.submitStatus &&
          (current.submitStatus == SubmitReviewStatus.success ||
              current.submitStatus == SubmitReviewStatus.failure),
      listener: (BuildContext context, ReviewsState state) {
        final AppLocalizations l10n = AppLocalizations.of(context);
        if (state.submitStatus == SubmitReviewStatus.success) {
          context.showSnackbar(state.message ?? l10n.reviewSubmitted);
          Navigator.of(context).pop(true);
        } else if (state.submitStatus == SubmitReviewStatus.failure) {
          context.showSnackbar(
            state.message ?? l10n.reviewSubmitFailed,
            isError: true,
          );
        }
      },
      builder: (BuildContext context, ReviewsState state) {
        final bool isSubmitting = state.isAppointmentSubmitting(
          widget.appointment.id,
        );

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
                      Text(
                        l10n.rateExperience,
                        style: AppTextStyles.title.copyWith(fontSize: 20),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.howWasAppointment(widget.appointment.clinicName),
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _StarRatingInput(
                        rating: _rating,
                        hoveredRating: _hoveredRating,
                        onChanged: (int value) =>
                            setState(() => _rating = value),
                        onHover: (int? value) =>
                            setState(() => _hoveredRating = value ?? 0),
                      ),
                      if (_rating > 0) ...<Widget>[
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            _ratingLabel(_rating, l10n),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      _CommentField(controller: _commentController, l10n: l10n),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: (_rating > 0 && !isSubmitting)
                              ? () => _submitReview(cubit)
                              : null,
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: AppColors.white,
                                  ),
                                )
                              : const Icon(Icons.send_rounded, size: 18),
                          label: Text(
                            isSubmitting ? l10n.submitting : l10n.submitReview,
                            style: AppTextStyles.button.copyWith(fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.surface,
                            disabledBackgroundColor: AppColors.tertiary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
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
        );
      },
    );
  }

  Future<void> _submitReview(ReviewsCubit cubit) async {
    final int? centerId = widget.appointment.centerId;
    final int? serviceId = widget.appointment.serviceId;
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (centerId == null || serviceId == null) {
      if (mounted) {
        context.showSnackbar(l10n.missingAppointmentDetails, isError: true);
      }
      return;
    }

    try {
      await cubit.submitReview(
        appointmentId: widget.appointment.id,
        centerId: centerId,
        serviceId: serviceId,
        employeeId: widget.appointment.employeeId,
        rating: _rating,
        comment: _commentController.text,
      );
    } catch (_) {
      // Error is handled via Bloc listener snackbar; no need for double handling.
    }
  }

  String _ratingLabel(int rating, AppLocalizations l10n) {
    return switch (rating) {
      1 => l10n.ratingPoor,
      2 => l10n.ratingFair,
      3 => l10n.ratingAverage,
      4 => l10n.ratingGood,
      5 => l10n.ratingExcellent,
      _ => '',
    };
  }
}

class _StarRatingInput extends StatelessWidget {
  const _StarRatingInput({
    required this.rating,
    required this.hoveredRating,
    required this.onChanged,
    required this.onHover,
  });

  final int rating;
  final int hoveredRating;
  final ValueChanged<int> onChanged;
  final ValueChanged<int?> onHover;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(5, (int index) {
          final int starValue = index + 1;
          final bool isFilled =
              (hoveredRating > 0 ? hoveredRating : rating) >= starValue;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: MouseRegion(
              onEnter: (_) => onHover(starValue),
              onExit: (_) => onHover(null),
              child: GestureDetector(
                onTap: () => onChanged(starValue),
                child: AnimatedScale(
                  scale:
                      (hoveredRating > 0 ? hoveredRating : rating) == starValue
                      ? 1.15
                      : 1.0,
                  duration: const Duration(milliseconds: 140),
                  curve: Curves.easeOut,
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 44,
                    color: isFilled
                        ? const Color(0xFFFFB400)
                        : AppColors.textMuted,
                    shadows: isFilled
                        ? <BoxShadow>[
                            BoxShadow(
                              color: const Color(
                                0xFFFFB400,
                              ).withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _CommentField extends StatelessWidget {
  const _CommentField({required this.controller, required this.l10n});

  final TextEditingController controller;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          l10n.addCommentOptional,
          style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: 5,
          maxLength: 500,
          style: AppTextStyles.bodyLarge,
          decoration: InputDecoration(
            counterText: '',
            hintText: l10n.tellUsMore,
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textLight,
            ),
            filled: true,
            fillColor: AppColors.white,
          ),
        ),
      ],
    );
  }
}
