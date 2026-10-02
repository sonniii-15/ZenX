import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/user_search_repository.dart';
import '../../../gamification/domain/models/user_profile_state.dart';
import '../../../gamification/domain/models/badge.dart' as gamification;
import 'package:flutter/material.dart';

class FirebaseUserSearchRepository implements IUserSearchRepository {
  final FirebaseFirestore _firestore;

  FirebaseUserSearchRepository({FirebaseFirestore? firestore}) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<UserSearchResult>> searchUsers(String query, {int limit = 20}) async {
    if (query.isEmpty) return [];

    // Prefix search approach
    final snapshot = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThan: '${query}z')
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final profile = _fromFirestore(data);
      return UserSearchResult(doc.id, profile);
    }).toList();
  }

  // Copied mapping from FirebaseUserRepository to avoid circular dependency / complex abstraction for MVP
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
      totalPoints: data['totalPoints'] as int? ?? 0,
      currentLevel: data['currentLevel'] as int? ?? 1,
      totalActivities: data['totalActivities'] as int? ?? 0,
      totalDistanceKm: (data['totalDistanceKm'] as num?)?.toDouble() ?? 0.0,
      earnedBadges: badges,
    );
  }
}
