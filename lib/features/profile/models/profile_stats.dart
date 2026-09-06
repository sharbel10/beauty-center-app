import 'package:equatable/equatable.dart';

class ProfileStats extends Equatable {
  const ProfileStats({
    required this.appointmentsTotal,
    required this.appointmentsUpcoming,
    required this.appointmentsCompleted,
    required this.favoriteCenters,
    required this.favoriteServices,
    required this.reviews,
    required this.unreadNotifications,
  });

  factory ProfileStats.fromJson(Map<String, dynamic> json) {
    return ProfileStats(
      appointmentsTotal: json['appointments_total'] as int? ?? 0,
      appointmentsUpcoming: json['appointments_upcoming'] as int? ?? 0,
      appointmentsCompleted: json['appointments_completed'] as int? ?? 0,
      favoriteCenters: json['favorite_centers'] as int? ?? 0,
      favoriteServices: json['favorite_services'] as int? ?? 0,
      reviews: json['reviews'] as int? ?? 0,
      unreadNotifications: json['unread_notifications'] as int? ?? 0,
    );
  }

  final int appointmentsTotal;
  final int appointmentsUpcoming;
  final int appointmentsCompleted;
  final int favoriteCenters;
  final int favoriteServices;
  final int reviews;
  final int unreadNotifications;

  @override
  List<Object?> get props => [
    appointmentsTotal,
    appointmentsUpcoming,
    appointmentsCompleted,
    favoriteCenters,
    favoriteServices,
    reviews,
    unreadNotifications,
  ];
}
