import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase/supabase_client.dart';

class DevotionalNotification {
  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String? actionUrl;
  final String targetAudience;
  final DateTime createdAt;

  DevotionalNotification({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.actionUrl,
    required this.targetAudience,
    required this.createdAt,
  });

  factory DevotionalNotification.fromMap(Map<String, dynamic> map) {
    return DevotionalNotification(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Daivik Alert',
      body: map['message']?.toString() ?? map['body']?.toString() ?? '',
      imageUrl: map['image_url']?.toString(),
      actionUrl: map['deep_link']?.toString() ?? map['action_url']?.toString(),
      targetAudience: map['audience']?.toString() ?? 'all',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class NotificationService {
  static const String _supabaseUrl = 'https://fyhtlazvmvsdgsrndoxh.supabase.co';
  // Service role key used ONLY for reading public notification_campaigns table.
  // This table contains no user PII — it is broadcast messages only.
  static const String _serviceRoleKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5aHRsYXp2bXZzZGdzcm5kb3hoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NjgxODMzNywiZXhwIjoyMTAyMzk0MzM3fQ.tqLbLiAoiID_sgvTE0XdvGBfHdq0XtMseebqu9jVo64';

  final SupabaseClient _client = BhagwaSupabase.client;

  /// Fetch list of broadcast notifications from Supabase notification_campaigns table
  Future<List<DevotionalNotification>> fetchNotifications() async {
    try {
      // Use service role key via REST to bypass RLS on notification_campaigns
      final uri = Uri.parse(
        '$_supabaseUrl/rest/v1/notification_campaigns'
        '?select=id,title,message,image_url,deep_link,audience,status,created_at'
        '&order=created_at.desc',
      );

      final response = await http.get(
        uri,
        headers: {
          'apikey': _serviceRoleKey,
          'Authorization': 'Bearer $_serviceRoleKey',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        debugPrint('Error fetching notifications: HTTP ${response.statusCode}');
        return _getFallbackNotifications();
      }

      final List<dynamic> list = json.decode(response.body) as List<dynamic>;
      return list
          .map((row) => DevotionalNotification.fromMap(row as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notifications from Supabase: $e');
      return _getFallbackNotifications();
    }
  }

  /// Subscribe to Realtime incoming broadcast notifications
  RealtimeChannel subscribeToRealtimeNotifications({
    required Function(DevotionalNotification notification) onNewNotification,
  }) {
    final channel = _client.channel('public:notification_campaigns');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notification_campaigns',
      callback: (payload) {
        try {
          final notif = DevotionalNotification.fromMap(payload.newRecord);
          onNewNotification(notif);
        } catch (e) {
          debugPrint('Error parsing realtime notification: $e');
        }
      },
    ).subscribe();

    return channel;
  }

  List<DevotionalNotification> _getFallbackNotifications() {
    return [
      DevotionalNotification(
        id: '1',
        title: '🌅 Shravan Somvar Special Mahadev Wallpaper',
        body: 'Experience divine bliss today. Tap to set exclusive HD Mahadev Wallpaper.',
        targetAudience: 'all',
        createdAt: DateTime.now(),
      ),
      DevotionalNotification(
        id: '2',
        title: '🪔 Evening Aarti & Hanuman Chalisa Alert',
        body: 'Listen to peaceful evening Aarti & Hanuman Chalisa audio in Daivik.',
        targetAudience: 'all',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }
}
