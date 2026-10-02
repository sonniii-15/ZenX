import '../models/leaderboard_entry.dart';

abstract class ILeaderboardRepository {
  Future<List<LeaderboardEntry>> getLeaderboard(String currentUserId);
}
