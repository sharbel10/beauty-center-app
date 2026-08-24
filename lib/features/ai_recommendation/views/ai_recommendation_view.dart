import 'dart:ui';

import 'package:beauty_center_app/core/di/injection.dart';
import 'package:beauty_center_app/core/network/api_endpoints.dart';
import 'package:beauty_center_app/core/router/route_names.dart';
import 'package:beauty_center_app/core/theme/app_colors.dart';
import 'package:beauty_center_app/core/theme/app_text_styles.dart';
import 'package:beauty_center_app/core/widgets/app_bottom_navigation.dart';
import 'package:beauty_center_app/features/ai_recommendation/cubit/ai_recommendation_cubit.dart';
import 'package:beauty_center_app/features/ai_recommendation/cubit/ai_recommendation_state.dart';
import 'package:beauty_center_app/features/ai_recommendation/models/ai_recommendations_response.dart';
import 'package:beauty_center_app/features/book_treatment/models/book_treatment_args.dart';
import 'package:beauty_center_app/features/clinic/cubit/clinic_details_cubit.dart';
import 'package:beauty_center_app/features/clinic/views/clinic_details_view.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

enum _RecommendationStep { choose, describe, scan, results }

class AiRecommendationView extends StatefulWidget {
  const AiRecommendationView({required this.cubit, super.key});

  final AiRecommendationCubit cubit;

  @override
  State<AiRecommendationView> createState() => _AiRecommendationViewState();
}

class _AiRecommendationViewState extends State<AiRecommendationView> {
  final TextEditingController _descriptionController = TextEditingController();
  late final AiRecommendationCubit _cubit;
  _RecommendationStep _step = _RecommendationStep.choose;

  @override
  void initState() {
    super.initState();
    _cubit = widget.cubit;
  }

  @override
  void didUpdateWidget(AiRecommendationView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.cubit, _cubit)) {
      widget.cubit.close();
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _goBack() {
    if (_step == _RecommendationStep.choose) {
      context.goNamed(RouteNames.home);
      return;
    }
    _cubit.reset();
    setState(() => _step = _RecommendationStep.choose);
  }

  void _showMessage(String message, {bool isError = true}) {
    if (!mounted) return;
    final Color background = isError ? AppColors.error : AppColors.primary;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: background,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _inputErrorMessage(AiRecommendationInputError error) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return switch (error) {
      AiRecommendationInputError.empty => l10n.aiInputRequired,
      AiRecommendationInputError.textTooLong => l10n.aiTextTooLong,
      AiRecommendationInputError.imageTooLarge => l10n.aiImageTooLarge,
      AiRecommendationInputError.unsupportedImage => l10n.aiUnsupportedImage,
      AiRecommendationInputError.missingImage => l10n.aiImageMissing,
    };
  }

  Future<void> _submitText() async {
    try {
      await _cubit.request(text: _descriptionController.text);
    } on AiRecommendationInputException catch (error) {
      _showMessage(_inputErrorMessage(error.error));
    }
  }

  Future<void> _submitImage(String imagePath) async {
    try {
      await _cubit.request(imagePath: imagePath);
    } on AiRecommendationInputException catch (error) {
      _showMessage(_inputErrorMessage(error.error));
    }
  }

  void _startOver() {
    _cubit.reset();
    _descriptionController.clear();
    setState(() => _step = _RecommendationStep.choose);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AiRecommendationCubit>.value(
      value: _cubit,
      child: BlocConsumer<AiRecommendationCubit, AiRecommendationState>(
        listenWhen:
            (AiRecommendationState previous, AiRecommendationState current) =>
                previous.status != current.status,
        listener: (BuildContext context, AiRecommendationState state) {
          if (state.status == AiRecommendationStatus.failure &&
              state.message != null) {
            _showMessage(state.message!);
          } else if (state.status == AiRecommendationStatus.success &&
              state.result != null) {
            setState(() => _step = _RecommendationStep.results);
          }
        },
        builder: (BuildContext context, AiRecommendationState state) {
          final AiRecommendationsResponse? recommendation = state.result;
          return PopScope(
            canPop: _step == _RecommendationStep.choose,
            onPopInvokedWithResult: (bool didPop, Object? result) {
              if (!didPop) _goBack();
            },
            child: switch (_step) {
              _RecommendationStep.choose => _ChoicePage(
                onDescribe: () =>
                    setState(() => _step = _RecommendationStep.describe),
                onScan: () => setState(() => _step = _RecommendationStep.scan),
              ),
              _RecommendationStep.describe => _DescriptionPage(
                controller: _descriptionController,
                isLoading: state.isLoading,
                onBack: _goBack,
                onContinue: _submitText,
              ),
              _RecommendationStep.scan => _FaceScanPage(
                isLoading: state.isLoading,
                onBack: _goBack,
                onImageCaptured: _submitImage,
              ),
              _RecommendationStep.results =>
                recommendation == null
                    ? const _RecommendationResultSkeleton()
                    : _ResultsPage(
                        result: recommendation,
                        onBack: _goBack,
                        onStartOver: _startOver,
                      ),
            },
          );
        },
      ),
    );
  }
}

