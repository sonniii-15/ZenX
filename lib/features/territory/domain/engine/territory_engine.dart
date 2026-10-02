import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import '../models/territory_cell.dart';

class TerritoryEngine {
  final double minDistanceForCompletion; // Minimum distance (meters) walked before a loop can close
  final double loopClosureThreshold; // Distance (meters) to starting point to trigger closure
  final double cellSize; // kept for backwards compatibility with mock generation

  static const double earthRadius = 6378137.0;

  // State Tracking for active session
  final List<LatLng> _route = [];
  final List<TerritoryCell> _capturedCells = [];
  bool _isLoopCompleted = false;
  double _accumulatedDistance = 0.0;
  double _calculatedAreaSqm = 0.0;

  TerritoryEngine({
    this.minDistanceForCompletion = 50.0,
    this.loopClosureThreshold = 25.0,
    this.cellSize = 20.0,
    int minDistinctCellsForCompletion = 5,
  });

  List<TerritoryCell> get capturedCells => List.unmodifiable(_capturedCells);
  bool get isLoopCompleted => _isLoopCompleted;
  double get territoryAreaSqm => _calculatedAreaSqm;

  void processCoordinate(LatLng coord) {
    if (_isLoopCompleted) return; // Freeze territory logic when completed

    if (_route.isEmpty) {
      _route.add(coord);
      return;
    }

    final previous = _route.last;
    final addedDistance = const Distance().as(
      LengthUnit.Meter,
      previous,
      coord,
    );

    // Only add points if they represent actual movement (filter microscopic jitter)
    if (addedDistance < 2.0) return;

    _route.add(coord);
    _accumulatedDistance += addedDistance;

    _checkLoopCompletion(coord);
  }

  void _checkLoopCompletion(LatLng currentCoord) {
    if (_isLoopCompleted) return;
    if (_route.length < 5) return;
    if (_accumulatedDistance < minDistanceForCompletion) return;

    final startCoord = _route.first;
    final distanceToStart = const Distance().as(
      LengthUnit.Meter,
      currentCoord,
      startCoord,
    );

    // If user returns close to the start after walking a sufficient distance
    if (distanceToStart <= loopClosureThreshold) {
      _isLoopCompleted = true;
      _calculateAndCaptureTerritory();
    }
  }

  void _calculateAndCaptureTerritory() {
    // 1. Calculate Area using Shoelace formula on Web Mercator projection
    _calculatedAreaSqm = _calculatePolygonArea(_route);

    // 2. Create the captured territory using the exact path walked
    final territory = TerritoryCell(
      id: 'captured_loop_${DateTime.now().millisecondsSinceEpoch}',
      gridX: 0,
      gridY: 0,
      center: _calculateCenter(_route),
      boundaryPoints: List<LatLng>.from(_route), // The exact shape walked
      state: TerritoryState.completed,
    );

    _capturedCells.add(territory);
  }

  double _calculatePolygonArea(List<LatLng> points) {
    if (points.length < 3) return 0.0;
    
    final projectedPoints = points.map((p) => _projectToWebMercator(p)).toList();
    double area = 0.0;
    
    int j = projectedPoints.length - 1;
    for (int i = 0; i < projectedPoints.length; i++) {
      area += (projectedPoints[j].x + projectedPoints[i].x) * (projectedPoints[j].y - projectedPoints[i].y);
      j = i;
    }
    
    return (area / 2.0).abs();
  }

  LatLng _calculateCenter(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(0, 0);
    double latSum = 0;
    double lngSum = 0;
    for (var p in points) {
      latSum += p.latitude;
      lngSum += p.longitude;
    }
    return LatLng(latSum / points.length, lngSum / points.length);
  }

  void reset() {
    _route.clear();
    _capturedCells.clear();
    _isLoopCompleted = false;
    _accumulatedDistance = 0.0;
    _calculatedAreaSqm = 0.0;
  }

  // --- Map Projection Utilities ---

  math.Point<double> _projectToWebMercator(LatLng coord) {
    final lonRad = coord.longitudeInRad;
    final clampedLat = math.max(-89.5, math.min(89.5, coord.latitude));
    final clampedLatRad = clampedLat * math.pi / 180.0;
    
    final x = earthRadius * lonRad;
    final y = earthRadius * math.log(math.tan(math.pi / 4.0 + clampedLatRad / 2.0));
    return math.Point<double>(x, y);
  }
}
