import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import '../core/supabase/supabase_client.dart';

// ─── Background FCM handler (must be top-level function) ─────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
  // Background messages with notification payload are automatically shown by OS.
  // For data-only messages, show a local notification.
  if (message.notification == null && message.data.isNotEmpty) {
    await PushNotificationService._showLocalNotificationFromData(message.data);
  }
}

// ─── PushNotificationService ──────────────────────────────────────────────────
class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'daivik_broadcasts';
  static const _channelName = 'Daivik Broadcasts';
  static const _channelDesc = 'Festival alerts, Aarti reminders & Wallpaper updates';

  static const String _supabaseUrl = 'https://fyhtlazvmvsdgsrndoxh.supabase.co';
  static const String _serviceKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5aHRsYXp2bXZzZGdzcm5kb3hoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NjgxODMzNywiZXhwIjoyMTAyMzk0MzM3fQ.tqLbLiAoiID_sgvTE0XdvGBfHdq0XtMseebqu9jVo64';

  /// Call this ONCE in main() before runApp()
  static Future<void> initialize() async {
    // 1. Request OS permission
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    // 2. Init local notifications channel
    await _initLocalNotifications();

    // 3. Register background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 4. Register token + listen for token refresh
    await _registerToken();
    _fcm.onTokenRefresh.listen(_saveToken);

    // 5. Foreground message handler → show local banner
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM] Foreground: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // 6. App opened from notification tap
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] Opened from notification: ${message.data}');
    });

    // 7. Check if app was launched from a terminated-state notification
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      debugPrint('[FCM] Launched from terminated notification: ${initial.data}');
    }
  }

  // ── Local Notifications Setup ──────────────────────────────────────────────
  static Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _local.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
    );

    // Create Android notification channel
    if (Platform.isAndroid) {
      await _local
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              _channelId,
              _channelName,
              description: _channelDesc,
              importance: Importance.max,
              playSound: true,
              enableVibration: true,
            ),
          );
    }
  }

  // ── Show Local Notification from RemoteMessage ─────────────────────────────
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final notif = message.notification;
    final title = notif?.title ?? message.data['title'] ?? 'Daivik';
    final body = notif?.body ?? message.data['body'] ?? '';

    await _local.show(
      message.hashCode,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDesc,
          importance: Importance.max,
          priority: Priority.max,
          visibility: NotificationVisibility.public,
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(body),
          enableVibration: true,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  // ── Show Local Notification from data map (background data-only) ───────────
  static Future<void> _showLocalNotificationFromData(
      Map<String, dynamic> data) async {
    final title = data['title']?.toString() ?? 'Daivik';
    final body = data['body']?.toString() ?? '';

    await _local.show(
      data.hashCode,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          importance: Importance.max,
          priority: Priority.max,
          visibility: NotificationVisibility.public,
          icon: '@mipmap/ic_launcher',
          enableVibration: true,
          playSound: true,
        ),
      ),
    );
  }

  // ── Token Registration ─────────────────────────────────────────────────────
  static Future<void> _registerToken() async {
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        await _saveToken(token);
      }
    } catch (e) {
      debugPrint('[FCM] Token registration error: $e');
    }
  }

  static Future<void> _saveToken(String token) async {
    try {
      final userId = BhagwaSupabase.currentUserId;
      final platform = Platform.isAndroid ? 'android' : 'ios';

      debugPrint('[FCM] Registering token: ${token.substring(0, 20)}... userId=$userId');

      // Try the admin API first (creates device_tokens table entry)
      final response = await http.post(
        Uri.parse('https://bhagwa-admin.vercel.app/api/v1/device-token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'token': token,
          'platform': platform,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[FCM] Token registered via admin API ✓');
        return;
      }

      // Fallback: store directly in Supabase device_tokens table
      final fallbackResponse = await http.post(
        Uri.parse('$_supabaseUrl/rest/v1/device_tokens'),
        headers: {
          'apikey': _serviceKey,
          'Authorization': 'Bearer $_serviceKey',
          'Content-Type': 'application/json',
          'Prefer': 'resolution=merge-duplicates',
        },
        body: json.encode({
          'fcm_token': token,
          'platform': platform,
          'user_id': userId,
          'last_seen': DateTime.now().toUtc().toIso8601String(),
          'is_active': true,
        }),
      );

      debugPrint('[FCM] Supabase direct fallback: HTTP ${fallbackResponse.statusCode}');
    } catch (e) {
      debugPrint('[FCM] Error saving token: $e');
    }
  }

  /// Get current FCM token (for debugging)
  static Future<String?> getToken() => _fcm.getToken();
}
