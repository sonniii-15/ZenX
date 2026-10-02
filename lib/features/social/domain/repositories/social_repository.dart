import '../models/social_post.dart';
import '../models/social_comment.dart';

abstract class ISocialRepository {
  Future<void> createPost(SocialPost post);
  Future<List<SocialPost>> getFeed({int limit = 20, DateTime? startAfter});
  Future<List<SocialPost>> getUserPosts(String userId, {int limit = 20});
  
  Future<bool> getLikeState(String postId, String userId);
  Future<void> likePost(String postId, String userId);
  Future<void> unlikePost(String postId, String userId);
  
  Future<List<SocialComment>> getPostComments(String postId);
  Future<void> addComment(String postId, SocialComment comment);
}
