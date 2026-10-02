import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/zenx_colors.dart';
import '../providers/social_providers.dart';
import '../../domain/models/social_comment.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/widgets/zenx_avatar.dart';

class CommentsPage extends ConsumerStatefulWidget {
  final String postId;

  const CommentsPage({super.key, required this.postId});

  @override
  ConsumerState<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends ConsumerState<CommentsPage> {
  final _commentController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final user = ref.read(authStateProvider).valueOrNull;
      if (user == null) throw Exception('Not authenticated');

      final comment = SocialComment(
        id: '', // Will be set by Firestore
        userId: user.uid,
        username: user.displayName ?? 'Unknown',
        profileImageUrl: user.photoURL,
        text: text,
        createdAt: DateTime.now(),
      );

      await ref.read(socialRepositoryProvider).addComment(widget.postId, comment);
      _commentController.clear();
      
      // Refresh comments
      ref.invalidate(postCommentsProvider(widget.postId));
      await ref.read(postCommentsProvider(widget.postId).future);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: ZenXColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(postCommentsProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: commentsAsync.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return const Center(
                    child: Text('No comments yet. Be the first!', style: TextStyle(color: ZenXColors.textSecondary)),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ZenXAvatar(
                            radius: 16,
                            networkImageUrl: comment.profileImageUrl,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(comment.username, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                    const SizedBox(width: 8),
                                    Text(timeago.format(comment.createdAt), style: const TextStyle(fontSize: 12, color: ZenXColors.textSecondary)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(comment.text, style: const TextStyle(color: Colors.white)),
                              ],
                            ),
                          )
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: ZenXColors.primary)),
              error: (err, stack) => const Center(child: Text('Error loading comments', style: TextStyle(color: ZenXColors.error))),
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: ZenXColors.surface,
                border: Border(top: BorderSide(color: ZenXColors.surfaceHighlight)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: const TextStyle(color: ZenXColors.textSecondary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.3),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      style: const TextStyle(color: Colors.white),
                      enabled: !_isSubmitting,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _isSubmitting
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: ZenXColors.primary, strokeWidth: 2)),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: ZenXColors.primary),
                          onPressed: _submitComment,
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
