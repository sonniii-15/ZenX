import 'package:flutter_test/flutter_test.dart';
import 'package:zenx/features/social/domain/models/social_post.dart';
import 'package:zenx/features/social/domain/models/social_comment.dart';

void main() {
  group('Social Models', () {
    test('SocialPost copyWith works correctly', () {
      final post = SocialPost(
        id: 'post1',
        userId: 'user1',
        username: 'TestUser',
        caption: 'First run',
        distanceKm: 5.0,
        duration: const Duration(minutes: 30),
        points: 100,
        capturedCellsCount: 10,
        createdAt: DateTime(2023),
      );

      final updated = post.copyWith(
        likeCount: 5,
        commentCount: 2,
        caption: 'Updated run',
      );

      expect(updated.id, 'post1');
      expect(updated.likeCount, 5);
      expect(updated.commentCount, 2);
      expect(updated.caption, 'Updated run');
      expect(updated.distanceKm, 5.0);
    });

    test('SocialPost equality', () {
      final post1 = SocialPost(
        id: 'post1',
        userId: 'user1',
        username: 'TestUser',
        caption: 'First run',
        distanceKm: 5.0,
        duration: const Duration(minutes: 30),
        points: 100,
        capturedCellsCount: 10,
        createdAt: DateTime(2023),
      );

      final post2 = SocialPost(
        id: 'post1', // Same ID
        userId: 'user2', // Different other fields
        username: 'Other',
        caption: '',
        distanceKm: 0.0,
        duration: Duration.zero,
        points: 0,
        capturedCellsCount: 0,
        createdAt: DateTime.now(),
      );

      expect(post1, equals(post2));
    });

    test('SocialComment equality', () {
      final comment1 = SocialComment(
        id: 'c1',
        userId: 'u1',
        username: 'User',
        text: 'Hello',
        createdAt: DateTime(2023),
      );

      final comment2 = SocialComment(
        id: 'c1',
        userId: 'u2',
        username: 'Other',
        text: 'Bye',
        createdAt: DateTime.now(),
      );

      expect(comment1, equals(comment2));
    });

    test('SocialComment copyWith', () {
      final comment = SocialComment(
        id: 'c1',
        userId: 'u1',
        username: 'User',
        text: 'Hello',
        createdAt: DateTime(2023),
      );

      final updated = comment.copyWith(text: 'Updated text');
      expect(updated.id, 'c1');
      expect(updated.text, 'Updated text');
    });
  });
}
