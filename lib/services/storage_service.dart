import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'meta_analytics_service.dart';

class UserPreferences {
  final bool isLoggedIn;
  final bool onboardingCompleted;
  final String appLanguage; // 'en' for English (default), 'hi' for Hindi
  final String userName;
  final String bhagwaUserId; // e.g. '101'
  final String userPhone;
  final String userEmail;
  final bool isDarkMode;
  final int paymentCount;
  final List<String> selectedDeities;
  final List<String> selectedContentTypes;
  final bool morningBhaktiNotif;
  final bool eveningAartiNotif;
  final bool goodNightNotif;
  final bool festivalNotif;

  const UserPreferences({
    this.isLoggedIn = false,
    this.onboardingCompleted = false,
    this.appLanguage = 'en',
    this.userName = 'Aditya Sharma',
    this.bhagwaUserId = '101',
    this.userPhone = '+91 98765 43210',
    this.userEmail = 'aditya@example.com',
    this.isDarkMode = false,
    this.paymentCount = 0,
    this.selectedDeities = const ['Mahadev', 'Hanuman', 'Krishna'],
    this.selectedContentTypes = const ['Bhajans', 'Wallpapers', 'Mantras'],
    this.morningBhaktiNotif = true,
    this.eveningAartiNotif = true,
    this.goodNightNotif = true,
    this.festivalNotif = true,
  });

  UserPreferences copyWith({
    bool? isLoggedIn,
    bool? onboardingCompleted,
    String? appLanguage,
    String? userName,
    String? bhagwaUserId,
    String? userPhone,
    String? userEmail,
    bool? isDarkMode,
    int? paymentCount,
    List<String>? selectedDeities,
    List<String>? selectedContentTypes,
    bool? morningBhaktiNotif,
    bool? eveningAartiNotif,
    bool? goodNightNotif,
    bool? festivalNotif,
  }) {
    return UserPreferences(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      appLanguage: appLanguage ?? this.appLanguage,
      userName: userName ?? this.userName,
      bhagwaUserId: bhagwaUserId ?? this.bhagwaUserId,
      userPhone: userPhone ?? this.userPhone,
      userEmail: userEmail ?? this.userEmail,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      paymentCount: paymentCount ?? this.paymentCount,
      selectedDeities: selectedDeities ?? this.selectedDeities,
      selectedContentTypes: selectedContentTypes ?? this.selectedContentTypes,
      morningBhaktiNotif: morningBhaktiNotif ?? this.morningBhaktiNotif,
      eveningAartiNotif: eveningAartiNotif ?? this.eveningAartiNotif,
      goodNightNotif: goodNightNotif ?? this.goodNightNotif,
      festivalNotif: festivalNotif ?? this.festivalNotif,
    );
  }
}

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  SharedPreferences? _prefs;

  UserPreferencesNotifier() : super(const UserPreferences()) {
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final isLoggedIn = _prefs?.getBool('is_logged_in') ?? false;
    final onboardingCompleted = _prefs?.getBool('onboarding_completed') ?? false;
    final appLanguage = _prefs?.getString('app_language') ?? 'en';
    final userName = _prefs?.getString('user_name') ?? 'Aditya Sharma';
    final bhagwaUserId = _prefs?.getString('bhagwa_user_id') ?? '101';
    final userPhone = _prefs?.getString('user_phone') ?? '+91 98765 43210';
    final userEmail = _prefs?.getString('user_email') ?? 'aditya@example.com';
    final isDarkMode = _prefs?.getBool('is_dark_mode') ?? false;
    final paymentCount = _prefs?.getInt('payment_count') ?? 0;
    final selectedDeities = _prefs?.getStringList('selected_deities') ?? ['Mahadev', 'Hanuman', 'Krishna'];
    final selectedContentTypes = _prefs?.getStringList('selected_content_types') ?? ['Bhajans', 'Wallpapers', 'Mantras'];

    state = state.copyWith(
      isLoggedIn: isLoggedIn,
      onboardingCompleted: onboardingCompleted,
      appLanguage: appLanguage,
      userName: userName,
      bhagwaUserId: bhagwaUserId,
      userPhone: userPhone,
      userEmail: userEmail,
      isDarkMode: isDarkMode,
      paymentCount: paymentCount,
      selectedDeities: selectedDeities,
      selectedContentTypes: selectedContentTypes,
    );
  }

  Future<void> setLanguage(String langCode) async {
    state = state.copyWith(appLanguage: langCode);
    await _prefs?.setString('app_language', langCode);
  }

  Future<void> toggleLanguage() async {
    final nextLang = state.appLanguage == 'en' ? 'hi' : 'en';
    await setLanguage(nextLang);
  }

  Future<void> login({
    required String name,
    required String phone,
    String? email,
    String? bhagwaUserId,
  }) async {
    final finalEmail = email?.isNotEmpty == true ? email! : '$phone@bhakti.app';
    final finalUserId = bhagwaUserId ?? state.bhagwaUserId;

    state = state.copyWith(
      isLoggedIn: true,
      userName: name.isNotEmpty ? name : 'Devotee User',
      bhagwaUserId: finalUserId,
      userPhone: phone,
      userEmail: finalEmail,
    );

    await _prefs?.setBool('is_logged_in', true);
    await _prefs?.setString('user_name', state.userName);
    await _prefs?.setString('bhagwa_user_id', state.bhagwaUserId);
    await _prefs?.setString('user_phone', state.userPhone);
    await _prefs?.setString('user_email', state.userEmail);
  }

  Future<void> updateBhagwaUserId(String numericId) async {
    state = state.copyWith(bhagwaUserId: numericId);
    await _prefs?.setString('bhagwa_user_id', numericId);
  }

  Future<void> logout() async {
    state = state.copyWith(isLoggedIn: false);
    await _prefs?.setBool('is_logged_in', false);
  }

  Future<void> completeOnboarding(List<String> deities, List<String> contentTypes) async {
    state = state.copyWith(
      onboardingCompleted: true,
      selectedDeities: deities,
      selectedContentTypes: contentTypes,
    );

    await _prefs?.setBool('onboarding_completed', true);
    await _prefs?.setStringList('selected_deities', deities);
    await _prefs?.setStringList('selected_content_types', contentTypes);
  }

  Future<void> toggleDarkMode() async {
    final newMode = !state.isDarkMode;
    state = state.copyWith(isDarkMode: newMode);
    await _prefs?.setBool('is_dark_mode', newMode);
  }

  void toggleMorningNotif() {
    state = state.copyWith(morningBhaktiNotif: !state.morningBhaktiNotif);
  }

  void toggleEveningNotif() {
    state = state.copyWith(eveningAartiNotif: !state.eveningAartiNotif);
  }

  void toggleGoodNightNotif() {
    state = state.copyWith(goodNightNotif: !state.goodNightNotif);
  }

  void toggleFestivalNotif() {
    state = state.copyWith(festivalNotif: !state.festivalNotif);
  }

  Future<void> recordPayment({required double amount, String currency = 'INR'}) async {
    final newCount = state.paymentCount + 1;
    state = state.copyWith(paymentCount: newCount);
    await _prefs?.setInt('payment_count', newCount);

    // Trigger Meta Marketing Events
    MetaAnalyticsService.logPurchase(amount: amount, currency: currency);
    if (newCount == 1) {
      MetaAnalyticsService.logFirstPay(amount: amount, currency: currency);
    } else if (newCount == 2) {
      MetaAnalyticsService.logSecondPay(amount: amount, currency: currency);
    }
  }
}

final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  return UserPreferencesNotifier();
});
