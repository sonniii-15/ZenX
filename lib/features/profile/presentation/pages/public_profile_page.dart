import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/zenx_colors.dart';
import '../../../../core/widgets/zenx_stat_card.dart';
import '../../../gamification/presentation/providers/user_profile_provider.dart';
import '../../../social/presentation/providers/social_providers.dart';
import '../../../social/presentation/widgets/social_post_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final publicProfileProvider = FutureProvider.family<dynamic, String>((ref, userId) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getUserProfile(userId);
});

final userPostsProvider = FutureProvider.family<dynamic, String>((ref, userId) async {
  final repo = ref.watch(socialRepositoryProvider);
  return repo.getUserPosts(userId);
});

class PublicProfilePage extends ConsumerWidget {
  final String userId;

  const PublicProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicProfileProvider(userId));
    final postsAsync = ref.watch(userPostsProvider(userId));
    final followState = ref.watch(followStateProvider(userId));
    final authUser = ref.watch(authStateProvider).valueOrNull;
    final isFollowing = followState.valueOrNull ?? false;
    final isSelf = authUser?.uid == userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('User not found', style: TextStyle(color: ZenXColors.error)));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: AnimateList(
              interval: 100.ms,
              effects: [const FadeEffect(duration: Duration(milliseconds: 300)), const SlideEffect(begin: Offset(0, 0.1), duration: Duration(milliseconds: 300))],
              children: [
                const Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: ZenXColors.surfaceHighlight,
                    child: Icon(Icons.person, size: 50, color: ZenXColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(profile.username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                Center(
                  child: Text('Level ${profile.currentLevel} • ${profile.totalPoints} pts', style: const TextStyle(color: ZenXColors.primary)),
                ),
                
                if (!isSelf) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: followState.isLoading
                          ? null
                          : () => ref.read(followStateProvider(userId).notifier).toggleFollow(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isFollowing ? ZenXColors.surfaceHighlight : ZenXColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: followState.isLoading 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white))
                          : Text(isFollowing ? 'Following' : 'Follow', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
                
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: ZenXStatCard(title: 'Activities', value: '${profile.totalActivities}', icon: Icons.directions_run)),
                    const SizedBox(width: 16),
                    Expanded(child: ZenXStatCard(title: 'Total Km', value: profile.totalDistanceKm.toStringAsFixed(2), icon: Icons.map)),
                  ],
                ),
                
                const SizedBox(height: 32),
                const Text('Recent Activities', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                
                postsAsync.when(
                  data: (posts) {
                    if (posts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text('No public activities yet.', style: TextStyle(color: ZenXColors.textSecondary)),
                        ),
                      );
                    }
                    return Column(
                      children: (posts as List).map((p) => SocialPostCard(post: p)).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator(color: ZenXColors.primary)),
                  error: (err, stack) => Center(child: Text('Error loading posts: $err', style: const TextStyle(color: ZenXColors.error))),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: ZenXColors.primary)),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: ZenXColors.error))),
      ),
    );
  }
}
