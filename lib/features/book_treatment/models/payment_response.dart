import 'package:equatable/equatable.dart';

class PaymentResponse extends Equatable {
  const PaymentResponse({required this.payment});

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return PaymentResponse(
      payment: PaymentAttempt.fromJson(
        data['payment'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
    );
  }

  final PaymentAttempt payment;

  @override
  List<Object?> get props => <Object?>[payment];
}

class PaymentAttempt extends Equatable {
  const PaymentAttempt({
    required this.id,
    required this.appointmentId,
    required this.status,
    required this.amount,
    required this.currency,
    this.clientSecret,
    this.failureReason,
  });

  factory PaymentAttempt.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> stripe =
        json['stripe'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return PaymentAttempt(
      id: (json['id'] as num?)?.toInt() ?? 0,
      appointmentId: (json['appointment_id'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'pending',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? '',
      clientSecret: stripe['client_secret'] as String?,
      failureReason: json['failure_reason'] as String?,
    );
  }

  final int id;
  final int appointmentId;
  final String status;
  final double amount;
  final String currency;
  final String? clientSecret;
  final String? failureReason;

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isFailed => status.toLowerCase() == 'failed';
  bool get isPending => status.toLowerCase() == 'pending';

  @override
  List<Object?> get props => <Object?>[
    id,
    appointmentId,
    status,
    amount,
    currency,
    clientSecret,
    failureReason,
  ];
}
