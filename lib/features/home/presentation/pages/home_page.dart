import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/zenx_colors.dart';
import '../../../gamification/presentation/providers/user_profile_provider.dart';
import '../../../social/presentation/providers/social_providers.dart';
import '../../../social/domain/models/social_post.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../auth/presentation/providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final feedAsync = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: userProfileAsync.when(
          data: (userProfile) {
            return RefreshIndicator(
              color: ZenXColors.primary,
              onRefresh: () async {
                ref.invalidate(feedProvider);
                await ref.read(feedProvider.future);
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  Animate(
                    effects: const [FadeEffect(duration: Duration(milliseconds: 400)), SlideEffect(begin: Offset(0, 0.1), duration: Duration(milliseconds: 400))],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TOP HEADER
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // LEFT: + Icon
                            Container(
                              decoration: const BoxDecoration(
                                color: ZenXColors.surface,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.add, color: Colors.white),
                                onPressed: () {
                                  // Open post creation flow without causing a Map cast exception
                                  context.push('/create-post');
                                },
                              ),
                            ),
                            
                            // CENTER: Greeting
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    'Hey, ${userProfile.username.split(' ').first} 🔥',
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Ready to conquer today?',
                                    style: TextStyle(fontSize: 12, color: ZenXColors.textSecondary),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            
                            // RIGHT: Notification
                            Column(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    color: ZenXColors.surface,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.notifications_none, color: Colors.white),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'No Notification',
                                  style: TextStyle(fontSize: 10, color: ZenXColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // YOUR STATS
                        const Text('YOUR STATS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: ZenXColors.textSecondary, letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          decoration: BoxDecoration(
                            color: ZenXColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: ZenXColors.surfaceHighlight.withValues(alpha: 0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatItem('${userProfile.totalActivities}', 'Runs', Icons.directions_run),
                              _buildDivider(),
                              _buildStatItem('${userProfile.totalPoints}', 'Points', Icons.local_fire_department),
                              _buildDivider(),
                              _buildStatItem('${userProfile.totalDistanceKm.toStringAsFixed(1)}km', 'Distance', Icons.map),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // RECENT ACTIVITY HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                            TextButton(
                              onPressed: () {},
                              child: const Text('View all', style: TextStyle(color: ZenXColors.primary, fontSize: 14)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  
                  // FEED (INSTAGRAM/STRAVA STYLE)
                  feedAsync.when(
                    data: (posts) {
                      if (posts.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 60.0),
                          child: Center(
                            child: Text('No activities yet.\nComplete a run to start the feed!', 
                              textAlign: TextAlign.center,
                              style: TextStyle(color: ZenXColors.textSecondary, fontSize: 14)
                            ),
                          ),
                        );
                      }
                      
                      return Column(
                        children: posts.map((post) => _buildActivityCard(post)).toList(),
                      );
                    },
                    loading: () => const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(color: ZenXColors.primary),
                    )),
                    error: (err, stack) => const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Error loading feed', style: TextStyle(color: ZenXColors.error)),
                    )),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: ZenXColors.primary)),
          error: (err, stack) => const Center(child: Text('Error loading profile', style: TextStyle(color: ZenXColors.error))),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: ZenXColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: ZenXColors.textSecondary)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: ZenXColors.surfaceHighlight.withValues(alpha: 0.5),
    );
  }
  
  Widget _buildActivityCard(SocialPost post) {
    return SocialPostCard(post: post);
  }
}

class SocialPostCard extends ConsumerStatefulWidget {
  final SocialPost post;

  const SocialPostCard({super.key, required this.post});

  @override
  ConsumerState<SocialPostCard> createState() => _SocialPostCardState();
}

class _SocialPostCardState extends ConsumerState<SocialPostCard> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.post.likeCount;
    _checkLikeState();
  }
  
  Future<void> _checkLikeState() async {
    final userId = ref.read(authStateProvider).valueOrNull?.uid;
    if (userId != null) {
      final repo = ref.read(socialRepositoryProvider);
      final isLiked = await repo.getLikeState(widget.post.id, userId);
      if (mounted) {
        setState(() {
          _isLiked = isLiked;
        });
      }
    }
  }
  
  void _toggleLike() async {
    final userId = ref.read(authStateProvider).valueOrNull?.uid;
    if (userId == null) return;
    
    final repo = ref.read(socialRepositoryProvider);
    
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likeCount -= 1;
      } else {
        _isLiked = true;
        _likeCount += 1;
      }
    });
    
    if (_isLiked) {
      await repo.likePost(widget.post.id, userId);
    } else {
      await repo.unlikePost(widget.post.id, userId);
    }
  }

  Widget _buildPostStatItem(String value, String label, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isHighlight ? ZenXColors.primary : Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: ZenXColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: ZenXColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ZenXColors.surfaceHighlight.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Avatar + Name + Time)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: ZenXColors.surfaceHighlight,
                    image: widget.post.profileImageUrl != null
                        ? DecorationImage(image: NetworkImage(widget.post.profileImageUrl!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: widget.post.profileImageUrl == null
                      ? const Icon(Icons.person, color: ZenXColors.textSecondary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.username,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                      ),
                      Text(
                        timeago.format(widget.post.createdAt),
                        style: const TextStyle(color: ZenXColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: ZenXColors.textSecondary),
                  onPressed: () {},
                ),
              ],
            ),
          ),
          
          // Activity Stats inside the Post
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              widget.post.caption.isNotEmpty ? widget.post.caption : 'Completed an activity!',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          
          // Show photo if available (from Firebase Storage)
          if (widget.post.activityPhotoLocalPath != null && widget.post.activityPhotoLocalPath!.startsWith('http'))
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.post.activityPhotoLocalPath!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),
              ),
            ),
          
          if (widget.post.distanceKm > 0 || widget.post.points > 0)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildPostStatItem('${widget.post.distanceKm.toStringAsFixed(2)} km', 'Distance'),
                  _buildPostStatItem(
                    '${widget.post.duration.inMinutes}m ${widget.post.duration.inSeconds.remainder(60)}s', 
                    'Time'
                  ),
                  _buildPostStatItem('+${widget.post.points}', 'Points', isHighlight: true),
                ],
              ),
            ),

          // Bottom Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border, 
                    color: _isLiked ? ZenXColors.primary : Colors.white
                  ),
                  onPressed: _toggleLike,
                ),
                if (_likeCount > 0)
                  Text('$_likeCount', style: const TextStyle(color: Colors.white70)),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                  onPressed: () {
                    // Navigate to comments (assuming /comments/:postId route exists)
                    // context.push('/comments/${widget.post.id}');
                  },
                ),
                if (widget.post.commentCount > 0)
                  Text('${widget.post.commentCount}', style: const TextStyle(color: Colors.white70)),
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.05, duration: 400.ms);
  }
}
