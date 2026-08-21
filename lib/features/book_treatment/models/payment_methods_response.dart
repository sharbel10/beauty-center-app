import 'package:equatable/equatable.dart';

class PaymentMethodsResponse extends Equatable {
  const PaymentMethodsResponse({
    required this.currency,
    required this.deposit,
    required this.methods,
  });

  factory PaymentMethodsResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data =
        json['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final List<dynamic> methods =
        data['methods'] as List<dynamic>? ?? <dynamic>[];

    return PaymentMethodsResponse(
      currency: data['currency'] as String? ?? '',
      deposit: DepositPolicy.fromJson(
        data['deposit'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      methods: methods
          .map(
            (dynamic item) =>
                PaymentGatewayOption.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  final String currency;
  final DepositPolicy deposit;
  final List<PaymentGatewayOption> methods;

  PaymentGatewayOption? get stripeGateway {
    for (final PaymentGatewayOption method in methods) {
      if (method.code.toLowerCase() == 'stripe' && method.isOnline) {
        return method;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => <Object?>[currency, deposit, methods];
}

class DepositPolicy extends Equatable {
  const DepositPolicy({required this.type, required this.value});

  factory DepositPolicy.fromJson(Map<String, dynamic> json) {
    return DepositPolicy(
      type: json['type'] as String? ?? 'none',
      value: (json['value'] as num?)?.toDouble() ?? 0,
    );
  }

  final String type;
  final double value;

  bool get isRequired => type.toLowerCase() != 'none' && value > 0;

  @override
  List<Object?> get props => <Object?>[type, value];
}

class PaymentGatewayOption extends Equatable {
  const PaymentGatewayOption({
    required this.id,
    required this.name,
    required this.code,
    required this.isOnline,
  });

  factory PaymentGatewayOption.fromJson(Map<String, dynamic> json) {
    return PaymentGatewayOption(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      isOnline: json['is_online'] as bool? ?? false,
    );
  }

  final int id;
  final String name;
  final String code;
  final bool isOnline;

  @override
  List<Object?> get props => <Object?>[id, name, code, isOnline];
}
