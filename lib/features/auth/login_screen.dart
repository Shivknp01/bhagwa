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

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  RealtimeChannel? _realtimeChannel;

  final TextEditingController _nameController = TextEditingController(text: 'Aditya Sharma');
  final TextEditingController _phoneController = TextEditingController(text: '9876543210');
  final TextEditingController _otpController = TextEditingController(text: '123456');

  bool _isOtpSent = false;
  bool _isLoading = false;

  AuthSettings _authSettings = const AuthSettings();

  // 3D Interactive Parallax Tilt Controller
  double _tiltX = 0.0;
  double _tiltY = 0.0;

  // 3D Floating Levitation Animation
  late AnimationController _levitateController;
  late Animation<double> _levitateAnim;

  @override
  void initState() {
    super.initState();
    _initAuthSettingsAndRealtime();

    _levitateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _levitateAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
      CurvedAnimation(parent: _levitateController, curve: Curves.easeInOutSine),
    );
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
    _levitateController.dispose();
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

  void _onPanUpdate(DragUpdateDetails details, Size screenSize) {
    final dx = details.localPosition.dx - screenSize.width / 2;
    final dy = details.localPosition.dy - screenSize.height / 2;
    setState(() {
      _tiltY = (dx / (screenSize.width / 2)).clamp(-1.0, 1.0) * 0.18;
      _tiltX = (-dy / (screenSize.height / 2)).clamp(-1.0, 1.0) * 0.18;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _tiltX = 0.0;
      _tiltY = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0906), // Deep Divine 3D Space Theme
      body: GestureDetector(
        onPanUpdate: (d) => _onPanUpdate(d, screenSize),
        onPanEnd: _onPanEnd,
        child: Stack(
          children: [
            // 1. Ambient 3D Glowing Background Orbs
            Positioned(
              top: -100,
              left: -50,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primarySaffron.withValues(alpha: 0.25),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primarySaffron.withValues(alpha: 0.4),
                      blurRadius: 90,
                      spreadRadius: 40,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -50,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.amberGold.withValues(alpha: 0.2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.amberGold.withValues(alpha: 0.35),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),

            // 2. Levitating 3D Devotional Icons in Parallax Depth
            AnimatedBuilder(
              animation: _levitateAnim,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: 70 + _levitateAnim.value,
                      left: 30,
                      child: const Text('🔱', style: TextStyle(fontSize: 34, shadows: [Shadow(color: Colors.amber, blurRadius: 20)])),
                    ),
                    Positioned(
                      top: 130 - _levitateAnim.value,
                      right: 35,
                      child: const Text('🪔', style: TextStyle(fontSize: 32, shadows: [Shadow(color: Colors.orange, blurRadius: 20)])),
                    ),
                    Positioned(
                      bottom: 120 + _levitateAnim.value,
                      left: 25,
                      child: const Text('🦚', style: TextStyle(fontSize: 34, shadows: [Shadow(color: Colors.cyan, blurRadius: 20)])),
                    ),
                    Positioned(
                      bottom: 80 - _levitateAnim.value,
                      right: 30,
                      child: const Text('☸️', style: TextStyle(fontSize: 30, shadows: [Shadow(color: Colors.amberAccent, blurRadius: 18)])),
                    ),
                  ],
                );
              },
            ),

            // 3. Main Interactive 3D Card Stage
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                  child: Column(
                    children: [
                      // Top Bar with Language Toggle
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                          ),
                          child: const LanguageToggleButton(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Interactive 3D Perspective Card
                      TweenAnimationBuilder<Matrix4>(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOutCubic,
                        tween: Matrix4Tween(
                          begin: Matrix4.identity(),
                          end: Matrix4.identity()
                            ..setEntry(3, 2, 0.0012)
                            ..rotateX(_tiltX)
                            ..rotateY(_tiltY),
                        ),
                        builder: (context, transformMatrix, child) {
                          return Transform(
                            transform: transformMatrix,
                            alignment: Alignment.center,
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B110B).withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: AppColors.primarySaffron.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primarySaffron.withValues(alpha: 0.3),
                                blurRadius: 36,
                                spreadRadius: -4,
                                offset: Offset(-_tiltY * 40, _tiltX * 40 + 12),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.8),
                                blurRadius: 40,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // 3D Glowing Logo Sphere
                              Center(
                                child: AnimatedBuilder(
                                  animation: _levitateAnim,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, _levitateAnim.value * 0.4),
                                      child: Container(
                                        padding: const EdgeInsets.all(24),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: AppColors.saffronGradient,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primarySaffron.withValues(alpha: 0.5),
                                              blurRadius: 30,
                                              spreadRadius: 4,
                                              offset: const Offset(0, 8),
                                            ),
                                          ],
                                        ),
                                        child: const Text('🚩', style: TextStyle(fontSize: 48)),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 24),

                              Text(
                                'Daivik',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 34,
                                  color: Colors.white,
                                  letterSpacing: 0.8,
                                  shadows: [
                                    Shadow(
                                      color: AppColors.primarySaffron.withValues(alpha: 0.8),
                                      blurRadius: 18,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Experience Divine Peace & Daily Bhakti',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.75),
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 28),

                              // 1. GOOGLE 3D BUTTON (If Enabled in Admin Settings)
                              if (_authSettings.googleEnabled) ...[
                                _build3DButton(
                                  onPressed: _isLoading ? null : _handleGoogleLogin,
                                  bgColor: Colors.white,
                                  fgColor: Colors.black87,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.network(
                                        'https://authjs.dev/img/providers/google.svg',
                                        height: 22,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.g_mobiledata_rounded, color: Colors.red, size: 28),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Continue with Google',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // 2. PHONE OTP 3D CONTAINER (If Enabled in Admin Settings)
                              if (_authSettings.phoneEnabled) ...[
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: AppColors.primarySaffron.withValues(alpha: 0.35),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Mobile Number',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        style: const TextStyle(color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: 'Enter 10-digit phone number',
                                          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                                          prefixIcon: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                            child: Text(
                                              '🇮🇳 +91',
                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primarySaffron),
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                          filled: true,
                                          fillColor: Colors.white.withValues(alpha: 0.06),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(16),
                                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                                          ),
                                        ),
                                      ),

                                      if (_isOtpSent) ...[
                                        const SizedBox(height: 14),
                                        const Text(
                                          'Verification Code (OTP)',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        TextField(
                                          controller: _otpController,
                                          keyboardType: TextInputType.number,
                                          maxLength: 6,
                                          style: const TextStyle(color: Colors.white),
                                          decoration: InputDecoration(
                                            hintText: 'Enter 6-digit OTP',
                                            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                                            prefixIcon: const Icon(Icons.lock_clock_rounded, color: AppColors.primarySaffron),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                            filled: true,
                                            fillColor: Colors.white.withValues(alpha: 0.06),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                                            ),
                                          ),
                                        ),
                                      ],

                                      const SizedBox(height: 18),

                                      _build3DButton(
                                        onPressed: _isLoading
                                            ? null
                                            : (_isOtpSent ? _handleVerifyAndLogin : _handleSendOtp),
                                        bgColor: AppColors.primarySaffron,
                                        fgColor: Colors.white,
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
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // 3. SKIP LOGIN GUEST MODE 3D BUTTON (If Enabled in Admin Settings)
                              if (_authSettings.skipEnabled) ...[
                                _build3DButton(
                                  onPressed: _isLoading ? null : _handleSkipLogin,
                                  bgColor: Colors.white.withValues(alpha: 0.08),
                                  fgColor: AppColors.primarySaffron,
                                  borderColor: AppColors.primarySaffron.withValues(alpha: 0.6),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('🚩', style: TextStyle(fontSize: 18)),
                                      SizedBox(width: 10),
                                      Text(
                                        'Continue without Login (Guest)',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primarySaffron,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 24),
                              Center(
                                child: Text(
                                  'By signing in, you agree to our Terms & Privacy Policy.',
                                  style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DButton({
    required VoidCallback? onPressed,
    required Color bgColor,
    required Color fgColor,
    Color? borderColor,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: (borderColor ?? bgColor).withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: fgColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: borderColor ?? Colors.transparent, width: 1.2),
          ),
          elevation: 4,
        ),
        child: child,
      ),
    );
  }
}
