import '../../domain/repositories/activity_repository.dart';
import '../../domain/models/tracking_state.dart';

class MockActivityRepository implements IActivityRepository {
  final List<TrackingState> _mockStorage = [];

  @override
  Future<void> saveActivity(String userId, TrackingState activity) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockStorage.add(activity);
  }

  @override
  Future<List<TrackingState>> getActivities(String userId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_mockStorage);
  }
}
