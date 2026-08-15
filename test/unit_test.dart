import 'package:flutter_test/flutter_test.dart';
import 'package:bhagwa/core/utils/number_formatter.dart';
import 'package:bhagwa/core/utils/share_helper.dart';
import 'package:bhagwa/data/repositories/mock_content_repository.dart';

void main() {
  group('NumberFormatter Tests', () {
    test('formatCount formats thousands correctly', () {
      expect(NumberFormatter.formatCount(1200), '1.2K');
      expect(NumberFormatter.formatCount(4800), '4.8K');
      expect(NumberFormatter.formatCount(12000), '12K');
    });

    test('formatCount formats millions correctly', () {
      expect(NumberFormatter.formatCount(1200000), '1.2M');
    });

    test('formatDuration formats duration correctly', () {
      expect(NumberFormatter.formatDuration(const Duration(minutes: 4, seconds: 15)), '04:15');
      expect(NumberFormatter.formatDuration(const Duration(seconds: 45)), '00:45');
    });
  });

  group('ShareHelper Tests', () {
    test('buildDeepLink creates correct post URL', () {
      final link = ShareHelper.buildDeepLink('post_123');
      expect(link, 'https://yourapp.example/post/post_123');
    });
  });

  group('MockContentRepository Tests', () {
    test('getFeed returns non-empty feed posts', () async {
      final repo = MockContentRepository();
      final posts = await repo.getFeed();
      expect(posts.isNotEmpty, isTrue);
      expect(posts.length, greaterThanOrEqualTo(10));
    });

    test('searchPosts filters posts by query', () async {
      final repo = MockContentRepository();
      final results = await repo.searchPosts('Mahadev');
      expect(results.every((p) => p.title.contains('Mahadev') || p.description.contains('Mahadev') || p.deity == 'Mahadev'), isTrue);
    });

    test('toggleLike updates like status and count', () async {
      final repo = MockContentRepository();
      final initialPost = (await repo.getFeed()).first;
      final initialLikes = initialPost.likes;
      final initialLikedState = initialPost.isLiked;

      final updatedPost = await repo.toggleLike(initialPost.id);
      expect(updatedPost.isLiked, equals(!initialLikedState));
      expect(updatedPost.likes, equals(initialLikedState ? initialLikes - 1 : initialLikes + 1));
    });
  });
}
