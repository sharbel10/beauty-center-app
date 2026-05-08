class AuthState {
  const AuthState({required this.isAuthenticated, this.isSubmitting = false});

  final bool isAuthenticated;
  final bool isSubmitting;

  AuthState copyWith({bool? isAuthenticated, bool? isSubmitting}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