class _RecommendationResultSkeleton extends StatelessWidget {
  const _RecommendationResultSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(child: Center(child: CircularProgressIndicator())),
    );
  }
}

class _ChoicePage extends StatelessWidget {
  const _ChoicePage({required this.onDescribe, required this.onScan});

  final VoidCallback onDescribe;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const AppBottomNavigation(
        currentItem: AppNavItem.aiScan,
      ),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
              sliver: SliverList.list(
                children: <Widget>[
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.auto_awesome_rounded,
                            size: 15,
                            color: AppColors.secondary,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            l10n.aiBeautyAssistant,
                            style: AppTextStyles.smallCaps.copyWith(
                              color: AppColors.primary,
                              fontSize: 10,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.personalRecommendation,
                    style: AppTextStyles.headlineLarge.copyWith(
                      height: 1.08,
                      fontSize: 34,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.personalRecommendationSubtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _RecommendationCard(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: l10n.describeYourNeeds,
                    subtitle: l10n.describeYourNeedsSubtitle,
                    buttonLabel: l10n.startWithDescription,
                    onPressed: onDescribe,
                  ),
                  const SizedBox(height: 16),
                  _RecommendationCard(
                    icon: Icons.face_retouching_natural_rounded,
                    title: l10n.scanYourFace,
                    subtitle: l10n.scanYourFaceSubtitle,
                    buttonLabel: l10n.startFaceScan,
                    emphasized: true,
                    onPressed: onScan,
                  ),
                  SizedBox(
                    height: 80 + AppBottomNavigation.contentOverlap(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
    this.emphasized = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final Color foreground = emphasized ? Colors.white : AppColors.textPrimary;
    final Color secondaryForeground = emphasized
        ? Colors.white.withValues(alpha: 0.72)
        : AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: emphasized
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Color(0xFF102C4C), AppColors.primary],
              )
            : null,
        color: emphasized ? null : AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        border: emphasized
            ? null
            : Border.all(color: AppColors.divider.withValues(alpha: 0.8)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: emphasized ? 0.9 : 0.45),
            blurRadius: emphasized ? 28 : 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: emphasized
                  ? AppColors.secondary.withValues(alpha: 0.18)
                  : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              icon,
              color: emphasized ? AppColors.secondary : AppColors.primary,
              size: 27,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            style: AppTextStyles.titleLarge.copyWith(
              color: foreground,
              fontSize: 21,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: secondaryForeground,
              height: 1.55,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: emphasized
                ? FilledButton(
                    onPressed: onPressed,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.primary,
                    ),
                    child: _CardButtonLabel(label: buttonLabel),
                  )
                : OutlinedButton(
                    onPressed: onPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                    child: _CardButtonLabel(label: buttonLabel),
                  ),
          ),
        ],
      ),
    );
  }
}

