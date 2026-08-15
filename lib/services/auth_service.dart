import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase/supabase_client.dart';

class AuthSettings {
  final bool googleEnabled;
  final bool phoneEnabled;
  final bool skipEnabled;

  const AuthSettings({
    this.googleEnabled = true,
    this.phoneEnabled = true,
    this.skipEnabled = true,
  });

  AuthSettings copyWith({
    bool? googleEnabled,
    bool? phoneEnabled,
    bool? skipEnabled,
  }) {
    return AuthSettings(
      googleEnabled: googleEnabled ?? this.googleEnabled,
      phoneEnabled: phoneEnabled ?? this.phoneEnabled,
      skipEnabled: skipEnabled ?? this.skipEnabled,
    );
  }
}

class AuthService {
  final SupabaseClient _client = BhagwaSupabase.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => _client.auth.currentSession != null;

  /// Fetch dynamic auth configuration from Supabase app_settings
  Future<AuthSettings> fetchAuthSettings() async {
    try {
      final response = await _client
          .from('app_settings')
          .select('setting_key, setting_value');

      bool google = true;
      bool phone = true;
      bool skip = true;

      for (final row in response as List) {
        final key = row['setting_key'] as String;
        final rawVal = row['setting_value'];
        final bool val = rawVal == true || rawVal == 'true';
        if (key == 'auth.google_enabled') google = val;
        if (key == 'auth.phone_enabled') phone = val;
        if (key == 'auth.skip_enabled') skip = val;
      }

      return AuthSettings(
        googleEnabled: google,
        phoneEnabled: phone,
        skipEnabled: skip,
      );
    } catch (e) {
      debugPrint('AuthService fetchAuthSettings error: $e');
      return const AuthSettings();
    }
  }

  /// Subscribe to Realtime app_settings updates for instant 0ms UI toggling
  RealtimeChannel subscribeToRealtimeAuthSettings({
    required Function(AuthSettings updatedSettings) onSettingsChanged,
  }) {
    final channel = _client.channel('public:app_settings');
    channel.onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'app_settings',
      callback: (payload) async {
        final newSettings = await fetchAuthSettings();
        onSettingsChanged(newSettings);
      },
    ).subscribe();

    return channel;
  }

  /// Sign in with Google OAuth
  Future<bool> signInWithGoogle() async {
    try {
      final bool res = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'bhagwa://auth-callback',
      );
      return res;
    } catch (e) {
      debugPrint('Error in signInWithGoogle: $e');
      rethrow;
    }
  }

  /// Send SMS OTP to Phone Number
  Future<void> sendPhoneOTP(String phoneNumber) async {
    try {
      final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';
      await _client.auth.signInWithOtp(
        phone: formattedPhone,
      );
    } catch (e) {
      debugPrint('Error in sendPhoneOTP: $e');
      rethrow;
    }
  }

  /// Verify Phone OTP Code
  Future<AuthResponse> verifyPhoneOTP({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      final formattedPhone = phoneNumber.startsWith('+') ? phoneNumber : '+91$phoneNumber';
      final response = await _client.auth.verifyOTP(
        type: OtpType.sms,
        phone: formattedPhone,
        token: otpCode,
      );

      if (response.user != null) {
        await _updateLastActive(response.user!.id);
      }

      return response;
    } catch (e) {
      debugPrint('Error in verifyPhoneOTP: $e');
      rethrow;
    }
  }

  /// Skip Login (Anonymous Guest Authentication)
  Future<AuthResponse> signInAnonymously() async {
    try {
      final response = await _client.auth.signInAnonymously();
      return response;
    } catch (e) {
      debugPrint('Error in signInAnonymously: $e');
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
