import 'dart:math';
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
    final settings = await _authService.fetchAuthSettings();
    if (mounted) {
      setState(() {
        _authSettings = settings;
      });
    }

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
    } catch (_) {}

    final assignedId = await _authService.syncProfileToSupabase(
      displayName: 'Devotee',
      loginMethod: 'google',
    );

    await ref.read(userPreferencesProvider.notifier).login(
          name: 'Devotee',
          phone: '',
          bhagwaUserId: assignedId,
        );
    if (mounted) _navigateToNextScreen();
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
        setState(() => _isOtpSent = true);
      }
    }
  }

  Future<void> _handleVerifyAndLogin() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final otp = _otpController.text.trim();
    final displayName = name.isNotEmpty ? name : 'Devotee';

    setState(() => _isLoading = true);
    try {
      await _authService.verifyPhoneOTP(phoneNumber: phone, otpCode: otp);
    } catch (_) {}

    final assignedId = await _authService.syncProfileToSupabase(
      displayName: displayName,
      phone: '+91 $phone',
      loginMethod: 'phone',
    );

    await ref.read(userPreferencesProvider.notifier).login(
          name: displayName,
          phone: '+91 $phone',
          bhagwaUserId: assignedId,
        );

    if (mounted) {
      _navigateToNextScreen();
    }
  }

  Future<void> _handleSkipLogin() async {
    setState(() => _isLoading = true);

    const mythologicalNames = [
      'Shiv_Bhakta',
      'Ram_Bhakta',
      'Hanuman_Sevak',
      'Krishna_Prem',
      'Mahakal_Bhakta',
      'Narayan_Bhakta',
      'Durga_Bhakta',
      'Ganesh_Bhakta'
    ];
    final randomPrefix = mythologicalNames[Random().nextInt(mythologicalNames.length)];
    final randomId = 100 + Random().nextInt(900);
    final guestDevoteeName = '${randomPrefix}_$randomId';

    try {
      await _authService.signInAnonymously();
    } catch (_) {}

    final assignedId = await _authService.syncProfileToSupabase(
      displayName: guestDevoteeName,
      loginMethod: 'skip',
    );

    await ref.read(userPreferencesProvider.notifier).login(
          name: guestDevoteeName,
          phone: '',
          bhagwaUserId: assignedId,
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32.0,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Bar with Language Toggle
                      const Align(
                        alignment: Alignment.centerRight,
                        child: LanguageToggleButton(),
                      ),

                      // Flexible top space to position branding nicely
                      const Spacer(flex: 1),

                      // Header Logo & Branding
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.saffronGradient,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primarySaffron.withValues(alpha: 0.25),
                                blurRadius: 18,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Text('🚩', style: TextStyle(fontSize: 42)),
                        ),
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Daivik',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: AppColors.primarySaffronDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Experience Divine Peace & Daily Bhakti',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Spacer pushing login methods to bottom
                      const Spacer(flex: 2),

                      // BOTTOM SECTION: Login Methods stuck to bottom
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // 1. GOOGLE LOGIN BUTTON
                          if (_authSettings.googleEnabled) ...[
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _handleGoogleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.surface,
                                foregroundColor: theme.textTheme.bodyLarge?.color,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(color: theme.dividerColor, width: 1),
                                ),
                                elevation: 0.5,
                              ),
                              icon: Image.network(
                                'https://authjs.dev/img/providers/google.svg',
                                height: 20,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.g_mobiledata_rounded, color: Colors.red, size: 24),
                              ),
                              label: const Text(
                                'Continue with Google',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // 2. PHONE OTP LOGIN FORM
                          if (_authSettings.phoneEnabled) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppColors.primarySaffron.withValues(alpha: 0.25),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Mobile Number',
                                    style: theme.textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(fontSize: 14),
                                    decoration: InputDecoration(
                                      hintText: 'Enter 10-digit phone number',
                                      hintStyle: const TextStyle(fontSize: 13),
                                      prefixIcon: const Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                        child: Text(
                                          '🇮🇳 +91',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                      filled: true,
                                      fillColor: theme.colorScheme.surface,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: theme.dividerColor),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: theme.dividerColor),
                                      ),
                                    ),
                                  ),

                                  if (_isOtpSent) ...[
                                    const SizedBox(height: 10),
                                    Text(
                                      'Verification Code (OTP)',
                                      style: theme.textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _otpController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 6,
                                      style: const TextStyle(fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: 'Enter 6-digit OTP',
                                        hintStyle: const TextStyle(fontSize: 13),
                                        prefixIcon: const Icon(Icons.lock_clock_rounded, color: AppColors.primarySaffron, size: 20),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        filled: true,
                                        fillColor: theme.colorScheme.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: theme.dividerColor),
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 12),

                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : (_isOtpSent ? _handleVerifyAndLogin : _handleSendOtp),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primarySaffron,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        elevation: 1,
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              height: 18,
                                              width: 18,
                                              child: CircularProgressIndicator(
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              _isOtpSent ? 'Verify & Login 🚩' : 'Get Phone OTP & Login',
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // 3. SKIP LOGIN GUEST MODE BUTTON
                          if (_authSettings.skipEnabled) ...[
                            OutlinedButton.icon(
                              onPressed: _isLoading ? null : _handleSkipLogin,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                side: BorderSide(color: AppColors.primarySaffron.withValues(alpha: 0.5)),
                              ),
                              icon: const Text('🚩', style: TextStyle(fontSize: 16)),
                              label: const Text(
                                'Continue without Login (Guest Mode)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primarySaffron,
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),
                          const Center(
                            child: Text(
                              'By signing in, you agree to our Terms & Privacy Policy.',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