class _CardButtonLabel extends StatelessWidget {
  const _CardButtonLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: DefaultTextStyle.of(context).style.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.arrow_forward_rounded, size: 18),
      ],
    );
  }
}

class _DescriptionPage extends StatelessWidget {
  const _DescriptionPage({
    required this.controller,
    required this.isLoading,
    required this.onBack,
    required this.onContinue,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onBack;
  final Future<void> Function() onContinue;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _LuminaAppBar(onBack: onBack),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppColors.secondary,
                  size: 29,
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.yourBeautyGoals, style: AppTextStyles.headlineMedium),
              const SizedBox(height: 12),
              Text(
                l10n.describeYourNeedsSubtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: controller,
                enabled: !isLoading,
                maxLength: AiRecommendationCubit.maxTextLength,
                minLines: 7,
                maxLines: 10,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: l10n.beautyGoalsHint,
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                    height: 1.55,
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                  contentPadding: const EdgeInsets.all(20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: AppColors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: AppColors.secondary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: isLoading ? null : onContinue,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  icon: isLoading
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.auto_awesome_rounded, size: 19),
                  label: Text(
                    isLoading
                        ? l10n.aiAnalyzingTitle
                        : l10n.continueToRecommendation,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.clinicalPrivacyNotice,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultsPage extends StatelessWidget {
  const _ResultsPage({
    required this.result,
    required this.onBack,
    required this.onStartOver,
  });

  final AiRecommendationsResponse result;
  final VoidCallback onBack;
  final VoidCallback onStartOver;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _LuminaAppBar(onBack: onBack),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
              sliver: SliverList.list(
                children: <Widget>[
                  Container(
                    width: 58,
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: <Color>[AppColors.secondary, Color(0xFFE5CB96)],
                      ),
                      borderRadius: BorderRadius.circular(19),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.aiResultsTitle,
                    style: AppTextStyles.headlineMedium,
                  ),
                  const SizedBox(height: 9),
                  Text(
                    l10n.aiResultsSubtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (result.isEmpty)
                    _EmptyRecommendations(onStartOver: onStartOver)
                  else ...<Widget>[
                    if (result.services.isNotEmpty) ...<Widget>[
                      _ResultSectionTitle(
                        icon: Icons.spa_outlined,
                        title: l10n.aiSuggestedServices,
                      ),
                      const SizedBox(height: 14),
                      for (final AiRecommendedService service
                          in result.services) ...<Widget>[
                        _RecommendedServiceCard(service: service),
                        const SizedBox(height: 14),
                      ],
                    ],
                    if (result.centers.isNotEmpty) ...<Widget>[
                      if (result.services.isNotEmpty)
                        const SizedBox(height: 12),
                      _ResultSectionTitle(
                        icon: Icons.storefront_outlined,
                        title: l10n.aiSuggestedCenters,
                      ),
                      const SizedBox(height: 14),
                      for (final AiRecommendedCenter center
                          in result.centers) ...<Widget>[
                        _RecommendedCenterCard(center: center),
                        const SizedBox(height: 14),
                      ],
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: onStartOver,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(l10n.aiNewRecommendation),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultSectionTitle extends StatelessWidget {
  const _ResultSectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: AppColors.secondary, size: 21),
        const SizedBox(width: 9),
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.primary,
            fontSize: 18,
          ),
        ),
      ],
    );
  }
}

class _RecommendedServiceCard extends StatelessWidget {
  const _RecommendedServiceCard({required this.service});

  final AiRecommendedService service;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int? centerId = service.centerId;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x100A2A55),
            blurRadius: 18,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (service.imageUrl.isNotEmpty)
            _RecommendationImage(url: service.imageUrl, height: 150),
          Padding(
            padding: const EdgeInsets.all(19),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        service.name,
                        style: AppTextStyles.titleMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _MatchBadge(percent: service.matchPercentage),
                  ],
                ),
                if (service.centerName.isNotEmpty ||
                    service.categoryName.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Text(
                    <String>[
                      if (service.centerName.isNotEmpty) service.centerName,
                      if (service.categoryName.isNotEmpty) service.categoryName,
                    ].join(' · '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                if (service.description.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 10),
                  Text(
                    service.description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: <Widget>[
                    if (service.durationMinutes > 0) ...<Widget>[
                      const Icon(
                        Icons.schedule_rounded,
                        color: AppColors.secondary,
                        size: 17,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.clinicDurationMinutes(service.durationMinutes),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      l10n.priceSp(_formatPrice(service.finalPrice)),
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (centerId != null) ...<Widget>[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton(
                      onPressed: () => context.pushNamed(
                        RouteNames.bookTreatment,
                        extra: BookTreatmentArgs(
                          centerId: centerId,
                          initialServiceId: service.id,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: Text(l10n.aiBookService),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedCenterCard extends StatelessWidget {
  const _RecommendedCenterCard({required this.center});

  final AiRecommendedCenter center;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ClinicDetailsView(
            centerId: center.id,
            cubit: getIt<ClinicDetailsCubit>(),
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 72,
                height: 72,
                child: center.imageUrl.isEmpty
                    ? const ColoredBox(
                        color: AppColors.surfaceMuted,
                        child: Icon(
                          Icons.storefront_outlined,
                          color: AppColors.primary,
                        ),
                      )
                    : _RecommendationImage(url: center.imageUrl, height: 72),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    center.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
                  ),
                  if (center.location.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 5),
                    Text(
                      center.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 7),
                  Text(
                    l10n.aiViewCenter,
                    style: AppTextStyles.link.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            if (center.matchPercentage case final int percent)
              _MatchBadge(percent: percent),
          ],
        ),
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        AppLocalizations.of(context).aiMatchPercent(percent),
        style: AppTextStyles.smallCaps.copyWith(
          color: const Color(0xFF765817),
          fontSize: 8,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

class _RecommendationImage extends StatelessWidget {
  const _RecommendationImage({required this.url, required this.height});

  final String url;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Image.network(
        ApiEndpoints.mediaUrl(url),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(
          color: AppColors.surfaceMuted,
          child: Icon(Icons.image_not_supported_outlined),
        ),
      ),
    );
  }
}

class _EmptyRecommendations extends StatelessWidget {
  const _EmptyRecommendations({required this.onStartOver});

  final VoidCallback onStartOver;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: <Widget>[
          const Icon(
            Icons.search_off_rounded,
            color: AppColors.textMuted,
            size: 42,
          ),
          const SizedBox(height: 14),
          Text(
            l10n.aiNoRecommendations,
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.aiNoRecommendationsSubtitle,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: onStartOver,
            child: Text(l10n.aiNewRecommendation),
          ),
        ],
      ),
    );
  }
}

String _formatPrice(double value) {
  final String digits = value.toStringAsFixed(0);
  return digits.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match match) => '${match[1]},',
  );
}

class _FaceScanPage extends StatefulWidget {
  const _FaceScanPage({
    required this.isLoading,
    required this.onBack,
    required this.onImageCaptured,
  });

  final bool isLoading;
  final VoidCallback onBack;
  final Future<void> Function(String imagePath) onImageCaptured;

  @override
  State<_FaceScanPage> createState() => _FaceScanPageState();
}

class _FaceScanPageState extends State<_FaceScanPage> {
  final GlobalKey<_CameraPreviewLayerState> _cameraKey =
      GlobalKey<_CameraPreviewLayerState>();
  bool _isCapturing = false;

  Future<void> _captureAndSubmit() async {
    if (_isCapturing || widget.isLoading) return;
    setState(() => _isCapturing = true);
    try {
      final XFile? image = await _cameraKey.currentState?.captureImage();
      if (image == null) {
        throw CameraException('captureUnavailable', 'Camera not ready');
      }
      await widget.onImageCaptured(image.path);
    } on Object {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).aiCaptureFailed),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF081A2E),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _CameraPreviewLayer(key: _cameraKey),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: <double>[0, 0.42, 1],
                colors: <Color>[
                  Color(0x99031C35),
                  Color(0x11031C35),
                  Color(0xF2031C35),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: <Widget>[
                _ScanHeader(onBack: widget.onBack),
                Expanded(
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                          final double frameHeight =
                              (constraints.maxHeight * 0.55).clamp(
                                290.0,
                                430.0,
                              );
                          final double frameWidth = (frameHeight * 0.76).clamp(
                            230.0,
                            constraints.maxWidth - 42,
                          );

                          return Column(
                            children: <Widget>[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: frameWidth,
                                height: frameHeight,
                                child: const CustomPaint(
                                  painter: _FaceFramePainter(),
                                  child: Center(
                                    child: Icon(
                                      Icons.face_retouching_natural_rounded,
                                      size: 92,
                                      color: Color(0x2BFFFFFF),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                l10n.biometricAlignment,
                                style: AppTextStyles.smallCaps.copyWith(
                                  color: const Color(0xFFE3C282),
                                  fontSize: 10,
                                  letterSpacing: 2.1,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Text(
                                  l10n.alignFaceWithinFrame,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.titleLarge.copyWith(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 36,
                                ),
                                child: Text(
                                  l10n.wellLitScanHint,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.65),
                                    fontSize: 11,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                  ),
                ),
                _ScanActionPanel(
                  isLoading: widget.isLoading || _isCapturing,
                  onScan: _captureAndSubmit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraPreviewLayer extends StatefulWidget {
  const _CameraPreviewLayer({super.key});

  @override
  State<_CameraPreviewLayer> createState() => _CameraPreviewLayerState();
}

class _CameraPreviewLayerState extends State<_CameraPreviewLayer>
    with WidgetsBindingObserver {
  CameraController? _controller;
  bool _isLoading = true;
  bool _hasError = false;

  Future<XFile?> captureImage() async {
    final CameraController? controller = _controller;
    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return null;
    }
    return controller.takePicture();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    CameraController? nextController;
    try {
      final List<CameraDescription> cameras = await availableCameras();
      if (cameras.isEmpty) throw StateError('No camera is available');

      final CameraDescription camera = cameras.firstWhere(
        (CameraDescription item) =>
            item.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      nextController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await nextController.initialize();

      if (!mounted) {
        await nextController.dispose();
        return;
      }
      final CameraController? previousController = _controller;
      setState(() {
        _controller = nextController;
        _isLoading = false;
      });
      await previousController?.dispose();
    } on Object {
      await nextController?.dispose();
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      _controller = null;
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final CameraController? controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      final Size screenSize = MediaQuery.sizeOf(context);
      double scale = screenSize.aspectRatio * controller.value.aspectRatio;
      if (scale < 1) scale = 1 / scale;

      return ClipRect(
        child: Transform.scale(
          scale: scale,
          child: Center(child: CameraPreview(controller)),
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const _CameraPreviewPlaceholder(),
        if (_isLoading)
          const Center(
            child: CircularProgressIndicator(color: AppColors.secondary),
          )
        else if (_hasError)
          _CameraErrorState(onRetry: _initializeCamera),
      ],
    );
  }
}

class _CameraErrorState extends StatelessWidget {
  const _CameraErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.no_photography_outlined,
              color: Colors.white.withValues(alpha: 0.7),
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.cameraUnavailable,
              textAlign: TextAlign.center,
              style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.cameraUnavailableHint,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white.withValues(alpha: 0.65),
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE3C282),
                side: const BorderSide(color: Color(0xFFE3C282)),
              ),
              child: Text(l10n.tryCameraAgain),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraPreviewPlaceholder extends StatelessWidget {
  const _CameraPreviewPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: AppLocalizations.of(context).cameraPreviewPlaceholder,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.28),
            radius: 0.92,
            colors: <Color>[
              Color(0xFF607384),
              Color(0xFF263C50),
              Color(0xFF0A1D31),
            ],
          ),
        ),
        child: CustomPaint(painter: _AmbientCameraPainter()),
      ),
    );
  }
}

class _ScanHeader extends StatelessWidget {
  const _ScanHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: <Widget>[
          IconButton(
            onPressed: onBack,
            color: Colors.white,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 21),
          ),
          Expanded(
            child: Text(
              'Lumina',
              textAlign: TextAlign.center,
              style: AppTextStyles.titleLarge.copyWith(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.8),
              ),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.secondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanActionPanel extends StatelessWidget {
  const _ScanActionPanel({required this.isLoading, required this.onScan});

  final bool isLoading;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Color(0xFFE3C282),
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.luminaIntelligence,
                            style: AppTextStyles.smallCaps.copyWith(
                              color: Colors.white,
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            l10n.scanAnalysisHint,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.66),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: FilledButton.icon(
              onPressed: isLoading ? null : onScan,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: const Color(0xFFE3C282),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              iconAlignment: IconAlignment.end,
              icon: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Color(0xFFE3C282),
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.sensors_rounded),
              label: Text(
                isLoading ? l10n.aiAnalyzingTitle : l10n.scanFace,
                style: AppTextStyles.button.copyWith(
                  color: const Color(0xFFE3C282),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.clinicalPrivacyNotice,
            textAlign: TextAlign.center,
            style: AppTextStyles.smallCaps.copyWith(
              color: Colors.white.withValues(alpha: 0.42),
              fontSize: 8,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _LuminaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _LuminaAppBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 21),
      ),
      title: Text(
        'Lumina',
        style: AppTextStyles.titleLarge.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: const <Widget>[
        Padding(
          padding: EdgeInsetsDirectional.only(end: 18),
          child: Icon(
            Icons.auto_awesome_rounded,
            color: AppColors.secondary,
            size: 22,
          ),
        ),
      ],
    );
  }
}

class _FaceFramePainter extends CustomPainter {
  const _FaceFramePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect frame = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    final RRect oval = RRect.fromRectAndRadius(
      frame,
      Radius.elliptical(size.width * 0.48, size.height * 0.30),
    );
    final Paint glowPaint = Paint()
      ..color = const Color(0x55E3C282)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9);
    final Paint linePaint = Paint()
      ..color = const Color(0xFFE3C282)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    canvas.drawRRect(oval, glowPaint);
    canvas.drawRRect(oval, linePaint);

    final Paint innerPaint = Paint()
      ..color = const Color(0x26735B25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        frame.deflate(size.width * 0.12),
        Radius.elliptical(size.width * 0.38, size.height * 0.24),
      ),
      innerPaint,
    );

    final Paint markerPaint = Paint()..color = const Color(0xFFE3C282);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, 1),
          width: 20,
          height: 4,
        ),
        const Radius.circular(3),
      ),
      markerPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height - 1),
          width: 20,
          height: 4,
        ),
        const Radius.circular(3),
      ),
      markerPaint,
    );

    final Paint nodePaint = Paint()..color = const Color(0xFF9A792F);
    for (final Offset node in <Offset>[
      Offset(size.width * 0.27, size.height * 0.28),
      Offset(size.width * 0.73, size.height * 0.37),
      Offset(size.width * 0.50, size.height * 0.64),
    ]) {
      canvas.drawCircle(node, 4, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AmbientCameraPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint softShape = Paint()
      ..color = const Color(0x163C5265)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 26);
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.56),
      size.width * 0.34,
      softShape,
    );
    canvas.drawCircle(
      Offset(size.width * 0.87, size.height * 0.43),
      size.width * 0.42,
      softShape,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
