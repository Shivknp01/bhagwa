import 'package:flutter/material.dart';

class AppColors {
  // Saffron & Warm Accents
  static const Color primarySaffron = Color(0xFFFF6D00); // Vibrant Saffron
  static const Color primarySaffronLight = Color(0xFFFF9E40);
  static const Color primarySaffronDark = Color(0xFFD84315);

  static const Color amberGold = Color(0xFFFFB300);
  static const Color deepMaroon = Color(0xFF880E4F);
  static const Color sacredRed = Color(0xFFD50000);
  static const Color spiritualPurple = Color(0xFF4A148C);
  static const Color peacockBlue = Color(0xFF006064);

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFFBF8F3); // Warm sacred cream
  static const Color lightSurface = Color(0xFFFFFDF9);
  static const Color lightSurfaceSecondary = Color(0xFFF7F1E5);
  static const Color lightTextPrimary = Color(0xFF231C14);
  static const Color lightTextSecondary = Color(0xFF6E6354);
  static const Color lightBorder = Color(0xFFEADBCA);

  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF14100C); // Deep midnight warm black
  static const Color darkSurface = Color(0xFF1F1A15);
  static const Color darkSurfaceSecondary = Color(0xFF2D251D);
  static const Color darkTextPrimary = Color(0xFFF7F3EB);
  static const Color darkTextSecondary = Color(0xFFABA092);
  static const Color darkBorder = Color(0xFF3B3227);

  // Card Gradients & Visual Tokens
  static const LinearGradient saffronGradient = LinearGradient(
    colors: [Color(0xFFFF6D00), Color(0xFFFF9100)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldenGradient = LinearGradient(
    colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sacredSunriseGradient = LinearGradient(
    colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF26211C), Color(0xFF1A1714)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Category Specific Sacred Gradients
  static const LinearGradient allCategoryGradient = LinearGradient(
    colors: [Color(0xFFFF6D00), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient wallpaperGradient = LinearGradient(
    colors: [Color(0xFFC2185B), Color(0xFFF44336)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bhajanGradient = LinearGradient(
    colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient musicGradient = LinearGradient(
    colors: [Color(0xFF006064), Color(0xFF00838F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient ringtoneGradient = LinearGradient(
    colors: [Color(0xFF4A148C), Color(0xFF7B1FA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mantraGradient = LinearGradient(
    colors: [Color(0xFFBF360C), Color(0xFFE65100)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient stutiGradient = LinearGradient(
    colors: [Color(0xFF880E4F), Color(0xFFAD1457)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient horoscopeGradient = LinearGradient(
    colors: [Color(0xFF1A237E), Color(0xFF3F51B5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient statusGradient = LinearGradient(
    colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
