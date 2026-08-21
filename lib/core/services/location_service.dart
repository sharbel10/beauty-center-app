import 'package:beauty_center_app/core/utils/app_logger.dart';
import 'package:equatable/equatable.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

class UserLocation extends Equatable {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.locality,
    this.administrativeArea,
    this.country,
  });

  final double latitude;
  final double longitude;
  final String? locality;
  final String? administrativeArea;
  final String? country;

  /// Human-readable label for the home header, e.g. "Beirut, Lebanon".
  String get displayLabel {
    final List<String> parts = <String>[
      if (locality != null && locality!.trim().isNotEmpty) locality!.trim(),
      if (administrativeArea != null &&
          administrativeArea!.trim().isNotEmpty &&
          administrativeArea!.trim() != locality?.trim())
        administrativeArea!.trim(),
      if (country != null &&
          country!.trim().isNotEmpty &&
          (locality == null || locality!.trim().isEmpty))
        country!.trim(),
    ];

    if (parts.isEmpty) {
      return '${latitude.toStringAsFixed(2)}, ${longitude.toStringAsFixed(2)}';
    }

    if (parts.length >= 2) {
      return '${parts[0]}, ${parts[1]}';
    }

    if (country != null &&
        country!.trim().isNotEmpty &&
        parts.first != country!.trim()) {
      return '${parts.first}, ${country!.trim()}';
    }

    return parts.first;
  }

  @override
  List<Object?> get props => <Object?>[
    latitude,
    longitude,
    locality,
    administrativeArea,
    country,
  ];
}

enum LocationFailureReason {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  unavailable,
}

class LocationResult {
  const LocationResult.success(this.location) : failureReason = null;

  const LocationResult.failure(this.failureReason) : location = null;

  final UserLocation? location;
  final LocationFailureReason? failureReason;

  bool get isSuccess => location != null;
}

@lazySingleton
class LocationService {
  final Geocoding _geocoding = Geocoding();

  Future<LocationResult> getCurrentLocation() async {
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const LocationResult.failure(
          LocationFailureReason.serviceDisabled,
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        return const LocationResult.failure(
          LocationFailureReason.permissionDenied,
        );
      }

      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.failure(
          LocationFailureReason.permissionDeniedForever,
        );
      }

      final Position? position = await _resolvePosition();
      if (position == null) {
        return const LocationResult.failure(LocationFailureReason.unavailable);
      }

      return LocationResult.success(await _toUserLocation(position));
    } catch (error, stackTrace) {
      AppLogger.e('Failed to get current location', error, stackTrace);
      return const LocationResult.failure(LocationFailureReason.unavailable);
    }
  }

  /// Prefer a fresh fix; fall back to last-known (common on emulators
  /// where GPS never produces a first fix).
  Future<Position?> _resolvePosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (error) {
      AppLogger.w('getCurrentPosition failed, trying last known: $error');
      return Geolocator.getLastKnownPosition();
    }
  }

  Future<UserLocation> _toUserLocation(Position position) async {
    String? locality;
    String? administrativeArea;
    String? country;

    try {
      final List<Placemark> placemarks = await _geocoding
          .placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        locality = place.locality?.trim().isNotEmpty == true
            ? place.locality
            : place.subAdministrativeArea;
        administrativeArea = place.administrativeArea;
        country = place.country;
      }
    } catch (error, stackTrace) {
      AppLogger.w('Reverse geocoding failed: $error');
      AppLogger.e('Reverse geocoding failed', error, stackTrace);
    }

    return UserLocation(
      latitude: position.latitude,
      longitude: position.longitude,
      locality: locality,
      administrativeArea: administrativeArea,
      country: country,
    );
  }
}
