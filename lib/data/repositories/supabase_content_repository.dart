import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase/supabase_client.dart';
import '../../models/devotional_post.dart';
import '../../models/horoscope.dart';
import '../../models/deity.dart';
import '../../models/comment.dart';
import 'content_repository.dart';
import 'mock_content_repository.dart';

class SupabaseContentRepository implements ContentRepository {
  final SupabaseClient _client = BhagwaSupabase.client;
  final MockContentRepository _fallback = MockContentRepository();

  @override
  Future<List<DevotionalPost>> getFeed({String? category, String? deity}) async {
    try {
      final response = await _client.rpc(
        'get_feed',
        params: {
          'p_category': category ?? 'All',
          'p_deity': deity ?? 'All',
          'p_limit': 50,
          'p_offset': 0,
        },
      );

      if (response == null || (response as List).isEmpty) {
        return _fallback.getFeed(category: category, deity: deity);
      }

      final List<dynamic> data = response;
      return data.map((row) => _mapRowToDevotionalPost(row as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Supabase getFeed notice (using fallback): $e');
      return _fallback.getFeed(category: category, deity: deity);
    }
  }

  @override
  Future<List<DevotionalPost>> searchPosts(String query, {String? categoryFilter}) async {
    try {
      final response = await _client
          .from('posts')
          .select()
          .ilike('title', '%$query%')
          .eq('status', 'published');

      if ((response as List).isEmpty) {
        return _fallback.searchPosts(query, categoryFilter: categoryFilter);
      }

      final List<dynamic> data = response;
      return data.map((row) => _mapRowToDevotionalPost(row as Map<String, dynamic>)).toList();
    } catch (e) {
      return _fallback.searchPosts(query, categoryFilter: categoryFilter);
    }
  }

  @override
  Future<DevotionalPost?> getPostById(String id) async {
    try {
      final response = await _client
          .from('posts')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) {
        return _fallback.getPostById(id);
      }

      return _mapRowToDevotionalPost(response);
    } catch (e) {
      return _fallback.getPostById(id);
    }
  }

  @override
  Future<List<Horoscope>> getHoroscopes() => _fallback.getHoroscopes();

  @override
  Future<Horoscope?> getHoroscopeBySign(String sign) => _fallback.getHoroscopeBySign(sign);

  @override
  Future<List<Deity>> getDeities() => _fallback.getDeities();

  @override
  Future<List<Comment>> getComments(String postId) => _fallback.getComments(postId);

  @override
  Future<Comment> addComment(String postId, String commentText, String userName) =>
      _fallback.addComment(postId, commentText, userName);

  @override
  Future<DevotionalPost> toggleLike(String postId) async {
    try {
      await _client.rpc('toggle_like', params: {'p_post_id': postId});
    } catch (e) {
      debugPrint('Supabase toggleLike notice: $e');
    }
    return _fallback.toggleLike(postId);
  }

  @override
  Future<DevotionalPost> toggleSave(String postId) async {
    try {
      await _client.rpc('toggle_save', params: {'p_post_id': postId});
    } catch (e) {
      debugPrint('Supabase toggleSave notice: $e');
    }
    return _fallback.toggleSave(postId);
  }

  @override
  Future<List<DevotionalPost>> getSavedPosts() => _fallback.getSavedPosts();

  @override
  Future<List<DevotionalPost>> getLikedPosts() => _fallback.getLikedPosts();

  DevotionalPost _mapRowToDevotionalPost(Map<String, dynamic> row) {
    final String typeStr = (row['content_type'] as String? ?? 'status').toLowerCase();
    
    PostContentType contentType = PostContentType.status;
    if (typeStr == 'wallpaper') contentType = PostContentType.wallpaper;
    if (typeStr == 'bhajan') contentType = PostContentType.bhajan;
    if (typeStr == 'music') contentType = PostContentType.music;
    if (typeStr == 'ringtone') contentType = PostContentType.ringtone;
    if (typeStr == 'mantra') contentType = PostContentType.mantra;
    if (typeStr == 'stuti') contentType = PostContentType.stuti;
    if (typeStr == 'horoscope') contentType = PostContentType.horoscope;

    final String actionTypeStr = (row['action_type'] as String? ?? 'shareStatus');
    PostActionType actionType = PostActionType.shareStatus;
    if (actionTypeStr == 'setWallpaper') actionType = PostActionType.setWallpaper;
    if (actionTypeStr == 'playMusic') actionType = PostActionType.playMusic;
    if (actionTypeStr == 'playBhajan') actionType = PostActionType.playBhajan;
    if (actionTypeStr == 'setRingtone') actionType = PostActionType.setRingtone;
    if (actionTypeStr == 'readMantra') actionType = PostActionType.readMantra;
    if (actionTypeStr == 'readStuti') actionType = PostActionType.readStuti;
    if (actionTypeStr == 'readHoroscope') actionType = PostActionType.readHoroscope;

    return DevotionalPost(
      id: row['id']?.toString() ?? '',
      contentType: contentType,
      title: row['title']?.toString() ?? '',
      titleHi: row['title_hi']?.toString(),
      description: row['description']?.toString() ?? '',
      descriptionHi: row['description_hi']?.toString(),
      imageUrl: row['media_url']?.toString() ?? row['thumbnail_url']?.toString(),
      audioUrl: row['audio_url']?.toString(),
      likes: (row['displayed_likes'] as int?) ?? (row['actual_likes'] as int?) ?? 0,
      commentsCount: (row['displayed_comments'] as int?) ?? (row['actual_comments'] as int?) ?? 0,
      views: (row['displayed_views'] as int?) ?? (row['actual_views'] as int?) ?? 0,
      actionType: actionType,
      actionLabel: row['action_label']?.toString() ?? 'Share Status',
      actionLabelHi: row['action_label_hi']?.toString(),
      deity: row['deity_name']?.toString() ?? 'Mahadev',
      authorName: row['author_name']?.toString() ?? 'Bhakti Media',
    );
  }
}
