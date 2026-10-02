import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/social_repository.dart';
import '../../data/repositories/firebase_social_repository.dart';
import '../../domain/repositories/follow_repository.dart';
import '../../data/repositories/firebase_follow_repository.dart';
import '../../domain/repositories/user_search_repository.dart';
import '../../data/repositories/firebase_user_search_repository.dart';
import '../../domain/models/social_post.dart';
import '../../domain/models/social_comment.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// Repositories
final socialRepositoryProvider = Provider<ISocialRepository>((ref) {
  return FirebaseSocialRepository();
});

final followRepositoryProvider = Provider<IFollowRepository>((ref) {
  return FirebaseFollowRepository();
});

final userSearchRepositoryProvider = Provider<IUserSearchRepository>((ref) {
  return FirebaseUserSearchRepository();
});

// Feed Provider
final feedProvider = FutureProvider<List<SocialPost>>((ref) async {
  final repo = ref.watch(socialRepositoryProvider);
  return repo.getFeed(limit: 50);
});

// Like State Provider Family
final likeStateProvider = StateNotifierProvider.family<LikeStateNotifier, AsyncValue<bool>, String>((ref, postId) {
  final authUser = ref.watch(authStateProvider).valueOrNull;
  final repo = ref.watch(socialRepositoryProvider);
  return LikeStateNotifier(repo, authUser?.uid, postId);
});

class LikeStateNotifier extends StateNotifier<AsyncValue<bool>> {
  final ISocialRepository _repo;
  final String? _userId;
  final String _postId;

  LikeStateNotifier(this._repo, this._userId, this._postId) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    if (_userId == null) {
      state = const AsyncValue.data(false);
      return;
    }
    try {
      final isLiked = await _repo.getLikeState(_postId, _userId);
      state = AsyncValue.data(isLiked);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleLike() async {
    if (_userId == null) return;
    
    final current = state.valueOrNull ?? false;
    
    // Optimistic update
    state = AsyncValue.data(!current);
    
    try {
      if (current) {
        await _repo.unlikePost(_postId, _userId);
      } else {
        await _repo.likePost(_postId, _userId);
      }
    } catch (e) {
      // Revert on failure
      state = AsyncValue.data(current);
    }
  }
}

// Comments Provider Family
final postCommentsProvider = FutureProvider.family<List<SocialComment>, String>((ref, postId) async {
  final repo = ref.watch(socialRepositoryProvider);
  return repo.getPostComments(postId);
});

// Follow State Provider Family
final followStateProvider = StateNotifierProvider.family<FollowStateNotifier, AsyncValue<bool>, String>((ref, targetUserId) {
  final authUser = ref.watch(authStateProvider).valueOrNull;
  final repo = ref.watch(followRepositoryProvider);
  return FollowStateNotifier(repo, authUser?.uid, targetUserId);
});

class FollowStateNotifier extends StateNotifier<AsyncValue<bool>> {
  final IFollowRepository _repo;
  final String? _sourceUserId;
  final String _targetUserId;

  FollowStateNotifier(this._repo, this._sourceUserId, this._targetUserId) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    if (_sourceUserId == null || _sourceUserId == _targetUserId) {
      state = const AsyncValue.data(false);
      return;
    }
    try {
      final isFollowing = await _repo.isFollowing(_sourceUserId, _targetUserId);
      state = AsyncValue.data(isFollowing);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleFollow() async {
    if (_sourceUserId == null || _sourceUserId == _targetUserId) return;
    
    final current = state.valueOrNull ?? false;
    
    // Optimistic update
    state = AsyncValue.data(!current);
    
    try {
      if (current) {
        await _repo.unfollowUser(_sourceUserId, _targetUserId);
      } else {
        await _repo.followUser(_sourceUserId, _targetUserId);
      }
    } catch (e) {
      // Revert on failure
      state = AsyncValue.data(current);
    }
  }
}
