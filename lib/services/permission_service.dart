import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Request Media Storage / Gallery permissions (Images & Video upload)
  static Future<bool> requestMediaUploadPermissions() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final photos = await Permission.photos.request();
        final videos = await Permission.videos.request();
        final storage = await Permission.storage.request();
        return photos.isGranted || videos.isGranted || storage.isGranted;
      }
      final storage = await Permission.storage.request();
      return storage.isGranted;
    } catch (e) {
      debugPrint('Permission request error: $e');
      return true;
    }
  }

  /// Request Camera permission
  static Future<bool> requestCameraPermission() async {
    try {
      final camera = await Permission.camera.request();
      return camera.isGranted;
    } catch (e) {
      debugPrint('Camera permission error: $e');
      return true;
    }
  }

  /// Request Notification permission
  static Future<bool> requestNotificationPermission() async {
    try {
      final notif = await Permission.notification.request();
      return notif.isGranted;
    } catch (e) {
      debugPrint('Notification permission error: $e');
      return true;
    }
  }

  /// Request System Write Settings for custom ringtones
  static Future<bool> requestSystemWriteSettingsPermission() async {
    try {
      final systemAlert = await Permission.systemAlertWindow.request();
      return systemAlert.isGranted;
    } catch (e) {
      debugPrint('System settings permission error: $e');
      return true;
    }
  }
}
