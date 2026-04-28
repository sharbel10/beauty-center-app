class OnboardingState {
  const OnboardingState({this.isCompleted = false});

  final bool isCompleted;

  OnboardingState copyWith({bool? isCompleted}) {
    return OnboardingState(isCompleted: isCompleted ?? this.isCompleted);
  }
}
