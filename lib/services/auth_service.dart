import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase/supabase_client.dart';

class AuthService {
  final SupabaseClient _client = BhagwaSupabase.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => _client.auth.currentSession != null;

  /// Sign in or Register using Email and Password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        await _updateLastActive(response.user!.id);
      }

      return response;
    } catch (e) {
      debugPrint('Error signing in with email: $e');
      rethrow;
    }
  }

  /// Anonymous / Quick Guest Sign In for instant onboarding
  Future<AuthResponse> signInAnonymously() async {
    try {
      final response = await _client.auth.signInAnonymously();
      return response;
    } catch (e) {
      debugPrint('Error signing in anonymously: $e');
      rethrow;
    }
  }

  /// Sign Out User
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> _updateLastActive(String userId) async {
    try {
      await _client.from('profiles').update({
        'last_active_at': DateTime.now().toIso8601String(),
      }).eq('auth_user_id', userId);
    } catch (e) {
      debugPrint('Error updating last_active_at: $e');
    }
  }
}
