import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:latlong2/latlong.dart';
import '../../domain/repositories/social_repository.dart';
import '../../domain/models/social_post.dart';
import '../../domain/models/social_comment.dart';

class FirebaseSocialRepository implements ISocialRepository {
  final FirebaseFirestore _firestore;

  FirebaseSocialRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<void> createPost(SocialPost post) async {
    final docRef = _firestore.collection('posts').doc();
    
    // Upload image to Firebase Storage if a local path is provided
    String? imageUrl = post.activityPhotoLocalPath;
    if (imageUrl != null && imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
      try {
        final file = File(imageUrl);
        if (await file.exists()) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('posts')
              .child(post.userId)
              .child('${docRef.id}_${DateTime.now().millisecondsSinceEpoch}.jpg');
          
          await storageRef.putFile(file);
          imageUrl = await storageRef.getDownloadURL();
        }
      } catch (e) {
        // Fallback to null if upload fails
        imageUrl = null;
      }
    }

    final postToSave = post.copyWith(
      id: docRef.id,
      activityPhotoLocalPath: imageUrl,
    );
    
    final data = _postToFirestore(postToSave);
    await docRef.set(data);
  }

  @override
  Future<List<SocialPost>> getFeed({int limit = 20, DateTime? startAfter}) async {
    Query query = _firestore.collection('posts').orderBy('createdAt', descending: true).limit(limit);
    if (startAfter != null) {
      query = query.startAfter([Timestamp.fromDate(startAfter)]);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => _postFromFirestore(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  @override
  Future<List<SocialPost>> getUserPosts(String userId, {int limit = 20}) async {
    final snapshot = await _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => _postFromFirestore(doc.data(), doc.id)).toList();
  }

  @override
  Future<bool> getLikeState(String postId, String userId) async {
    final doc = await _firestore.collection('posts').doc(postId).collection('likes').doc(userId).get();
    return doc.exists;
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    final batch = _firestore.batch();
    
    final likeRef = _firestore.collection('posts').doc(postId).collection('likes').doc(userId);
    batch.set(likeRef, {'createdAt': FieldValue.serverTimestamp()});
    
    final postRef = _firestore.collection('posts').doc(postId);
    batch.update(postRef, {'likeCount': FieldValue.increment(1)});
    
    await batch.commit();
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    final batch = _firestore.batch();
    
    final likeRef = _firestore.collection('posts').doc(postId).collection('likes').doc(userId);
    batch.delete(likeRef);
    
    final postRef = _firestore.collection('posts').doc(postId);
    batch.update(postRef, {'likeCount': FieldValue.increment(-1)});
    
    await batch.commit();
  }

  @override
  Future<List<SocialComment>> getPostComments(String postId) async {
    final snapshot = await _firestore
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .get();
        
    return snapshot.docs.map((doc) => _commentFromFirestore(doc.data(), doc.id)).toList();
  }

  @override
  Future<void> addComment(String postId, SocialComment comment) async {
    final batch = _firestore.batch();
    
    final commentRef = _firestore.collection('posts').doc(postId).collection('comments').doc();
    batch.set(commentRef, _commentToFirestore(comment.copyWith(id: commentRef.id)));
    
    final postRef = _firestore.collection('posts').doc(postId);
    batch.update(postRef, {'commentCount': FieldValue.increment(1)});
    
    await batch.commit();
  }

  Map<String, dynamic> _postToFirestore(SocialPost post) {
    return {
      'userId': post.userId,
      'username': post.username,
      'profileImageUrl': post.profileImageUrl,
      'avatarLocalPath': post.avatarLocalPath,
      'caption': post.caption,
      'distanceKm': post.distanceKm,
      'durationMs': post.duration.inMilliseconds,
      'points': post.points,
      'capturedCellsCount': post.capturedCellsCount,
      'averageSpeedKmh': post.averageSpeedKmh,
      'estimatedCalories': post.estimatedCalories,
      'activityPhotoLocalPath': post.activityPhotoLocalPath,
      'createdAt': Timestamp.fromDate(post.createdAt),
      'likeCount': post.likeCount,
      'commentCount': post.commentCount,
      'routeCoordinates': post.routeCoordinates.map((c) => {'lat': c.latitude, 'lng': c.longitude}).toList(),
    };
  }

  SocialPost _postFromFirestore(Map<String, dynamic> data, String id) {
    final routeData = data['routeCoordinates'] as List<dynamic>? ?? [];
    final route = routeData.map((c) => LatLng((c['lat'] as num).toDouble(), (c['lng'] as num).toDouble())).toList();

    return SocialPost(
      id: id,
      userId: data['userId'] as String? ?? '',
      username: _sanitizeUsername(data['username'] as String?, null),
      profileImageUrl: data['profileImageUrl'] as String?,
      avatarLocalPath: data['avatarLocalPath'] as String?,
      caption: data['caption'] as String? ?? '',
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0.0,
      duration: Duration(milliseconds: data['durationMs'] as int? ?? 0),
      points: data['points'] as int? ?? 0,
      capturedCellsCount: data['capturedCellsCount'] as int? ?? 0,
      averageSpeedKmh: (data['averageSpeedKmh'] as num?)?.toDouble() ?? 0.0,
      estimatedCalories: (data['estimatedCalories'] as num?)?.toDouble() ?? 0.0,
      activityPhotoLocalPath: data['activityPhotoLocalPath'] as String?,
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
      likeCount: data['likeCount'] as int? ?? 0,
      commentCount: data['commentCount'] as int? ?? 0,
      routeCoordinates: route,
    );
  }

  Map<String, dynamic> _commentToFirestore(SocialComment comment) {
    return {
      'userId': comment.userId,
      'username': comment.username,
      'profileImageUrl': comment.profileImageUrl,
      'text': comment.text,
      'createdAt': Timestamp.fromDate(comment.createdAt),
    };
  }

  SocialComment _commentFromFirestore(Map<String, dynamic> data, String id) {
    return SocialComment(
      id: id,
      userId: data['userId'] as String? ?? '',
      username: _sanitizeUsername(data['username'] as String?, null),
      profileImageUrl: data['profileImageUrl'] as String?,
      text: data['text'] as String? ?? '',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  String _sanitizeUsername(String? username, String? email) {
    if (username == null || username.isEmpty || username == 'ZenX User' || username == 'Unknown' || username == 'ZenX') {
      if (email != null && email.contains('@')) {
        return email.split('@').first;
      }
      return 'User';
    }
    return username;
  }
}
