import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:zenx/features/gamification/domain/engine/gamification_engine.dart';
import 'package:zenx/features/gamification/domain/models/user_profile_state.dart';
import 'package:zenx/features/tracking/domain/models/tracking_state.dart';
import 'package:zenx/features/territory/domain/models/territory_cell.dart';

void main() {
  group('GamificationEngine Unit Tests', () {
    final engine = GamificationEngine();

    test('Awards correct points for cells and distance', () {
      const startingProfile = UserProfileState(username: 'TestUser');
      
      final cells = [
        const TerritoryCell(id: '1_1', gridX: 1, gridY: 1, center: LatLng(0,0), boundaryPoints: []),
        const TerritoryCell(id: '1_2', gridX: 1, gridY: 2, center: LatLng(0,0), boundaryPoints: []),
      ]; // 2 cells = 20 points

      final activity = TrackingState(
        isTracking: false,
        totalDistanceMeters: 2000.0, // 2km = 10 points
        capturedTerritory: cells,
        isLoopCompleted: false,
      );

      final newProfile = engine.processActivity(activity, startingProfile);

      expect(newProfile.totalPoints, 30); // 20 + 10
      expect(newProfile.totalDistanceKm, 2.0);
      expect(newProfile.totalActivities, 1);
    });

    test('Awards loop completion bonus points', () {
      const startingProfile = UserProfileState(username: 'TestUser');
      
      const activity = TrackingState(
        isTracking: false,
        totalDistanceMeters: 0.0,
        capturedTerritory: [],
        isLoopCompleted: true, // +100 points
      );

      final newProfile = engine.processActivity(activity, startingProfile);

      expect(newProfile.totalPoints, 100);
    });

    test('Calculates level correctly based on 500 point curve', () {
      var profile = const UserProfileState(username: 'TestUser');
      
      // Add 450 points -> Level 1
      profile = profile.copyWith(totalPoints: 450);
      var activity = const TrackingState();
      profile = engine.processActivity(activity, profile);
      expect(profile.currentLevel, 1);

      // Add 50 points -> Level 2
      profile = profile.copyWith(totalPoints: 500);
      profile = engine.processActivity(activity, profile);
      expect(profile.currentLevel, 2);

      // Add 1000 points -> Level 3
      profile = profile.copyWith(totalPoints: 1000);
      profile = engine.processActivity(activity, profile);
      expect(profile.currentLevel, 3);
    });

    test('Awards badges based on thresholds without duplicates', () {
      const startingProfile = UserProfileState(username: 'TestUser');
      
      final cells = List.generate(10, (index) => TerritoryCell(id: 'id_$index', gridX: index, gridY: 0, center: const LatLng(0,0), boundaryPoints: const []));

      final activity = TrackingState(
        isTracking: false,
        totalDistanceMeters: 6000.0, // > 5km
        capturedTerritory: cells, // >= 10 cells
        isLoopCompleted: true,
      );

      final newProfile = engine.processActivity(activity, startingProfile);

      final badgeIds = newProfile.earnedBadges.map((b) => b.id).toList();

      expect(badgeIds.contains('first_territory'), isTrue);
      expect(badgeIds.contains('loop_master'), isTrue);
      expect(badgeIds.contains('distance_explorer'), isTrue);
      expect(badgeIds.contains('cell_hoarder'), isTrue);

      // Process again, should not award duplicates
      final updatedProfile = engine.processActivity(activity, newProfile);
      expect(updatedProfile.earnedBadges.length, 4); // Still 4
    });
  });
}
