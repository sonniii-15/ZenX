class LeaderboardEntry {
  final String username;
  final int points;
  final bool isCurrentUser;

  LeaderboardEntry(this.username, this.points, {this.isCurrentUser = false});
}
