import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  final bool isLoggedIn;
  final bool onboardingCompleted;
  final String appLanguage; // 'en' for English (default), 'hi' for Hindi
  final String userName;
  final String userPhone;
  final String userEmail;
  final bool isDarkMode;
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
    this.userPhone = '+91 98765 43210',
    this.userEmail = 'aditya@example.com',
    this.isDarkMode = false,
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
    String? userPhone,
    String? userEmail,
    bool? isDarkMode,
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
      userPhone: userPhone ?? this.userPhone,
      userEmail: userEmail ?? this.userEmail,
      isDarkMode: isDarkMode ?? this.isDarkMode,
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
    final userPhone = _prefs?.getString('user_phone') ?? '+91 98765 43210';
    final userEmail = _prefs?.getString('user_email') ?? 'aditya@example.com';
    final isDarkMode = _prefs?.getBool('is_dark_mode') ?? false;
    final selectedDeities = _prefs?.getStringList('selected_deities') ?? ['Mahadev', 'Hanuman', 'Krishna'];
    final selectedContentTypes = _prefs?.getStringList('selected_content_types') ?? ['Bhajans', 'Wallpapers', 'Mantras'];

    state = state.copyWith(
      isLoggedIn: isLoggedIn,
      onboardingCompleted: onboardingCompleted,
      appLanguage: appLanguage,
      userName: userName,
      userPhone: userPhone,
      userEmail: userEmail,
      isDarkMode: isDarkMode,
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

  Future<void> login({required String name, required String phone, String? email}) async {
    final finalEmail = email?.isNotEmpty == true ? email! : '$phone@bhakti.app';
    state = state.copyWith(
      isLoggedIn: true,
      userName: name.isNotEmpty ? name : 'Devotee User',
      userPhone: phone,
      userEmail: finalEmail,
    );

    await _prefs?.setBool('is_logged_in', true);
    await _prefs?.setString('user_name', state.userName);
    await _prefs?.setString('user_phone', state.userPhone);
    await _prefs?.setString('user_email', state.userEmail);
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
}

final userPreferencesProvider = StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  return UserPreferencesNotifier();
});
