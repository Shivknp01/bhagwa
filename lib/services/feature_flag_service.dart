import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase/supabase_client.dart';

class FeatureFlagService {
  final SupabaseClient _client = BhagwaSupabase.client;
  final Map<String, bool> _flagsCache = {};

  /// Check if a feature flag is enabled
  Future<bool> isEnabled(String key, {bool defaultValue = true}) async {
    if (_flagsCache.containsKey(key)) {
      return _flagsCache[key]!;
    }

    try {
      final response = await _client
          .from('feature_flags')
          .select('enabled')
          .eq('flag_key', key)
          .maybeSingle();

      if (response != null && response['enabled'] != null) {
        final bool enabled = response['enabled'] as bool;
        _flagsCache[key] = enabled;
        return enabled;
      }
    } catch (e) {
      debugPrint('FeatureFlagService error for $key: $e');
    }

    return defaultValue;
  }
}
