import 'package:beauty_center_app/features/auth/models/customer.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus { initial, submitting, success, failure }

enum AuthOperation { none, register, verifyOtp, resendOtp, login }

class AuthState extends Equatable {
  const AuthState({
    required this.isAuthenticated,
    this.status = AuthStatus.initial,
    this.operation = AuthOperation.none,
    this.customer,
    this.token,
    this.message,
    this.errors,
  });

  final bool isAuthenticated;
  final AuthStatus status;
  final AuthOperation operation;
  final Customer? customer;
  final String? token;
  final String? message;
  final Map<String, dynamic>? errors;

  bool get isSubmitting => status == AuthStatus.submitting;

  AuthState copyWith({
    bool? isAuthenticated,
    AuthStatus? status,
    AuthOperation? operation,
    Customer? customer,
    String? token,
    String? message,
    Map<String, dynamic>? errors,
    bool clearCustomer = false,
    bool clearToken = false,
    bool clearMessage = false,
    bool clearErrors = false,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      status: status ?? this.status,
      operation: operation ?? this.operation,
      customer: clearCustomer ? null : (customer ?? this.customer),
      token: clearToken ? null : (token ?? this.token),
      message: clearMessage ? null : (message ?? this.message),
      errors: clearErrors ? null : (errors ?? this.errors),
    );
  }

  @override
  List<Object?> get props => [
    isAuthenticated,
    status,
    operation,
    customer,
    token,
    message,
    errors,
  ];
}
