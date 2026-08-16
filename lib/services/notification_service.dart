import 'package:flutter/foundation.dart';
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
      title: map['title']?.toString() ?? map['heading']?.toString() ?? 'Daivik Alert',
      body: map['message']?.toString() ?? map['body']?.toString() ?? '',
      imageUrl: map['image_url']?.toString() ?? map['imageUrl']?.toString(),
      actionUrl: map['deep_link']?.toString() ?? map['action_url']?.toString() ?? map['actionUrl']?.toString(),
      targetAudience: map['audience']?.toString() ?? map['target_audience']?.toString() ?? 'all',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'].toString())
          : map['createdAt'] != null
              ? DateTime.parse(map['createdAt'].toString())
              : DateTime.now(),
    );
  }
}

class NotificationService {
  final SupabaseClient _client = BhagwaSupabase.client;

  /// Fetch list of sent broadcast notifications from Supabase
  Future<List<DevotionalNotification>> fetchNotifications() async {
    try {
      final response = await _client
          .from('notification_campaigns')
          .select('*')
          .order('created_at', ascending: false);

      final list = (response as List)
          .map((row) => DevotionalNotification.fromMap(row as Map<String, dynamic>))
          .toList();

      return list;
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
        final notif = DevotionalNotification.fromMap(payload.newRecord);
        onNewNotification(notif);
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
