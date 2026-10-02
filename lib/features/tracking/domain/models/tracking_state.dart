import 'package:latlong2/latlong.dart';
import '../../../territory/domain/models/territory_cell.dart';

class TrackingState {
  final bool isTracking;
  final Duration elapsedDuration;
  final LatLng? currentLocation;
  final List<LatLng> routeCoordinates;
  final double totalDistanceMeters;
  final double gpsAccuracy;
  final DateTime? startTime;
  final DateTime? endTime;
  final String? errorMessage;
  final String activityType;
  
  // Territory additions
  final List<TerritoryCell> capturedTerritory;
  final List<TerritoryCell> mockTerritory;
  final bool isLoopCompleted;
  final double territoryAreaSqm;

  // Fitness Stats additions
  final double currentSpeedMps;

  const TrackingState({
    this.isTracking = false,
    this.elapsedDuration = Duration.zero,
    this.currentLocation,
    this.routeCoordinates = const [],
    this.totalDistanceMeters = 0.0,
    this.gpsAccuracy = 0.0,
    this.startTime,
    this.endTime,
    this.errorMessage,
    this.activityType = 'Running',
    this.capturedTerritory = const [],
    this.mockTerritory = const [],
    this.isLoopCompleted = false,
    this.territoryAreaSqm = 0.0,
    this.currentSpeedMps = 0.0,
  });

  double get distanceInKm => totalDistanceMeters / 1000.0;
  double get territoryAreaSqKm => territoryAreaSqm / 1000000.0;
  int get gpsPointCount => routeCoordinates.length;

  double get averageSpeedKmh {
    if (elapsedDuration.inSeconds == 0) return 0.0;
    return (totalDistanceMeters / elapsedDuration.inSeconds) * 3.6;
  }

  double get currentSpeedKmh => currentSpeedMps * 3.6;

  // Basic estimation: distance in km * mock weight (70kg) * 1.036
  double get estimatedCalories => distanceInKm * 70.0 * 1.036;

  TrackingState copyWith({
    bool? isTracking,
    Duration? elapsedDuration,
    LatLng? currentLocation,
    List<LatLng>? routeCoordinates,
    double? totalDistanceMeters,
    double? gpsAccuracy,
    DateTime? startTime,
    DateTime? endTime,
    String? errorMessage,
    bool clearError = false,
    String? activityType,
    List<TerritoryCell>? capturedTerritory,
    List<TerritoryCell>? mockTerritory,
    bool? isLoopCompleted,
    double? territoryAreaSqm,
    double? currentSpeedMps,
  }) {
    return TrackingState(
      isTracking: isTracking ?? this.isTracking,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      currentLocation: currentLocation ?? this.currentLocation,
      routeCoordinates: routeCoordinates ?? this.routeCoordinates,
      totalDistanceMeters: totalDistanceMeters ?? this.totalDistanceMeters,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      activityType: activityType ?? this.activityType,
      capturedTerritory: capturedTerritory ?? this.capturedTerritory,
      mockTerritory: mockTerritory ?? this.mockTerritory,
      isLoopCompleted: isLoopCompleted ?? this.isLoopCompleted,
      territoryAreaSqm: territoryAreaSqm ?? this.territoryAreaSqm,
      currentSpeedMps: currentSpeedMps ?? this.currentSpeedMps,
    );
  }
}
