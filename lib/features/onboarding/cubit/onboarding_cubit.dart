import 'package:beauty_center_app/core/storage/preference_manager.dart';
import 'package:beauty_center_app/features/onboarding/cubit/onboarding_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class OnboardingCubit extends Cubit<OnboardingState> {
  OnboardingCubit(this._preferenceManager) : super(const OnboardingState());

  final PreferenceManager _preferenceManager;

  void completeOnboarding() async {
    await _preferenceManager.markFirstLaunchCompleted();
    emit(state.copyWith(isCompleted: true));
  }
}
