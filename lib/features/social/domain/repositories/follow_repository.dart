abstract class IFollowRepository {
  Future<void> followUser(String sourceUserId, String targetUserId);
  Future<void> unfollowUser(String sourceUserId, String targetUserId);
  Future<bool> isFollowing(String sourceUserId, String targetUserId);
}
