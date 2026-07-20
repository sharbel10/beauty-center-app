import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.emailVerified,
    required this.isActive,
    this.lastLoginAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      emailVerified: json['email_verified'] as bool,
      isActive: json['is_active'] as bool,
      lastLoginAt: json['last_login_at'] as String?,
    );
  }

  final int id;
  final String name;
  final String phone;
  final String email;
  final bool emailVerified;
  final bool isActive;
  final String? lastLoginAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'email_verified': emailVerified,
      'is_active': isActive,
      'last_login_at': lastLoginAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    phone,
    email,
    emailVerified,
    isActive,
    lastLoginAt,
  ];
}
