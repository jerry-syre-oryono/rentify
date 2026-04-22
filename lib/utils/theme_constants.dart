import 'package:flutter/material.dart';

/// Premium Gold Theme Colors - Luxury Rental App
class RentifyTheme {
  // Primary Colors
  static const Color goldPrimary = Color(0xFFD4AF37); // Luxury Gold
  static const Color deepSlate = Color(0xFF2C3E50); // Deep Slate
  static const Color skyBlue = Color(0xFF3498DB); // Sky Blue Accent
  
  // Background Colors
  static const Color lightBg = Color(0xFFFAFBFC); // Light Background
  static const Color darkBg = Color(0xFF1B1B1B); // Warm Black Dark
  
  // Semantic Colors
  static const Color success = Color(0xFF06A77D); // Teal Success
  static const Color error = Color(0xFFE63946); // Red Danger
  static const Color warning = Color(0xFFF7931E); // Orange Warning
  static const Color info = Color(0xFF3498DB); // Blue Info
  
  // Neutral Colors
  static const Color textDark = Color(0xFF2C3E50);
  static const Color textLight = Color(0xFFB0B0B0);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF334155);
  
  // Shadow Color
  static const Color shadow = Color(0x1A000000); // 10% black shadow
  
  // Gradient Colors
  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldPrimary, Color(0xFFE6C200)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [goldPrimary, skyBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

/// Animation Durations - Consistent across app
class AnimationDurations {
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration slow = Duration(milliseconds: 800);
  static const Duration verySlow = Duration(milliseconds: 1200);
}

/// Curve Presets - Premium animations
class AnimationCurves {
  static const Curve easeInOutGold = Curves.easeInOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOutQuad;
  static const Curve snappy = Curves.easeOutCubic;
}
