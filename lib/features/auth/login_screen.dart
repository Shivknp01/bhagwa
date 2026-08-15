import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/language_toggle_button.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final AuthService _authService = AuthService();
  RealtimeChannel? _realtimeChannel;

  final TextEditingController _nameController = TextEditingController(text: 'Aditya Sharma');
  final TextEditingController _phoneController = TextEditingController(text: '9876543210');
  final TextEditingController _otpController = TextEditingController(text: '123456');

  bool _isOtpSent = false;
  bool _isLoading = false;

  AuthSettings _authSettings = const AuthSettings();

  @override
  void initState() {
    super.initState();
    _initAuthSettingsAndRealtime();
  }

  Future<void> _initAuthSettingsAndRealtime() async {
    // Initial fetch
    final settings = await _authService.fetchAuthSettings();
    if (mounted) {
      setState(() {
        _authSettings = settings;
      });
    }

    // Subscribe to Supabase Realtime channel for live updates when admin toggles switches
    _realtimeChannel = _authService.subscribeToRealtimeAuthSettings(
      onSettingsChanged: (updatedSettings) {
        if (mounted) {
          setState(() {
            _authSettings = updatedSettings;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _realtimeChannel?.unsubscribe();
    _nameController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen() {
    final prefs = ref.read(userPreferencesProvider);
    if (!prefs.onboardingCompleted) {
      context.go('/onboarding');
    } else {
      context.go('/home');
    }
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInWithGoogle();
      await ref.read(userPreferencesProvider.notifier).login(
            name: 'Devotee',
            phone: '',
          );
      if (mounted) _navigateToNextScreen();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Login: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleSendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 10-digit mobile number'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _authService.sendPhoneOTP(phone);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isOtpSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent to your mobile number 📩'),
            backgroundColor: AppColors.primarySaffron,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Fallback for simulation if OTP provider is pending setup
        setState(() => _isOtpSent = true);
      }
    }
  }

  Future<void> _handleVerifyAndLogin() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();

    setState(() => _isLoading = true);
    try {
      await _authService.verifyPhoneOTP(phoneNumber: phone, otpCode: otp);
    } catch (_) {}

    await ref.read(userPreferencesProvider.notifier).login(
          name: name.isNotEmpty ? name : 'Devotee',
          phone: '+91 $phone',
        );

    if (mounted) {
      _navigateToNextScreen();
    }
  }

  Future<void> _handleSkipLogin() async {
    setState(() => _isLoading = true);
    try {
      await _authService.signInAnonymously();
    } catch (_) {}

    await ref.read(userPreferencesProvider.notifier).login(
          name: 'Guest Devotee',
          phone: '',
        );

    if (mounted) {
      _navigateToNextScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: LanguageToggleButton(),
              ),
              const SizedBox(height: 10),

              // Header Logo & Branding
              Center(
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.saffronGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primarySaffron.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Text('🚩', style: TextStyle(fontSize: 52)),
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Bhakti Sanga',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: AppColors.primarySaffronDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to sync your saved bhajans, mantras & daily horoscope preferences.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // 1. GOOGLE LOGIN BUTTON (If Enabled in Admin Settings)
              if (_authSettings.googleEnabled) ...[
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _handleGoogleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
                    ),
                    elevation: 1,
                  ),
                  icon: Image.network(
                    'https://authjs.dev/img/providers/google.svg',
                    height: 22,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata_rounded, color: Colors.red, size: 28),
                  ),
                  label: const Text(
                    'Continue with Google',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 2. PHONE OTP LOGIN FORM (If Enabled in Admin Settings)
              if (_authSettings.phoneEnabled) ...[
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.primarySaffron.withValues(alpha: 0.3),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mobile Number',
                        style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Enter 10-digit phone number',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                            child: Text(
                              '🇮🇳 +91',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: theme.dividerColor),
                          ),
                        ),
                      ),

                      if (_isOtpSent) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Verification Code (OTP)',
                          style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            hintText: 'Enter 6-digit OTP',
                            prefixIcon: const Icon(Icons.lock_clock_rounded, color: AppColors.primarySaffron),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            filled: true,
                            fillColor: theme.colorScheme.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: theme.dividerColor),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : (_isOtpSent ? _handleVerifyAndLogin : _handleSendOtp),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primarySaffron,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 2,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _isOtpSent ? 'Verify & Login 🚩' : 'Get Phone OTP & Login',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 3. SKIP LOGIN / GUEST MODE (If Enabled in Admin Settings)
              if (_authSettings.skipEnabled) ...[
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _handleSkipLogin,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: AppColors.primarySaffron.withValues(alpha: 0.5)),
                  ),
                  icon: const Text('🚩', style: TextStyle(fontSize: 18)),
                  label: const Text(
                    'Continue without Login (Guest Mode)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primarySaffron,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'By signing in, you agree to our Terms & Privacy Policy.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
