import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../data/services/location_service.dart';
import '../../domain/models/tracking_state.dart';
import '../../../../features/territory/domain/engine/territory_engine.dart';
import '../../../../features/territory/domain/models/territory_cell.dart';
import '../../domain/repositories/activity_repository.dart';
import '../../data/repositories/firebase_activity_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/activity_preference_provider.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final territoryEngineProvider = Provider<TerritoryEngine>((ref) {
  return TerritoryEngine(
    cellSize: 20.0,
    minDistinctCellsForCompletion: 5,
    minDistanceForCompletion: 100.0,
  );
});

final activityRepositoryProvider = Provider<IActivityRepository>((ref) {
  return FirebaseActivityRepository();
});

final trackingProvider = StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  final locationService = ref.watch(locationServiceProvider);
  final territoryEngine = ref.watch(territoryEngineProvider);
  final activityRepo = ref.watch(activityRepositoryProvider);
  final authState = ref.watch(authStateProvider).valueOrNull;
  final activityPreference = ref.watch(activityPreferenceProvider);
  
  return TrackingNotifier(locationService, territoryEngine, activityRepo, authState?.uid, activityPreference);
});

class TrackingNotifier extends StateNotifier<TrackingState> {
  final LocationService _locationService;
  final TerritoryEngine _territoryEngine;
  final IActivityRepository _activityRepository;
  final String? _userId;
  final String _activityType;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _timer;
  Position? _previousPosition;

  TrackingNotifier(this._locationService, this._territoryEngine, this._activityRepository, this._userId, this._activityType) : super(TrackingState(activityType: _activityType)) {
    initInitialLocation();
  }

  Future<void> initInitialLocation() async {
    try {
      final pos = await _locationService.getCurrentPosition();
      final latLng = LatLng(pos.latitude, pos.longitude);
      
      // Generate some mock rival and safe territories nearby for visual demonstration
      final mockCells = <TerritoryCell>[];
      final baseSize = _territoryEngine.cellSize / 111320.0; // rough km to lat conversion
      
      // 1. A cluster of rival cells slightly north
      for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
          final cLat = latLng.latitude + 0.003 + (i * baseSize);
          final cLng = latLng.longitude + 0.001 + (j * baseSize);
          mockCells.add(_createMockCell(cLat, cLng, 'rival_${i}_$j', TerritoryState.rival, baseSize));
        }
      }
      
      // 2. A safe zone slightly south-west
      for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
          final cLat = latLng.latitude - 0.002 - (i * baseSize);
          final cLng = latLng.longitude - 0.002 - (j * baseSize);
          mockCells.add(_createMockCell(cLat, cLng, 'safe_${i}_$j', TerritoryState.safe, baseSize));
        }
      }

      state = state.copyWith(
        currentLocation: latLng, 
        gpsAccuracy: pos.accuracy,
        mockTerritory: mockCells,
      );
    } catch (_) {}
  }
  
  TerritoryCell _createMockCell(double lat, double lng, String id, TerritoryState state, double size) {
    return TerritoryCell(
      id: id,
      gridX: 0,
      gridY: 0,
      center: LatLng(lat, lng),
      state: state,
      boundaryPoints: [
        LatLng(lat - size/2, lng - size/2),
        LatLng(lat + size/2, lng - size/2),
        LatLng(lat + size/2, lng + size/2),
        LatLng(lat - size/2, lng + size/2),
      ],
    );
  }

  Future<bool> startTracking() async {
    if (state.isTracking) return false;

    try {
      state = state.copyWith(clearError: true);
      await _locationService.checkAndRequestPermission();
      
      final initialPosition = await _locationService.getCurrentPosition();
      final initialLatLng = LatLng(initialPosition.latitude, initialPosition.longitude);

      _previousPosition = initialPosition;
      _territoryEngine.reset();
      _territoryEngine.processCoordinate(initialLatLng);

      state = TrackingState(
        isTracking: true,
        startTime: DateTime.now(),
        currentLocation: initialLatLng,
        routeCoordinates: [initialLatLng],
        totalDistanceMeters: 0.0,
        gpsAccuracy: initialPosition.accuracy,
        activityType: _activityType,
        capturedTerritory: _territoryEngine.capturedCells,
        isLoopCompleted: _territoryEngine.isLoopCompleted,
        territoryAreaSqm: _territoryEngine.territoryAreaSqm,
      );

      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        state = state.copyWith(
          elapsedDuration: Duration(seconds: state.elapsedDuration.inSeconds + 1),
        );
      });

      _positionSubscription?.cancel();
      _positionSubscription = _locationService.getPositionStream().listen(
        (position) {
          _handlePositionUpdate(position);
        },
        onError: (error) {
          state = state.copyWith(errorMessage: error.toString());
        },
      );

      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString(), isTracking: false);
      return false;
    }
  }

  void _handlePositionUpdate(Position position) {
    if (!state.isTracking) return;

    if (!_locationService.isValidPositionUpdate(position, _previousPosition)) {
      return;
    }

    final newLatLng = LatLng(position.latitude, position.longitude);
    
    double addedDistance = 0.0;
    double currentSpeed = position.speed;

    if (_previousPosition != null) {
      addedDistance = _locationService.calculateDistance(
        _previousPosition!.latitude,
        _previousPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      
      // Fallback manual speed calculation if OS doesn't provide speed (e.g. -1.0)
      if (currentSpeed < 0) {
        final timeDiffSeconds = position.timestamp.difference(_previousPosition!.timestamp).inSeconds;
        if (timeDiffSeconds > 0) {
          currentSpeed = addedDistance / timeDiffSeconds;
        } else {
          currentSpeed = 0.0;
        }
      }
    } else {
      if (currentSpeed < 0) currentSpeed = 0.0;
    }

    // Stationary filtering (1.0 km/h is approx 0.28 m/s)
    // Ignore tiny jumps if speed is very low
    if (currentSpeed <= 0.28 && _previousPosition != null) {
      // Update current location for the UI dot, but do not record route/distance/territory
      state = state.copyWith(
        currentLocation: newLatLng,
        gpsAccuracy: position.accuracy,
        currentSpeedMps: currentSpeed,
      );
      return;
    }

    _previousPosition = position;
    _territoryEngine.processCoordinate(newLatLng);

    final updatedRoute = List<LatLng>.from(state.routeCoordinates)..add(newLatLng);
    
    state = state.copyWith(
      currentLocation: newLatLng,
      routeCoordinates: updatedRoute,
      totalDistanceMeters: state.totalDistanceMeters + addedDistance,
      gpsAccuracy: position.accuracy,
      capturedTerritory: _territoryEngine.capturedCells,
      isLoopCompleted: _territoryEngine.isLoopCompleted,
      territoryAreaSqm: _territoryEngine.territoryAreaSqm,
      currentSpeedMps: currentSpeed,
    );
  }

  void stopTracking() {
    if (!state.isTracking) return;

    _positionSubscription?.cancel();
    _positionSubscription = null;
    _timer?.cancel();
    _timer = null;

    state = state.copyWith(
      isTracking: false,
      endTime: DateTime.now(),
    );

    // Save to backend if authenticated
    if (_userId != null) {
      _activityRepository.saveActivity(_userId, state);
    }
  }

  void resetTracking() {
    stopTracking();
    _territoryEngine.reset();
    state = TrackingState(activityType: _activityType);
    initInitialLocation();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }
}
