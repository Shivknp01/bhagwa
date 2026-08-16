import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/supabase/supabase_client.dart';
import 'services/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/marketing_event_service.dart';
import 'services/permission_service.dart';
import 'services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Core for Analytics, FCM & Crash reporting
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('[Firebase] Initialized successfully!');
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // Initialize FCM push notifications (registers token, sets up handlers)
  try {
    await PushNotificationService.initialize();
  } catch (e) {
    debugPrint('PushNotificationService init notice: $e');
  }

  // Initialize Marketing Event Service install tracking
  MarketingEventService.trackInstall();

  // Prompt Runtime OS Permissions for Notifications & Media Storage
  try {
    await PermissionService.requestMediaUploadPermissions();
  } catch (e) {
    debugPrint('Startup permissions request notice: $e');
  }

  // Initialize Supabase once at app startup
  try {
    await BhagwaSupabase.initialize();
  } catch (e) {
    debugPrint('Supabase initialization warning: $e');
  }

  runApp(
    const ProviderScope(
      child: DaivikApp(),
    ),
  );
}

class DaivikApp extends ConsumerWidget {
  const DaivikApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final userPrefs = ref.watch(userPreferencesProvider);

    return MaterialApp.router(
      title: 'Daivik',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: userPrefs.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
