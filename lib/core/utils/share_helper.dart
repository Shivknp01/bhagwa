import 'package:share_plus/share_plus.dart';

class ShareHelper {
  static String buildDeepLink(String postId) {
    return 'https://yourapp.example/post/$postId';
  }

  static Future<void> sharePost({
    required String postId,
    required String title,
    required String description,
  }) async {
    final String deepLink = buildDeepLink(postId);
    final String message =
        '🙏 *$title*\n\n$description\n\n✨ Open in Bhakti App: $deepLink';
    // ignore: deprecated_member_use
    await Share.share(message, subject: title);
  }

  static Future<void> shareWhatsApp({
    required String postId,
    required String title,
    required String description,
  }) async {
    final String deepLink = buildDeepLink(postId);
    final String message =
        '🌸 *$title*\n\n$description\n\n🚩 Join Daivik — Bhakti: $deepLink';
    // ignore: deprecated_member_use
    await Share.share(message, subject: title);
  }
}
