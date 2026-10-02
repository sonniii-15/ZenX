import '../../../tracking/domain/models/tracking_state.dart';

abstract class IActivityRepository {
  Future<void> saveActivity(String userId, TrackingState activity);
  Future<List<TrackingState>> getActivities(String userId);
}
