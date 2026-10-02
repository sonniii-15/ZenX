import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/repositories/activity_repository.dart';
import '../../domain/models/tracking_state.dart';

class FirebaseActivityRepository implements IActivityRepository {
  final FirebaseFirestore _firestore;

  FirebaseActivityRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> saveActivity(String userId, TrackingState activity) async {
    final batch = _firestore.batch();
    
    // 1. Save Activity
    final activityDoc = _firestore.collection('activities').doc();
    final data = _toFirestore(userId, activity, activityDoc.id);
    batch.set(activityDoc, data);

    // 2. Save Territories separately if captured
    if (activity.capturedTerritory.isNotEmpty) {
      for (final cell in activity.capturedTerritory) {
        final territoryDoc = _firestore.collection('territories').doc(cell.id);
        batch.set(territoryDoc, {
          'territoryId': cell.id,
          'ownerId': userId,
          'activityId': activityDoc.id,
          'capturedAt': FieldValue.serverTimestamp(),
          'boundaryCoordinates': cell.boundaryPoints.map((bp) => {'lat': bp.latitude, 'lng': bp.longitude}).toList(),
          'area': activity.territoryAreaSqm,
          'status': 'captured',
        });
      }
    }
    
    await batch.commit();
  }

  @override
  Future<List<TrackingState>> getActivities(String userId) async {
    final snapshot = await _firestore
        .collection('activities')
        .where('userId', isEqualTo: userId)
        .orderBy('completedAt', descending: true)
        .get();

    return snapshot.docs.map((doc) => _fromFirestore(doc.data())).toList();
  }

  Map<String, dynamic> _toFirestore(String userId, TrackingState state, String activityId) {
    return {
      'activityId': activityId,
      'userId': userId,
      'activityType': state.activityType,
      'startedAt': state.startTime != null ? Timestamp.fromDate(state.startTime!) : null,
      'completedAt': state.endTime != null ? Timestamp.fromDate(state.endTime!) : FieldValue.serverTimestamp(),
      'duration': state.elapsedDuration.inMilliseconds,
      'distanceKm': state.distanceInKm,
      'pace': state.averageSpeedKmh, // using speed kmh as pace for now
      'calories': state.estimatedCalories,
      'routePoints': state.routeCoordinates.map((c) => {'lat': c.latitude, 'lng': c.longitude}).toList(),
      'territoryCaptured': state.capturedTerritory.length,
      'territoryId': state.capturedTerritory.isNotEmpty ? state.capturedTerritory.first.id : null,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  TrackingState _fromFirestore(Map<String, dynamic> data) {
    final routeData = data['routePoints'] as List<dynamic>? ?? [];
    final route = routeData.map((c) => LatLng(c['lat'] as double, c['lng'] as double)).toList();

    return TrackingState(
      activityType: data['activityType'] as String? ?? 'Running',
      isTracking: false,
      elapsedDuration: Duration(milliseconds: data['duration'] as int? ?? 0),
      routeCoordinates: route,
      totalDistanceMeters: (data['distanceKm'] as num? ?? 0.0).toDouble() * 1000.0,
      startTime: data['startedAt'] != null ? (data['startedAt'] as Timestamp).toDate() : null,
      endTime: data['completedAt'] != null ? (data['completedAt'] as Timestamp).toDate() : null,
    );
  }
}
