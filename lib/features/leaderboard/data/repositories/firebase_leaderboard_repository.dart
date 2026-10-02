import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../../domain/models/leaderboard_entry.dart';

class FirebaseLeaderboardRepository implements ILeaderboardRepository {
  final FirebaseFirestore _firestore;

  FirebaseLeaderboardRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<LeaderboardEntry>> getLeaderboard(String currentUserId) async {
    final snapshot = await _firestore
        .collection('users')
        .orderBy('totalPoints', descending: true)
        .limit(100)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      String username = data['username'] as String? ?? 'Unknown';
      
      // Sanitize legacy mock usernames for other users in the leaderboard
      if (username.isEmpty || username == 'ZenX User' || username == 'Unknown' || username == 'ZenX') {
        final email = data['email'] as String? ?? '';
        if (email.contains('@')) {
          username = email.split('@').first;
        } else {
          username = 'User';
        }
      }
      
      return LeaderboardEntry(
        username,
        data['totalPoints'] as int? ?? 0,
        isCurrentUser: doc.id == currentUserId,
      );
    }).toList();
  }
}
