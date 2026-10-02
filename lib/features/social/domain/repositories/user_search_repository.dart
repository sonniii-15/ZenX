import '../../../gamification/domain/models/user_profile_state.dart';

class UserSearchResult {
  final String userId;
  final UserProfileState profile;

  UserSearchResult(this.userId, this.profile);
}

abstract class IUserSearchRepository {
  Future<List<UserSearchResult>> searchUsers(String query, {int limit = 20});
}
