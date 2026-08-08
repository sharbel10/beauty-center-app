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
    this.avatarPath,
    this.avatarUrl,
    this.gender,
    this.birthDate,
    this.city,
    this.address,
    this.latitude,
    this.longitude,
    this.locationUpdatedAt,
    this.preferredLocale,
    this.notificationsEnabled,
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
      avatarPath: json['avatar_path'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      gender: json['gender'] as String?,
      birthDate: json['birth_date'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationUpdatedAt: json['location_updated_at'] as String?,
      preferredLocale: json['preferred_locale'] as String?,
      notificationsEnabled: json['notifications_enabled'] as bool?,
    );
  }

  final int id;
  final String name;
  final String phone;
  final String email;
  final bool emailVerified;
  final bool isActive;
  final String? lastLoginAt;
  final String? avatarPath;
  final String? avatarUrl;
  final String? gender;
  final String? birthDate;
  final String? city;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? locationUpdatedAt;
  final String? preferredLocale;
  final bool? notificationsEnabled;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'email_verified': emailVerified,
      'is_active': isActive,
      'last_login_at': lastLoginAt,
      'avatar_path': avatarPath,
      'avatar_url': avatarUrl,
      'gender': gender,
      'birth_date': birthDate,
      'city': city,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'location_updated_at': locationUpdatedAt,
      'preferred_locale': preferredLocale,
      'notifications_enabled': notificationsEnabled,
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
    avatarPath,
    avatarUrl,
    gender,
    birthDate,
    city,
    address,
    latitude,
    longitude,
    locationUpdatedAt,
    preferredLocale,
    notificationsEnabled,
  ];
}
