import 'badge.dart';

class UserProfileState {
  final String username;
  final String? avatarLocalPath;
  final int totalPoints;
  final int currentLevel;
  final List<Badge> earnedBadges;
  final int totalActivities;
  final double totalDistanceKm;
  final double totalCalories;
  final int totalCapturedCells;

  const UserProfileState({
    required this.username,
    this.avatarLocalPath,
    this.totalPoints = 0,
    this.currentLevel = 1,
    this.earnedBadges = const [],
    this.totalActivities = 0,
    this.totalDistanceKm = 0.0,
    this.totalCalories = 0.0,
    this.totalCapturedCells = 0,
  });

  double get progressToNextLevel {
    // Curve: Level N requires N * 500 points total.
    // e.g., Level 1 -> 0 pts, Level 2 -> 500 pts, Level 3 -> 1000 pts
    final currentLevelBase = ((currentLevel - 1) * 500);
    final nextLevelBase = (currentLevel * 500);
    final progress = totalPoints - currentLevelBase;
    final required = nextLevelBase - currentLevelBase;
    return (progress / required).clamp(0.0, 1.0);
  }
  
  int get pointsForNextLevel => currentLevel * 500;

  UserProfileState copyWith({
    String? username,
    String? avatarLocalPath,
    int? totalPoints,
    int? currentLevel,
    List<Badge>? earnedBadges,
    int? totalActivities,
    double? totalDistanceKm,
    double? totalCalories,
    int? totalCapturedCells,
  }) {
    return UserProfileState(
      username: username ?? this.username,
      avatarLocalPath: avatarLocalPath ?? this.avatarLocalPath,
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevel: currentLevel ?? this.currentLevel,
      earnedBadges: earnedBadges ?? this.earnedBadges,
      totalActivities: totalActivities ?? this.totalActivities,
      totalDistanceKm: totalDistanceKm ?? this.totalDistanceKm,
      totalCalories: totalCalories ?? this.totalCalories,
      totalCapturedCells: totalCapturedCells ?? this.totalCapturedCells,
    );
  }
}
