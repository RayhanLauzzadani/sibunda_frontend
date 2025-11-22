import 'package:flutter/material.dart';

/// ========================================
/// APP COLORS - SiBunda Color Scheme
/// Extracted from repo lama color.dart
/// ========================================
class AppColors {
  AppColors._();

  // Pink Colors (Primary)
  static const Color pinkHighlight = Color(0xFFF383A1);
  static const Color pink100 = Color(0xFFF5517D);
  static const Color pink200 = Color(0xFFF13F6F);
  static const Color pink300 = Color(0xFFF53266); // Primary
  static const Color pink400 = Color(0xFFF82C62);
  static const Color pink500 = Color(0xFFF52159);

  // Primary alias
  static const Color primary = pink300;
  static const Color primaryLight = pinkHighlight;
  static const Color primaryDark = pink500;

  // Base Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFADADAD);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Semantic Colors
  static const Color error = Color(0xFFB00020);
  static const Color redWarning = Color(0xFFF6EBEB);
  static const Color greenCalm = Color(0xFF3E9D9D);
  static const Color greenSafe = Color(0xFFD0F1BB);
  static const Color yellow = Color(0xFFFBD460);
  static const Color greyCalm = Color(0xFFEBEFF6);
  static const Color greyCalmer = Color(0xFFF6F7F9);

  // Icon color (from register screen)
  static const Color iconGrey = Color(0xFF9A9A9A);

  // Material Swatch
  static const MaterialColor pinkSwatch = MaterialColor(
    0xFFF53266,
    <int, Color>{
      50: Color(0xFFFEE5ED),
      100: Color(0xFFFDBFD2),
      200: Color(0xFFF594B5),
      300: Color(0xFFF53266),
      400: Color(0xFFF82C62),
      500: Color(0xFFF52159),
      600: Color(0xFFF51B54),
      700: Color(0xFFF5134E),
      800: Color(0xFFE20D44),
      900: Color(0xFFBF0B3A),
    },
  );
}
