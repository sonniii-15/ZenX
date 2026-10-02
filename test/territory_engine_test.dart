import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:zenx/features/territory/domain/engine/territory_engine.dart';
import 'package:zenx/features/territory/domain/models/territory_cell.dart';

void main() {
  group('TerritoryEngine Unit Tests', () {
    late TerritoryEngine engine;

    setUp(() {
      engine = TerritoryEngine(
        cellSize: 20.0,
        minDistanceForCompletion: 50.0,
        loopClosureThreshold: 25.0,
      );
    });

    test('Initial coordinate does NOT yield a cell (no immediate red square)', () {
      const coord = LatLng(37.7749, -122.4194);
      engine.processCoordinate(coord);

      expect(engine.capturedCells.isEmpty, isTrue);
    });

    test('Loop does NOT complete if min distance is not reached', () {
      const coord1 = LatLng(37.774900, -122.419400);
      const coord2 = LatLng(37.774901, -122.419401);
      
      engine.processCoordinate(coord1);
      engine.processCoordinate(coord2);

      expect(engine.isLoopCompleted, isFalse);
      expect(engine.capturedCells.isEmpty, isTrue);
    });

    test('Loop completes successfully with enough distance and returns to start', () {
      // Create a large loop to exceed 50m
      const coordStart = LatLng(37.774900, -122.419400);
      const coordN = LatLng(37.775800, -122.419400); // 100m North
      const coordNE = LatLng(37.775800, -122.418400); // 100m East
      const coordE = LatLng(37.774900, -122.418400); // 100m South
      const coordReturn = LatLng(37.774901, -122.419401); // Back to start

      engine.processCoordinate(coordStart); 
      engine.processCoordinate(coordN);     
      engine.processCoordinate(coordNE);    
      engine.processCoordinate(coordE);     
      
      expect(engine.capturedCells.isEmpty, isTrue);
      expect(engine.isLoopCompleted, isFalse);

      engine.processCoordinate(coordReturn); // Close loop

      expect(engine.isLoopCompleted, isTrue);
      expect(engine.capturedCells.length, 1);
      
      final capturedTerritory = engine.capturedCells.first;
      expect(capturedTerritory.state, TerritoryState.completed);
      expect(capturedTerritory.boundaryPoints.length, 5);
      expect(engine.territoryAreaSqm, greaterThan(1000));
    });

    test('Reset clears all states', () {
      const coord = LatLng(37.774900, -122.419400);
      engine.processCoordinate(coord);
      
      engine.reset();
      
      expect(engine.capturedCells.isEmpty, isTrue);
      expect(engine.isLoopCompleted, isFalse);
      expect(engine.territoryAreaSqm, 0.0);
    });
  });
}
