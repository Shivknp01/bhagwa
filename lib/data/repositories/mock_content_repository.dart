import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/devotional_post.dart';
import '../../models/horoscope.dart';
import '../../models/deity.dart';
import '../../models/comment.dart';
import '../mock_data.dart';
import 'content_repository.dart';

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return MockContentRepository();
});

class MockContentRepository implements ContentRepository {
  final List<DevotionalPost> _posts = List.from(MockData.feedPosts);
  final Map<String, List<Comment>> _comments = Map.from(MockData.initialComments);

  @override
  Future<List<DevotionalPost>> getFeed({String? category, String? deity}) async {
    // Simulate brief network delay
    await Future.delayed(const Duration(milliseconds: 300));
    var results = List<DevotionalPost>.from(_posts);

    if (category != null && category.isNotEmpty && category != 'All') {
      results = results.where((p) {
        return p.contentType.name.toLowerCase() == category.toLowerCase();
      }).toList();
    }

    if (deity != null && deity.isNotEmpty && deity != 'All') {
      results = results.where((p) {
        return p.deity.toLowerCase() == deity.toLowerCase();
      }).toList();
    }

    return results;
  }

  @override
  Future<List<DevotionalPost>> searchPosts(String query, {String? categoryFilter}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final q = query.trim().toLowerCase();

    var results = _posts.where((post) {
      final matchTitle = post.title.toLowerCase().contains(q);
      final matchDesc = post.description.toLowerCase().contains(q);
      final matchDeity = post.deity.toLowerCase().contains(q);
      final matchType = post.contentType.name.toLowerCase().contains(q);
      return matchTitle || matchDesc || matchDeity || matchType;
    }).toList();

    if (categoryFilter != null && categoryFilter.isNotEmpty && categoryFilter != 'All') {
      results = results.where((p) => p.contentType.name.toLowerCase() == categoryFilter.toLowerCase()).toList();
    }

    return results;
  }

  @override
  Future<DevotionalPost?> getPostById(String id) async {
    final index = _posts.indexWhere((p) => p.id == id);
    if (index != -1) {
      return _posts[index];
    }
    return null;
  }

  @override
  Future<List<Horoscope>> getHoroscopes() async {
    return MockData.horoscopes;
  }

  @override
  Future<Horoscope?> getHoroscopeBySign(String sign) async {
    final list = MockData.horoscopes.where((h) => h.sign.toLowerCase() == sign.toLowerCase()).toList();
    return list.isNotEmpty ? list.first : MockData.horoscopes.first;
  }

  @override
  Future<List<Deity>> getDeities() async {
    return MockData.deities;
  }

  @override
  Future<List<Comment>> getComments(String postId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _comments[postId] ?? [];
  }

  @override
  Future<Comment> addComment(String postId, String commentText, String userName) async {
    final newComment = Comment(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      userName: userName.isNotEmpty ? userName : 'Devotee',
      userAvatar: 'https://i.pravatar.cc/150?img=${(DateTime.now().second % 70) + 1}',
      commentText: commentText,
      timestamp: DateTime.now(),
      likesCount: 0,
      isLiked: false,
    );

    if (!_comments.containsKey(postId)) {
      _comments[postId] = [];
    }
    _comments[postId]!.insert(0, newComment);

    // Update post comments count
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts[index] = _posts[index].copyWith(
        commentsCount: _posts[index].commentsCount + 1,
      );
    }

    return newComment;
  }

  @override
  Future<DevotionalPost> toggleLike(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final newLikedState = !post.isLiked;
      final newLikeCount = newLikedState ? post.likes + 1 : post.likes - 1;
      final updatedPost = post.copyWith(
        isLiked: newLikedState,
        likes: newLikeCount < 0 ? 0 : newLikeCount,
      );
      _posts[index] = updatedPost;
      return updatedPost;
    }
    throw Exception('Post not found');
  }

  @override
  Future<DevotionalPost> toggleSave(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      final newSavedState = !post.isSaved;
      final updatedPost = post.copyWith(isSaved: newSavedState);
      _posts[index] = updatedPost;
      return updatedPost;
    }
    throw Exception('Post not found');
  }

  @override
  Future<List<DevotionalPost>> getSavedPosts() async {
    return _posts.where((p) => p.isSaved).toList();
  }

  @override
  Future<List<DevotionalPost>> getLikedPosts() async {
    return _posts.where((p) => p.isLiked).toList();
  }
}
