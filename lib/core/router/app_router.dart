import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/audio/full_audio_player_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/category/category_detail_screen.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/favorites/saved_items_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/horoscope/horoscope_screen.dart';
import '../../features/navigation/main_shell_scaffold.dart';
import '../../features/notifications/notification_settings_screen.dart';
import '../../features/notifications/notifications_center_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/reader/mantra_reader_screen.dart';
import '../../features/search/search_screen.dart';
import '../../services/storage_service.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(userPreferencesProvider);

  // Flow: Login Screen FIRST -> Onboarding Pages -> 3 Main Pages (Home, Explore, Profile)
  String initialPath = '/home';
  if (!prefs.isLoggedIn) {
    initialPath = '/login';
  } else if (!prefs.onboardingCompleted) {
    initialPath = '/onboarding';
  }

  return GoRouter(
    initialLocation: initialPath,
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Stateful Shell Route for 3 Main Pages (Home, Explore, Profile)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Page 1: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Page 2: Explore
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/explore',
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),

          // Page 3: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Category Detail Route
      GoRoute(
        path: '/category/:name',
        builder: (context, state) {
          final categoryName = state.pathParameters['name'] ?? 'All';
          return CategoryDetailScreen(categoryName: categoryName);
        },
      ),

      // Full screen routes
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final query = state.uri.queryParameters['query'];
          return SearchScreen(initialQuery: query);
        },
      ),

      GoRoute(
        path: '/player',
        pageBuilder: (context, state) => CustomTransitionPage(
          child: const FullAudioPlayerScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: '/reader/:postId',
        builder: (context, state) {
          final postId = state.pathParameters['postId'] ?? 'post_4';
          return MantraReaderScreen(postId: postId);
        },
      ),

      GoRoute(
        path: '/horoscope',
        builder: (context, state) => const HoroscopeScreen(),
      ),

      GoRoute(
        path: '/saved',
        builder: (context, state) => const SavedItemsScreen(),
      ),

      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsCenterScreen(),
      ),

      GoRoute(
        path: '/notifications/settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
    ],
  );
});
