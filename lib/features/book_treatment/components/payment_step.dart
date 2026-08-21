import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/features/book_treatment/components/booking_step_title.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';

/// Reviews the deposit before opening Stripe's native PaymentSheet.
class PaymentStep extends StatelessWidget {
  const PaymentStep({
    required this.serviceName,
    required this.specialistName,
    required this.dateLabel,
    required this.timeLabel,
    required this.amountDueLabel,
    super.key,
  });

  final String serviceName;
  final String specialistName;
  final String dateLabel;
  final String timeLabel;
  final String amountDueLabel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          BookingStepTitle(
            title: l10n.paymentTitle,
            subtitle: l10n.paymentSubtitle,
          ),
          const SizedBox(height: 20),
          _TestModeBanner(label: l10n.stripeTestMode),
          const SizedBox(height: 16),
          _SummaryCard(
            serviceName: serviceName,
            specialistName: specialistName,
            dateLabel: dateLabel,
            timeLabel: timeLabel,
            totalLabel: amountDueLabel,
          ),
          const SizedBox(height: 16),
          _PaymentMethodCard(
            title: l10n.stripePaymentMethodTitle,
            subtitle: l10n.stripePaymentMethodSubtitle,
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.textMuted,
                size: 17,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.paymentSecureNotice,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TestModeBanner extends StatelessWidget {
  const _TestModeBanner({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.science_outlined,
            size: 17,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.serviceName,
    required this.specialistName,
    required this.dateLabel,
    required this.timeLabel,
    required this.totalLabel,
  });

  final String serviceName;
  final String specialistName;
  final String dateLabel;
  final String timeLabel;
  final String totalLabel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          _SummaryRow(label: l10n.serviceLabel, value: serviceName),
          const SizedBox(height: 12),
          _SummaryRow(label: l10n.specialistLabel, value: specialistName),
          const SizedBox(height: 12),
          _SummaryRow(label: l10n.dateLabel, value: dateLabel),
          const SizedBox(height: 12),
          _SummaryRow(label: l10n.timeLabel, value: timeLabel),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(height: 1, color: AppColors.divider),
          ),
          _SummaryRow(
            label: l10n.amountDueNow,
            value: totalLabel,
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
              fontWeight: emphasize ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTextStyles.bodyMedium.copyWith(
              color: emphasize ? AppColors.primary : AppColors.textPrimary,
              fontSize: emphasize ? 16 : 14,
              fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 48,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF635BFF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.credit_card_rounded,
              color: Color(0xFF635BFF),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textFaint),
        ],
      ),
    );
  }
}
