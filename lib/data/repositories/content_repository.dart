import '../../models/devotional_post.dart';
import '../../models/horoscope.dart';
import '../../models/deity.dart';
import '../../models/comment.dart';

abstract class ContentRepository {
  Future<List<DevotionalPost>> getFeed({String? category, String? deity});
  Future<List<DevotionalPost>> searchPosts(String query, {String? categoryFilter});
  Future<DevotionalPost?> getPostById(String id);
  Future<List<Horoscope>> getHoroscopes();
  Future<Horoscope?> getHoroscopeBySign(String sign);
  Future<List<Deity>> getDeities();
  Future<List<Comment>> getComments(String postId);
  Future<Comment> addComment(String postId, String commentText, String userName);
  Future<DevotionalPost> toggleLike(String postId);
  Future<DevotionalPost> toggleSave(String postId);
  Future<List<DevotionalPost>> getSavedPosts();
  Future<List<DevotionalPost>> getLikedPosts();
}
