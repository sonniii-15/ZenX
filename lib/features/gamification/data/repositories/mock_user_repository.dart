import '../../domain/repositories/user_repository.dart';
import '../../domain/models/user_profile_state.dart';

class MockUserRepository implements IUserRepository {
  final Map<String, UserProfileState> _mockStorage = {
    'zen_user_1': const UserProfileState(username: 'ZenRunner99'),
  };

  @override
  Future<UserProfileState?> getUserProfile(String userId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockStorage[userId];
  }

  @override
  Future<void> saveUserProfile(String userId, UserProfileState profile) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    _mockStorage[userId] = profile;
  }
}
