import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

class MetaAnalyticsService {
  static final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  /// 1. Log App Install / Launch Event
  static Future<void> logInstall() async {
    try {
      await _facebookAppEvents.logEvent(name: 'install');
      await _facebookAppEvents.logEvent(name: 'fb_mobile_activate_app');
      debugPrint('Meta SDK: Logged Event -> install');
    } catch (e) {
      debugPrint('Meta SDK logInstall notice: $e');
    }
  }

  /// 2. Log User Registration / Sign-In Event
  static Future<void> logRegistration({required String registrationMethod}) async {
    try {
      await _facebookAppEvents.logCompletedRegistration(
        registrationMethod: registrationMethod,
      );
      await _facebookAppEvents.logEvent(
        name: 'registration',
        parameters: {
          'method': registrationMethod,
        },
      );
      debugPrint('Meta SDK: Logged Event -> registration ($registrationMethod)');
    } catch (e) {
      debugPrint('Meta SDK logRegistration notice: $e');
    }
  }

  /// 3. Log In-App Purchase Event
  static Future<void> logPurchase({
    required double amount,
    required String currency,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _facebookAppEvents.logPurchase(
        amount: amount,
        currency: currency,
        parameters: parameters,
      );
      await _facebookAppEvents.logEvent(
        name: 'purchase',
        valueToSum: amount,
        parameters: {
          'currency': currency,
          ...?parameters,
        },
      );
      debugPrint('Meta SDK: Logged Event -> purchase ($currency $amount)');
    } catch (e) {
      debugPrint('Meta SDK logPurchase notice: $e');
    }
  }

  /// 4. Log First Payment Event (firstpay)
  static Future<void> logFirstPay({
    required double amount,
    required String currency,
    String? planName,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'firstpay',
        valueToSum: amount,
        parameters: {
          'amount': amount,
          'currency': currency,
          'plan_name': planName ?? 'Devotional Subscription',
        },
      );
      debugPrint('Meta SDK: Logged Event -> firstpay ($currency $amount)');
    } catch (e) {
      debugPrint('Meta SDK logFirstPay notice: $e');
    }
  }

  /// 5. Log Second Payment Event (secondpay)
  static Future<void> logSecondPay({
    required double amount,
    required String currency,
    String? planName,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'secondpay',
        valueToSum: amount,
        parameters: {
          'amount': amount,
          'currency': currency,
          'plan_name': planName ?? 'Devotional Subscription Renewal',
        },
      );
      debugPrint('Meta SDK: Logged Event -> secondpay ($currency $amount)');
    } catch (e) {
      debugPrint('Meta SDK logSecondPay notice: $e');
    }
  }
}
