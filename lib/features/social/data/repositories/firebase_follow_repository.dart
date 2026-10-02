import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/follow_repository.dart';

class FirebaseFollowRepository implements IFollowRepository {
  final FirebaseFirestore _firestore;

  FirebaseFollowRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> followUser(String sourceUserId, String targetUserId) async {
    if (sourceUserId == targetUserId) return; // Prevent self-following

    final docRef = _firestore
        .collection('users')
        .doc(sourceUserId)
        .collection('following')
        .doc(targetUserId);
        
    await docRef.set({
      'followedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> unfollowUser(String sourceUserId, String targetUserId) async {
    final docRef = _firestore
        .collection('users')
        .doc(sourceUserId)
        .collection('following')
        .doc(targetUserId);
        
    await docRef.delete();
  }

  @override
  Future<bool> isFollowing(String sourceUserId, String targetUserId) async {
    final doc = await _firestore
        .collection('users')
        .doc(sourceUserId)
        .collection('following')
        .doc(targetUserId)
        .get();
        
    return doc.exists;
  }
}
