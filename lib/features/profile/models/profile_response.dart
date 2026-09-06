import 'package:beauty_center_app/features/auth/models/customer.dart';
import 'package:beauty_center_app/features/profile/models/profile_stats.dart';
import 'package:equatable/equatable.dart';

class ProfileResponse extends Equatable {
  const ProfileResponse({
    required this.success,
    this.customer,
    this.stats,
    this.message,
  });

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic>? data = json['data'] as Map<String, dynamic>?;
    final Map<String, dynamic>? customerJson =
        data?['customer'] as Map<String, dynamic>?;
    final Map<String, dynamic>? statsJson =
        data?['stats'] as Map<String, dynamic>?;

    return ProfileResponse(
      success: json['success'] as bool? ?? true,
      customer: customerJson != null ? Customer.fromJson(customerJson) : null,
      stats: statsJson != null ? ProfileStats.fromJson(statsJson) : null,
      message: json['message'] as String?,
    );
  }

  final bool success;
  final Customer? customer;
  final ProfileStats? stats;
  final String? message;

  @override
  List<Object?> get props => <Object?>[success, customer, stats, message];
}
