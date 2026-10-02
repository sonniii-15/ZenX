import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../domain/models/user_profile_state.dart';
import '../../domain/models/badge.dart' as gamification;
import '../../domain/repositories/user_repository.dart';

class FirebaseUserRepository implements IUserRepository {
  final FirebaseFirestore _firestore;

  FirebaseUserRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserProfileState?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    return _fromFirestore(data);
  }

  @override
  Future<void> saveUserProfile(String userId, UserProfileState profile) async {
    await _firestore.collection('users').doc(userId).set(_toFirestore(profile), SetOptions(merge: true));
  }

  Map<String, dynamic> _toFirestore(UserProfileState profile) {
    return {
      'username': profile.username,
      'avatarLocalPath': profile.avatarLocalPath,
      'totalPoints': profile.totalPoints,
      'currentLevel': profile.currentLevel,
      'totalActivities': profile.totalActivities,
      'totalDistanceKm': profile.totalDistanceKm,
      'totalCalories': profile.totalCalories,
      'totalCapturedCells': profile.totalCapturedCells,
      'earnedBadges': profile.earnedBadges.map((b) => {
        'id': b.id,
        'title': b.title,
        'description': b.description,
        'iconDataCodePoint': b.iconData.codePoint,
        'iconDataFontFamily': b.iconData.fontFamily,
        'dateEarned': Timestamp.fromDate(b.dateEarned),
      }).toList(),
    };
  }

  UserProfileState _fromFirestore(Map<String, dynamic> data) {
    final badgesData = data['earnedBadges'] as List<dynamic>? ?? [];
    final badges = badgesData.map((b) {
      final bMap = b as Map<String, dynamic>;
      return gamification.Badge(
        id: bMap['id'] as String,
        title: bMap['title'] as String,
        description: bMap['description'] as String,
        iconData: IconData(
          bMap['iconDataCodePoint'] as int,
          fontFamily: bMap['iconDataFontFamily'] as String?,
        ),
        dateEarned: (bMap['dateEarned'] as Timestamp).toDate(),
      );
    }).toList();

    String username = data['username'] as String? ?? '';
    if (username.isEmpty) {
      final email = data['email'] as String? ?? '';
      if (email.contains('@')) {
        username = email.split('@').first;
      } else {
        username = 'User';
      }
    }

    return UserProfileState(
      username: username,
      avatarLocalPath: data['avatarLocalPath'] as String?,
      totalPoints: data['totalPoints'] as int? ?? 0,
      currentLevel: data['currentLevel'] as int? ?? 1,
      totalActivities: data['totalActivities'] as int? ?? 0,
      totalDistanceKm: (data['totalDistanceKm'] as num?)?.toDouble() ?? 0.0,
      totalCalories: (data['totalCalories'] as num?)?.toDouble() ?? 0.0,
      totalCapturedCells: data['totalCapturedCells'] as int? ?? 0,
      earnedBadges: badges,
    );
  }
}
