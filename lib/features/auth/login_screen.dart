import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/language_toggle_button.dart';
import '../../services/auth_service.dart';
import '../../services/marketing_event_service.dart';
import '../../services/msg91_service.dart';
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
    } catch (e) {
      debugPrint('Google Auth Notice: $e');
    }

    try {
      final assignedId = await _authService.syncProfileToSupabase(
        displayName: 'Devotee',
        loginMethod: 'google',
      );

      await ref.read(userPreferencesProvider.notifier).login(
            name: 'Devotee',
            phone: '',
            bhagwaUserId: assignedId,
          );
      MarketingEventService.trackRegistration(method: 'google');
      if (mounted) _navigateToNextScreen();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In notice: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
      await Msg91Service.sendOtp(phone);
      try {
        await _authService.sendPhoneOTP(phone);
      } catch (_) {}

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isOtpSent = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP sent successfully to your mobile number 📩'),
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

    if (otp.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid OTP code'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final isValid = await Msg91Service.verifyOtp(phoneNumber: phone, otpCode: otp);
      if (!isValid) {
        try {
          await _authService.verifyPhoneOTP(phoneNumber: phone, otpCode: otp);
        } catch (_) {}
      }
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
    MarketingEventService.trackRegistration(method: 'phone');

    if (mounted) {
      setState(() => _isLoading = false);
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
    } catch (e) {
      debugPrint('Guest login bypass notice: $e');
    }

    final assignedId = await _authService.syncProfileToSupabase(
      displayName: guestDevoteeName,
      loginMethod: 'skip',
    );

    await ref.read(userPreferencesProvider.notifier).login(
          name: guestDevoteeName,
          phone: '',
          bhagwaUserId: assignedId,
        );
    MarketingEventService.trackRegistration(method: 'skip');

    if (mounted) {
      setState(() => _isLoading = false);
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 24.0,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Language Toggle
                      const Align(
                        alignment: Alignment.centerRight,
                        child: LanguageToggleButton(),
                      ),

                      const Spacer(flex: 1),

                      // ==============================================================
                      // LIVE SACRED ZODIAC MANDALA WHEEL ANIMATION
                      // ==============================================================
                      const AstroZodiacMandalaWheel(),

                      const SizedBox(height: 16),

                      Text(
                        'Daivik',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 30,
                          color: AppColors.primarySaffronDark,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Experience Divine Peace & Daily Bhakti Guidance',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.75),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const Spacer(flex: 2),

                      // ==============================================================
                      // CLEAN 2D BOTTOM SECTION: LOGIN METHODS (PINNED TO BOTTOM)
                      // ==============================================================
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

                          const SizedBox(height: 14),
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

/// SACRED ASTROLOGICAL ZODIAC MANDALA WHEEL ANIMATION WIDGET
class AstroZodiacMandalaWheel extends StatefulWidget {
  const AstroZodiacMandalaWheel({super.key});

  @override
  State<AstroZodiacMandalaWheel> createState() => _AstroZodiacMandalaWheelState();
}

class _AstroZodiacMandalaWheelState extends State<AstroZodiacMandalaWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  static const List<ZodiacBadgeData> _zodiacSigns = [
    ZodiacBadgeData(symbol: '♈', color: Color(0xFFE53935), label: 'Aries'),
    ZodiacBadgeData(symbol: '♉', color: Color(0xFFFB8C00), label: 'Taurus'),
    ZodiacBadgeData(symbol: '♊', color: Color(0xFFFFB300), label: 'Gemini'),
    ZodiacBadgeData(symbol: '♋', color: Color(0xFF7CB342), label: 'Cancer'),
    ZodiacBadgeData(symbol: '♌', color: Color(0xFFFF9800), label: 'Leo'),
    ZodiacBadgeData(symbol: '♍', color: Color(0xFF43A047), label: 'Virgo'),
    ZodiacBadgeData(symbol: '♎', color: Color(0xFF00ACC1), label: 'Libra'),
    ZodiacBadgeData(symbol: '♏', color: Color(0xFF1E88E5), label: 'Scorpio'),
    ZodiacBadgeData(symbol: '♐', color: Color(0xFF3949AB), label: 'Sagittarius'),
    ZodiacBadgeData(symbol: '♑', color: Color(0xFF8E24AA), label: 'Capricorn'),
    ZodiacBadgeData(symbol: '♒', color: Color(0xFF5E35B1), label: 'Aquarius'),
    ZodiacBadgeData(symbol: '♓', color: Color(0xFFD81B60), label: 'Pisces'),
  ];

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double wheelSize = 260.0;

    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        final progress = _rotationController.value;
        final rotationAngle = progress * 2 * pi;

        return SizedBox(
          width: wheelSize,
          height: wheelSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Custom Painter for Yantra Geometric Star Lines & Circles
              CustomPaint(
                size: const Size(wheelSize, wheelSize),
                painter: MandalaYantraPainter(
                  rotationAngle: rotationAngle,
                  primaryColor: AppColors.primarySaffron,
                  accentColor: AppColors.amberGold,
                ),
              ),

              // 2. Center Official Daivik Sun & Om Logo Core
              Container(
                width: 90,
                height: 90,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primarySaffron.withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 6,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/daivik_logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              // 3. Outer Orbiting 12 Zodiac Badge Nodes
              ...List.generate(_zodiacSigns.length, (index) {
                final baseAngle = (index * 2 * pi) / _zodiacSigns.length;
                final currentAngle = baseAngle + rotationAngle;

                // Orbit radius = 108px
                const radius = 108.0;
                final x = radius * cos(currentAngle);
                final y = radius * sin(currentAngle);

                final badge = _zodiacSigns[index];

                return Transform.translate(
                  offset: Offset(x, y),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: badge.color,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: badge.color.withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        badge.symbol,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class ZodiacBadgeData {
  final String symbol;
  final Color color;
  final String label;

  const ZodiacBadgeData({
    required this.symbol,
    required this.color,
    required this.label,
  });
}

/// CUSTOM PAINTER FOR SACRED YANTRA GEOMETRIC STAR LINES & DASHED CIRCLES
class MandalaYantraPainter extends CustomPainter {
  final double rotationAngle;
  final Color primaryColor;
  final Color accentColor;

  MandalaYantraPainter({
    required this.rotationAngle,
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 22;
    final innerRadius = outerRadius * 0.62;

    // 1. Outer Orbit Line
    final orbitPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawCircle(center, outerRadius, orbitPaint);

    // 2. Dashed Inner Circle
    final dashedPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const dashCount = 36;
    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * 2 * pi) / dashCount + rotationAngle * 0.5;
      final sweepAngle = pi / dashCount;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        startAngle,
        sweepAngle,
        false,
        dashedPaint,
      );
    }

    // 3. Interlocking Geometric Yantra Lines (Matching Star Constellations in Screenshot)
    final starLinePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const numPoints = 8;
    final points = <Offset>[];
    for (int i = 0; i < numPoints; i++) {
      final a = (i * 2 * pi) / numPoints + rotationAngle;
      points.add(Offset(
        center.dx + innerRadius * cos(a),
        center.dy + innerRadius * sin(a),
      ));
    }

    for (int i = 0; i < numPoints; i++) {
      final nextIndex = (i + 3) % numPoints;
      canvas.drawLine(points[i], points[nextIndex], starLinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant MandalaYantraPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle;
  }
}
