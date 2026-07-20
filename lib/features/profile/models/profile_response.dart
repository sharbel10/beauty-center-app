import 'package:beauty_center_app/features/auth/models/customer.dart';
import 'package:equatable/equatable.dart';

class ProfileResponse extends Equatable {
  const ProfileResponse({required this.success, this.customer});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? data = json['data'] as Map<String, dynamic>?;
    final Map<String, dynamic>? customerJson =
        data?['customer'] as Map<String, dynamic>?;

    return ProfileResponse(
      success: json['success'] as bool? ?? true,
      customer: customerJson != null ? Customer.fromJson(customerJson) : null,
    );
  }

  final bool success;
  final Customer? customer;

  @override
  List<Object?> get props => <Object?>[success, customer];
}
