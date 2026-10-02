import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/leaderboard_repository.dart';
import '../../data/repositories/firebase_leaderboard_repository.dart';
import '../../domain/models/leaderboard_entry.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final leaderboardRepositoryProvider = Provider<ILeaderboardRepository>((ref) {
  return FirebaseLeaderboardRepository();
});

final leaderboardProvider = FutureProvider<List<LeaderboardEntry>>((ref) async {
  final authState = ref.watch(authStateProvider);
  final user = authState.valueOrNull;
  if (user == null) {
    throw Exception('User not authenticated');
  }

  final repo = ref.watch(leaderboardRepositoryProvider);
  return repo.getLeaderboard(user.uid);
});
