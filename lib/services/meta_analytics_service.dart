import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

class MetaAnalyticsService {
  static final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  /// 1. Install Event (install)
  static Future<void> logInstall() async {
    try {
      await _facebookAppEvents.logEvent(name: 'install');
      debugPrint('[Meta] install');
    } catch (e) {
      debugPrint('Meta SDK logInstall notice: $e');
    }
  }

  /// 2. Registration Event (registration)
  static Future<void> logRegistration({required String registrationMethod}) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'registration',
        parameters: {
          'method': registrationMethod,
        },
      );
      debugPrint('[Meta] registration (method: $registrationMethod)');
    } catch (e) {
      debugPrint('Meta SDK logRegistration notice: $e');
    }
  }

  /// 3. Confirmed Recharge Event (recharges)
  static Future<void> logRecharge({
    required double amount,
    required String currency,
    String? transactionId,
    String? productId,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'value': amount,
        'currency': currency,
      };
      if (transactionId != null) params['transaction_id'] = transactionId;
      if (productId != null) params['product_id'] = productId;

      await _facebookAppEvents.logEvent(
        name: 'recharges',
        valueToSum: amount,
        parameters: params,
      );
      debugPrint('[Meta] recharges (value: $amount, tx: $transactionId)');
    } catch (e) {
      debugPrint('Meta SDK logRecharge notice: $e');
    }
  }

  /// 4. First Pay Milestone Event (fp)
  static Future<void> logFirstPay({
    required double amount,
    required String currency,
    String? transactionId,
    String? productId,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'value': amount,
        'currency': currency,
      };
      if (transactionId != null) params['transaction_id'] = transactionId;
      if (productId != null) params['product_id'] = productId;

      await _facebookAppEvents.logEvent(
        name: 'fp',
        valueToSum: amount,
        parameters: params,
      );
      debugPrint('[Meta] fp (value: $amount, tx: $transactionId)');
    } catch (e) {
      debugPrint('Meta SDK logFirstPay notice: $e');
    }
  }

  /// 5. Second Pay Milestone Event (sp)
  static Future<void> logSecondPay({
    required double amount,
    required String currency,
    String? transactionId,
    String? productId,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'value': amount,
        'currency': currency,
      };
      if (transactionId != null) params['transaction_id'] = transactionId;
      if (productId != null) params['product_id'] = productId;

      await _facebookAppEvents.logEvent(
        name: 'sp',
        valueToSum: amount,
        parameters: params,
      );
      debugPrint('[Meta] sp (value: $amount, tx: $transactionId)');
    } catch (e) {
      debugPrint('Meta SDK logSecondPay notice: $e');
    }
  }

  /// 6. Third Pay Milestone Event (tp)
  static Future<void> logThirdPay({
    required double amount,
    required String currency,
    String? transactionId,
    String? productId,
  }) async {
    try {
      final Map<String, dynamic> params = {
        'value': amount,
        'currency': currency,
      };
      if (transactionId != null) params['transaction_id'] = transactionId;
      if (productId != null) params['product_id'] = productId;

      await _facebookAppEvents.logEvent(
        name: 'tp',
        valueToSum: amount,
        parameters: params,
      );
      debugPrint('[Meta] tp (value: $amount, tx: $transactionId)');
    } catch (e) {
      debugPrint('Meta SDK logThirdPay notice: $e');
    }
  }
}
