import 'package:flutter/material.dart';
import '../../../tracking/domain/models/tracking_state.dart';
import '../models/badge.dart' as gamification_badge;
import '../models/user_profile_state.dart';

class GamificationEngine {
  static const int pointsPerCell = 10;
  static const int pointsPerKm = 5;
  static const int pointsForLoop = 100;

  UserProfileState processActivity(TrackingState activity, UserProfileState currentUser) {
    // 1. Calculate Points
    int earnedPoints = 0;
    earnedPoints += activity.capturedTerritory.length * pointsPerCell;
    earnedPoints += (activity.distanceInKm * pointsPerKm).toInt();
    
    if (activity.isLoopCompleted) {
      earnedPoints += pointsForLoop;
    }

    final newTotalPoints = currentUser.totalPoints + earnedPoints;

    // 2. Calculate Level
    // Level N requires (N - 1) * 500 points
    int newLevel = 1;
    while (newTotalPoints >= (newLevel * 500)) {
      newLevel++;
    }

    // 3. Evaluate Badges
    final List<gamification_badge.Badge> newBadges = [];
    final currentBadgeIds = currentUser.earnedBadges.map((b) => b.id).toSet();

    if (activity.capturedTerritory.isNotEmpty && !currentBadgeIds.contains('first_territory')) {
      newBadges.add(gamification_badge.Badge(
        id: 'first_territory',
        title: 'First Territory',
        description: 'Captured your first territory cell.',
        iconData: Icons.flag,
        dateEarned: DateTime.now(),
      ));
    }

    if (activity.isLoopCompleted && !currentBadgeIds.contains('loop_master')) {
      newBadges.add(gamification_badge.Badge(
        id: 'loop_master',
        title: 'Loop Master',
        description: 'Completed a full territory loop.',
        iconData: Icons.all_inclusive,
        dateEarned: DateTime.now(),
      ));
    }

    if (activity.distanceInKm >= 5.0 && !currentBadgeIds.contains('distance_explorer')) {
      newBadges.add(gamification_badge.Badge(
        id: 'distance_explorer',
        title: 'Distance Explorer',
        description: 'Traveled over 5km in one session.',
        iconData: Icons.directions_run,
        dateEarned: DateTime.now(),
      ));
    }

    if (activity.capturedTerritory.length >= 10 && !currentBadgeIds.contains('cell_hoarder')) {
      newBadges.add(gamification_badge.Badge(
        id: 'cell_hoarder',
        title: 'Cell Hoarder',
        description: 'Captured 10 or more cells in one session.',
        iconData: Icons.grid_on,
        dateEarned: DateTime.now(),
      ));
    }

    final allBadges = List<gamification_badge.Badge>.from(currentUser.earnedBadges)..addAll(newBadges);

    return currentUser.copyWith(
      totalPoints: newTotalPoints,
      currentLevel: newLevel,
      earnedBadges: allBadges,
      totalActivities: currentUser.totalActivities + 1,
      totalDistanceKm: currentUser.totalDistanceKm + activity.distanceInKm,
      totalCalories: currentUser.totalCalories + activity.estimatedCalories,
      totalCapturedCells: currentUser.totalCapturedCells + activity.capturedTerritory.length,
    );
  }
}
