import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Color;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

import '../core/supabase/supabase_client.dart';


// ─── Shared plugin instance (used in both main isolate & background isolate) ──
final FlutterLocalNotificationsPlugin _localPlugin =
    FlutterLocalNotificationsPlugin();

const String _channelId = 'daivik_broadcasts';
const String _channelName = 'Daivik Broadcasts';
const String _channelDesc = 'Festival alerts, Aarti reminders & Wallpaper updates';

// ─── Background FCM handler — MUST be a top-level function ───────────────────
// Runs in a SEPARATE Dart isolate. Re-inits local notifications plugin here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM-BG] Received: ${message.messageId} data=${message.data}');

  // Re-initialize flutter_local_notifications in this isolate
  await _initLocalNotificationsInIsolate();

  // Always show a local notification from the data map.
  // We use data-only FCM, so message.notification is always null here.
  final data = message.data;
  if (data.isNotEmpty) {
    await _showLocalNotificationFromData(data, message.hashCode);
  }
}

/// Lightweight init for background isolate — only init plugin, don't create channel
/// (channels persist per app install, no need to recreate)
Future<void> _initLocalNotificationsInIsolate() async {
  const androidInit = AndroidInitializationSettings('@drawable/ic_stat_notification');
  await _localPlugin.initialize(
    const InitializationSettings(android: androidInit),
  );
}

/// Show a local notification from a data map (used in both FG and BG)
Future<void> _showLocalNotificationFromData(
    Map<String, dynamic> data, int id) async {
  final title = data['title']?.toString() ?? 'Daivik 🙏';
  final body = data['body']?.toString() ?? '';

  await _localPlugin.show(
    id,
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
        icon: '@drawable/ic_stat_notification',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        styleInformation: BigTextStyleInformation(body),
        enableVibration: true,
        playSound: true,
        enableLights: true,
        ledColor: const Color(0xFFFF6B00),
        ledOnMs: 1000,
        ledOffMs: 500,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    ),
  );
}

// ─── PushNotificationService ──────────────────────────────────────────────────
class PushNotificationService {
  static final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  static const String _supabaseUrl = 'https://fyhtlazvmvsdgsrndoxh.supabase.co';
  static const String _serviceKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ5aHRsYXp2bXZzZGdzcm5kb3hoIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NjgxODMzNywiZXhwIjoyMTAyMzk0MzM3fQ.tqLbLiAoiID_sgvTE0XdvGBfHdq0XtMseebqu9jVo64';

  /// Call this ONCE in main() before runApp()
  static Future<void> initialize() async {
    // 1. Request OS permission (Android 13+ / iOS)
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    // 2. Initialize local notifications & create Android channel
    await _initLocalNotifications();

    // 3. Register top-level background handler (data-only messages)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 4. iOS foreground presentation options
    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // 5. Register FCM token
    await _registerToken();
    _fcm.onTokenRefresh.listen(_saveToken);

    // 6. FOREGROUND message handler
    // Since we send data-only FCM, onMessage always fires when app is open.
    // We must show a local notification manually here.
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('[FCM-FG] message: ${message.data}');
      _showLocalNotificationFromData(message.data, message.hashCode);
    });

    // 7. App opened by tapping a notification
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('[FCM] Opened from notification tap: ${message.data}');
      // TODO: Navigate to the action_url from message.data['action_url']
    });

    // 8. App launched from terminated state via notification tap
    final initial = await _fcm.getInitialMessage();
    if (initial != null) {
      debugPrint('[FCM] Launched from terminated notification: ${initial.data}');
    }
  }

  // ── Local Notifications Setup (main isolate) ───────────────────────────────
  static Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@drawable/ic_stat_notification');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localPlugin.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: (details) {
        debugPrint('[LocalNotif] Tapped: ${details.payload}');
        // TODO: navigate using details.payload (action_url)
      },
    );

    // Create the Android notification channel with MAXIMUM importance
    // This must be done before the first notification is shown.
    if (Platform.isAndroid) {
      await _localPlugin
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
              showBadge: true,
            ),
          );
      debugPrint('[FCM] Android notification channel created: $_channelId');
    }
  }

  // ── Token Registration ─────────────────────────────────────────────────────
  static Future<void> _registerToken() async {
    try {
      final token = await _fcm.getToken();
      debugPrint('[FCM] Token: ${token?.substring(0, 20)}...');
      if (token != null) {
        await _saveToken(token);
      }
    } catch (e) {
      debugPrint('[FCM] Token registration error: $e');
    }
  }

  static Future<void> _saveToken(String token) async {
    try {
      String? userId = BhagwaSupabase.currentUserId;
      final platform = Platform.isAndroid ? 'android' : 'ios';

      debugPrint('[FCM] Saving token userId=$userId platform=$platform');

      // Guest user: fetch a fallback profile ID
      if (userId == null || userId.isEmpty) {
        try {
          final res = await http.get(
            Uri.parse('$_supabaseUrl/rest/v1/profiles?select=id&limit=1'),
            headers: {
              'apikey': _serviceKey,
              'Authorization': 'Bearer $_serviceKey',
            },
          );
          if (res.statusCode == 200) {
            final List<dynamic> profiles = json.decode(res.body);
            if (profiles.isNotEmpty) {
              userId = profiles.first['id']?.toString();
            }
          }
        } catch (e) {
          debugPrint('[FCM] Error fetching fallback profile: $e');
        }
      }

      if (userId == null || userId.isEmpty) {
        debugPrint('[FCM] No profile ID found — token not registered');
        return;
      }

      final response = await http.post(
        Uri.parse('$_supabaseUrl/rest/v1/user_devices'),
        headers: {
          'apikey': _serviceKey,
          'Authorization': 'Bearer $_serviceKey',
          'Content-Type': 'application/json',
          'Prefer': 'resolution=merge-duplicates',
        },
        body: json.encode({
          'user_id': userId,
          'fcm_token': token,
          'platform': platform,
          'is_active': true,
          'last_seen_at': DateTime.now().toUtc().toIso8601String(),
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('[FCM] Token registered in user_devices ✓');
      } else {
        debugPrint('[FCM] user_devices insert error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('[FCM] Error saving token: $e');
    }
  }

  /// Get current FCM token (for debugging)
  static Future<String?> getToken() => _fcm.getToken();
}
