import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationServiceException implements Exception {
  final String message;
  LocationServiceException(this.message);

  @override
  String toString() => message;
}

class LocationService {
  /// Checks and requests location permission.
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException('Location services are disabled. Please enable GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw LocationServiceException('Location permission denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw LocationServiceException(
        'Location permission permanently denied. Please enable it in system settings.',
      );
    }

    return true;
  }

  /// Gets current single position.
  Future<Position> getCurrentPosition() async {
    await checkAndRequestPermission();
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  /// Returns a stream of position updates with accuracy and distance filtering.
  Stream<Position> getPositionStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 3, // Update every 3 meters to avoid noise
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Calculates distance in meters between two coordinates.
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Sanitizes GPS updates to filter out unrealistic jumps or poor accuracy points.
  bool isValidPositionUpdate(Position position, Position? previousPosition) {
    // Filter out points with accuracy worse than 35 meters
    if (position.accuracy > 35) {
      return false;
    }

    if (previousPosition != null) {
      final distance = calculateDistance(
        previousPosition.latitude,
        previousPosition.longitude,
        position.latitude,
        position.longitude,
      );

      final timeDiffSeconds = position.timestamp.difference(previousPosition.timestamp).inSeconds;
      if (timeDiffSeconds > 0) {
        final speedMps = distance / timeDiffSeconds;
        // Filter out speed > 40 m/s (~144 km/h) as GPS glitch for walking/running
        if (speedMps > 40) {
          return false;
        }
      }
    }

    return true;
  }
}
