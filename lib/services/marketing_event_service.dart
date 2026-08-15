import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'meta_analytics_service.dart';
import '../core/supabase/supabase_client.dart';

class MarketingEventService {
  static final FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics.instance;
  static final Set<String> _processedTransactionIds = {};
  static bool _installFired = false;

  /// Strict Provider Filter for Meta Marketing SDK
  static const Set<String> metaAllowedEvents = {
    'install',
    'registration',
    'recharges',
    'fp',
    'sp',
    'tp',
  };

  /// 1. Install Event (fired once per installation identity)
  static Future<void> trackInstall() async {
    if (_installFired) return;
    final prefs = await SharedPreferences.getInstance();
    final alreadyLogged = prefs.getBool('meta_install_logged') ?? false;

    if (!alreadyLogged) {
      _installFired = true;
      await prefs.setBool('meta_install_logged', true);

      // Meta Provider (Allowed)
      await MetaAnalyticsService.logInstall();
    }

    // Firebase Analytics Provider (Full Taxonomy)
    try {
      await _firebaseAnalytics.logAppOpen();
      await _firebaseAnalytics.logEvent(name: 'install');
      debugPrint('[Firebase] Logged App Open & Install');
    } catch (e) {
      debugPrint('[Firebase] logInstall notice: $e');
    }
  }

  /// 2. Registration Event (fired only after successful account creation)
  static Future<void> trackRegistration({required String method}) async {
    // Meta Provider (Allowed)
    await MetaAnalyticsService.logRegistration(registrationMethod: method);

    // Firebase Analytics Provider (Full Taxonomy)
    try {
      await _firebaseAnalytics.logSignUp(signUpMethod: method);
      await _firebaseAnalytics.logEvent(
        name: 'registration',
        parameters: {'method': method},
      );
      debugPrint('[Firebase] Logged SignUp & Registration ($method)');
    } catch (e) {
      debugPrint('[Firebase] logRegistration notice: $e');
    }
  }

  /// 3. Verified Payment Sequence: recharges, fp, sp, tp
  static Future<void> trackVerifiedPaymentSuccess({
    required String transactionId,
    required double amount,
    String currency = 'INR',
    String? productId,
  }) async {
    // Deduplication check
    if (_processedTransactionIds.contains(transactionId)) {
      debugPrint('[MarketingEventService] Transaction $transactionId already processed. Deduplicated.');
      return;
    }
    _processedTransactionIds.add(transactionId);

    // Fetch trusted backend transaction count from Supabase
    int previousCount = 0;
    try {
      final client = BhagwaSupabase.client;
      final userId = client.auth.currentUser?.id;
      if (userId != null) {
        final res = await client
            .from('subscription_transactions')
            .select('id')
            .eq('user_id', userId)
            .eq('status', 'success');
        final list = res as List;
        previousCount = list.isNotEmpty ? list.length - 1 : 0;
      }
    } catch (e) {
      debugPrint('[MarketingEventService] Error querying payment history: $e');
    }

    // Always fire 'recharges' to Meta
    await MetaAnalyticsService.logRecharge(
      amount: amount,
      currency: currency,
      transactionId: transactionId,
      productId: productId,
    );

    // Fire milestone event based on exact previous count
    if (previousCount == 0) {
      await MetaAnalyticsService.logFirstPay(
        amount: amount,
        currency: currency,
        transactionId: transactionId,
        productId: productId,
      );
    } else if (previousCount == 1) {
      await MetaAnalyticsService.logSecondPay(
        amount: amount,
        currency: currency,
        transactionId: transactionId,
        productId: productId,
      );
    } else if (previousCount == 2) {
      await MetaAnalyticsService.logThirdPay(
        amount: amount,
        currency: currency,
        transactionId: transactionId,
        productId: productId,
      );
    }

    // Firebase Analytics Provider (Full Taxonomy)
    try {
      await _firebaseAnalytics.logPurchase(
        currency: currency,
        value: amount,
        transactionId: transactionId,
      );
      final Map<String, Object> payParams = {
        'value': amount,
        'currency': currency,
        'transaction_id': transactionId,
        'previous_recharge_count': previousCount,
      };
      if (productId != null) payParams['product_id'] = productId;

      await _firebaseAnalytics.logEvent(
        name: 'payment_success',
        parameters: payParams,
      );
      debugPrint('[Firebase] Logged Purchase & payment_success ($amount)');
    } catch (e) {
      debugPrint('[Firebase] logPurchase notice: $e');
    }
  }

  /// 4. Generic Event Dispatcher (Meta filter drops non-allowed events, Firebase receives all)
  static Future<void> trackProductEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    if (metaAllowedEvents.contains(eventName)) {
      debugPrint('[Meta] Processing allowed business event: $eventName');
    } else {
      // EXCLUDED FROM META - Meta provider ignores non-allowed events
      debugPrint('[Meta] IGNORED prohibited product event: $eventName');
    }

    // Firebase Analytics Provider receives full product taxonomy
    try {
      final Map<String, Object>? firebaseParams = parameters?.map(
        (key, value) => MapEntry(key, value as Object),
      );
      await _firebaseAnalytics.logEvent(
        name: eventName,
        parameters: firebaseParams,
      );
      debugPrint('[Firebase] Logged Event -> $eventName ${parameters ?? {}}');
    } catch (e) {
      debugPrint('[Firebase] logEvent notice: $e');
    }
  }
}
