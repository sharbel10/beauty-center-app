import 'package:beauty_center_app/core/services/location_service.dart';
import 'package:beauty_center_app/features/auth/models/customer.dart';
import 'package:beauty_center_app/features/profile/models/profile_stats.dart';
import 'package:beauty_center_app/l10n/generated/app_localizations.dart';
import 'package:equatable/equatable.dart';

enum ProfileStatus { initial, loading, success, failure, updating }

enum LocationStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.customer,
    this.stats,
    this.message,
    this.locationStatus = LocationStatus.initial,
    this.userLocation,
    this.locationFailureReason,
    this.isEditMode = false,
  });

  final ProfileStatus status;
  final Customer? customer;
  final ProfileStats? stats;
  final String? message;
  final LocationStatus locationStatus;
  final UserLocation? userLocation;
  final LocationFailureReason? locationFailureReason;
  final bool isEditMode;

  bool get isLoading => status == ProfileStatus.loading;
  bool get isUpdating => status == ProfileStatus.updating;
  bool get hasCustomer => customer != null;
  bool get isLocationLoading => locationStatus == LocationStatus.loading;
  bool get hasLocation => userLocation != null;

  String locationLabel(AppLocalizations l10n) {
    if (hasLocation) {
      return userLocation!.displayLabel;
    }
    if (isLocationLoading) {
      return l10n.findingYourLocation;
    }
    switch (locationFailureReason) {
      case LocationFailureReason.serviceDisabled:
        return l10n.locationServicesOff;
      case LocationFailureReason.permissionDenied:
      case LocationFailureReason.permissionDeniedForever:
        return l10n.enableLocation;
      case LocationFailureReason.unavailable:
      case null:
        return l10n.locationUnavailable;
    }
  }

  ProfileState copyWith({
    ProfileStatus? status,
    Customer? customer,
    ProfileStats? stats,
    String? message,
    bool clearCustomer = false,
    bool clearMessage = false,
    LocationStatus? locationStatus,
    UserLocation? userLocation,
    LocationFailureReason? locationFailureReason,
    bool clearLocation = false,
    bool clearLocationFailure = false,
    bool? isEditMode,
  }) {
    return ProfileState(
      status: status ?? this.status,
      customer: clearCustomer ? null : (customer ?? this.customer),
      stats: stats ?? this.stats,
      message: clearMessage ? null : (message ?? this.message),
      locationStatus: locationStatus ?? this.locationStatus,
      userLocation: clearLocation ? null : (userLocation ?? this.userLocation),
      locationFailureReason: clearLocationFailure
          ? null
          : (locationFailureReason ?? this.locationFailureReason),
      isEditMode: isEditMode ?? this.isEditMode,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    customer,
    stats,
    message,
    locationStatus,
    userLocation,
    locationFailureReason,
    isEditMode,
  ];
}
