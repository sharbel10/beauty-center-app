class SplashState {
  const SplashState({this.isLoading = false, this.nextRouteName});

  final bool isLoading;
  final String? nextRouteName;

  SplashState copyWith({bool? isLoading, String? nextRouteName}) {
    return SplashState(
      isLoading: isLoading ?? this.isLoading,
      nextRouteName: nextRouteName ?? this.nextRouteName,
    );
  }
}
