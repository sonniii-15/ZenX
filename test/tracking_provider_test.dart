import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:zenx/features/tracking/domain/models/tracking_state.dart';
import 'package:zenx/features/tracking/data/services/location_service.dart';

void main() {
  group('TrackingState Unit Tests', () {
    test('Initial tracking state values are default', () {
      const state = TrackingState();
      expect(state.isTracking, isFalse);
      expect(state.elapsedDuration, Duration.zero);
      expect(state.currentLocation, isNull);
      expect(state.routeCoordinates, isEmpty);
      expect(state.totalDistanceMeters, 0.0);
      expect(state.distanceInKm, 0.0);
      expect(state.gpsPointCount, 0);
    });

    test('TrackingState copyWith updates fields correctly', () {
      const state = TrackingState();
      final updated = state.copyWith(
        isTracking: true,
        totalDistanceMeters: 2500.0,
        currentLocation: const LatLng(37.7749, -122.4194),
        routeCoordinates: [const LatLng(37.7749, -122.4194)],
      );

      expect(updated.isTracking, isTrue);
      expect(updated.totalDistanceMeters, 2500.0);
      expect(updated.distanceInKm, 2.5);
      expect(updated.gpsPointCount, 1);
      expect(updated.currentLocation, const LatLng(37.7749, -122.4194));
    });
  });

  group('LocationService Validation Unit Tests', () {
    final locationService = LocationService();

    test('calculateDistance returns correct distance between two known points', () {
      // Distance between San Francisco and Oakland (~13 km)
      final distance = locationService.calculateDistance(37.7749, -122.4194, 37.8044, -122.2712);
      expect(distance, greaterThan(10000));
      expect(distance, lessThan(16000));
    });
  });
}
