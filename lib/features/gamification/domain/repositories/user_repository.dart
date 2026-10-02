import '../models/user_profile_state.dart';

abstract class IUserRepository {
  Future<UserProfileState?> getUserProfile(String userId);
  Future<void> saveUserProfile(String userId, UserProfileState profile);
}
