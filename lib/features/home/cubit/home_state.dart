import 'package:beauty_center_app/core/services/location_service.dart';
import 'package:beauty_center_app/features/home/models/home_data.dart';
import 'package:equatable/equatable.dart';

enum HomeStatus { initial, loading, success, failure }

enum LocationStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  const HomeState({
    this.status = HomeStatus.initial,
    this.data,
    this.message,
    this.locationStatus = LocationStatus.initial,
    this.userLocation,
    this.locationFailureReason,
  });

  final HomeStatus status;
  final HomeData? data;
  final String? message;
  final LocationStatus locationStatus;
  final UserLocation? userLocation;
  final LocationFailureReason? locationFailureReason;

  bool get isLoading => status == HomeStatus.loading;
  bool get hasData => data != null;
  bool get isLocationLoading => locationStatus == LocationStatus.loading;
  bool get hasLocation => userLocation != null;

  String get locationLabel {
    if (hasLocation) {
      return userLocation!.displayLabel;
    }
    if (isLocationLoading) {
      return 'Finding your location...';
    }
    switch (locationFailureReason) {
      case LocationFailureReason.serviceDisabled:
        return 'Location services off';
      case LocationFailureReason.permissionDenied:
      case LocationFailureReason.permissionDeniedForever:
        return 'Enable location';
      case LocationFailureReason.unavailable:
      case null:
        return 'Location unavailable';
    }
  }

  HomeState copyWith({
    HomeStatus? status,
    HomeData? data,
    String? message,
    bool clearData = false,
    bool clearMessage = false,
    LocationStatus? locationStatus,
    UserLocation? userLocation,
    LocationFailureReason? locationFailureReason,
    bool clearLocation = false,
    bool clearLocationFailure = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      data: clearData ? null : (data ?? this.data),
      message: clearMessage ? null : (message ?? this.message),
      locationStatus: locationStatus ?? this.locationStatus,
      userLocation: clearLocation ? null : (userLocation ?? this.userLocation),
      locationFailureReason: clearLocationFailure
          ? null
          : (locationFailureReason ?? this.locationFailureReason),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    data,
    message,
    locationStatus,
    userLocation,
    locationFailureReason,
  ];
}
