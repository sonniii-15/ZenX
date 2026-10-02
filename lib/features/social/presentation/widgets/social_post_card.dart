import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/zenx_colors.dart';
import '../../domain/models/social_post.dart';
import '../providers/social_providers.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'dart:io';
import '../../../../core/widgets/zenx_avatar.dart';

class SocialPostCard extends ConsumerWidget {
  final SocialPost post;
  final bool isPreview;

  const SocialPostCard({super.key, required this.post, this.isPreview = false});

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likeState = ref.watch(likeStateProvider(post.id));
    final isLiked = likeState.valueOrNull ?? false;

    // We optimistically calculate display like count to match optimistic state
    // But since the actual count is in `post`, if it was already liked, we don't add.
    // A more robust app would stream the post doc or maintain a local list state, but this works for MVP.

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: ZenXColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ZenXColors.surfaceHighlight, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            GestureDetector(
              onTap: () {
                context.push('/public-profile/${post.userId}');
              },
              child: Row(
                children: [
                  ZenXAvatar(
                    radius: 20,
                    networkImageUrl: post.profileImageUrl,
                    localImagePath: post.avatarLocalPath,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                        Text(timeago.format(post.createdAt), style: const TextStyle(fontSize: 12, color: ZenXColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            
            // Caption
            if (post.caption.isNotEmpty) ...[
              Text(post.caption, style: const TextStyle(fontSize: 14, color: Colors.white)),
              const SizedBox(height: 12),
            ],

            // Activity Photo (if any)
            if (post.activityPhotoLocalPath != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(post.activityPhotoLocalPath!),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Stats Grid (only if distance > 0)
            if (post.distanceKm > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(Icons.directions_run, '${post.distanceKm.toStringAsFixed(2)} km'),
                        _buildStat(Icons.timer, _formatDuration(post.duration)),
                        _buildStat(Icons.speed, '${post.averageSpeedKmh.toStringAsFixed(1)} km/h'),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat(Icons.local_fire_department, '${post.estimatedCalories.toStringAsFixed(0)} kcal'),
                        _buildStat(Icons.stars, '${post.points} pts'),
                        _buildStat(Icons.grid_on, '${post.capturedCellsCount} cells'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Actions
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? ZenXColors.error : ZenXColors.textSecondary,
                  ),
                  onPressed: likeState.isLoading 
                      ? null 
                      : () => ref.read(likeStateProvider(post.id).notifier).toggleLike(),
                ),
                Text(
                  '${post.likeCount + (isLiked && post.likeCount == 0 ? 1 : 0)}', 
                  style: TextStyle(color: isLiked ? ZenXColors.error : ZenXColors.textSecondary),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: ZenXColors.textSecondary),
                  onPressed: () {
                    if (!isPreview) {
                      context.push('/comments/${post.id}');
                    }
                  },
                ),
                Text(
                  '${post.commentCount}', 
                  style: const TextStyle(color: ZenXColors.textSecondary),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: ZenXColors.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}
