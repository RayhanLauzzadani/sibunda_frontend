import 'package:flutter/material.dart';

/// ========================================
/// COLORS - SiBunda Color Scheme
/// ========================================
class AppColors {
  // Pink Colors (Primary)
  static const Color pinkHighlight = Color(0xFFF383A1);
  static const Color pink100 = Color(0xFFF5517D);
  static const Color pink200 = Color(0xFFF13F6F);
  static const Color pink300 = Color(0xFFF53266); // Primary
  static const Color pink400 = Color(0xFFF82C62);
  static const Color pink500 = Color(0xFFF52159);

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

/// ========================================
/// TEXT THEME
/// ========================================
class AppTextTheme {
  static TextTheme textTheme = const TextTheme(
    displayLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.bold,
      color: AppColors.black,
    ),
    displayMedium: TextStyle(
      fontSize: 30,
      fontWeight: FontWeight.bold,
      color: AppColors.black,
    ),
    displaySmall: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.bold,
      color: AppColors.black,
    ),
    headlineLarge: TextStyle(
      fontSize: 25,
      fontWeight: FontWeight.bold,
      color: AppColors.black,
    ),
    headlineMedium: TextStyle(
      fontSize: 23,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
    headlineSmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.black,
    ),
    titleSmall: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.black,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: AppColors.black,
    ),
    bodyMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.normal,
      color: AppColors.black,
    ),
    bodySmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.normal,
      color: AppColors.black,
    ),
    labelLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    ),
    labelMedium: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: AppColors.black,
    ),
    labelSmall: TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: AppColors.black,
    ),
  );
}

/// ========================================
/// DIMENSIONS
/// ========================================
class AppDimens {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 20.0;
  static const double paddingXLarge = 24.0;

  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 20.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;
}

/// ========================================
/// MAIN THEME
/// ========================================
class AppTheme {
  // Colors
  static const Color primaryColor = AppColors.pink300;
  static const Color secondaryColor = AppColors.pink400;
  static const Color backgroundColor = AppColors.white;
  static const Color surfaceColor = AppColors.white;
  static const Color errorColor = AppColors.error;

  // Text Theme
  static TextTheme textTheme = AppTextTheme.textTheme;

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      surface: surfaceColor,
      background: backgroundColor,
    ),
    primaryColor: primaryColor,
    primarySwatch: AppColors.pinkSwatch,
    scaffoldBackgroundColor: backgroundColor,

    // App Bar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.white),
    ),

    // Text Theme
    textTheme: textTheme,

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.greyCalmer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        borderSide: const BorderSide(color: errorColor, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        borderSide: const BorderSide(color: errorColor, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimens.paddingLarge,
        vertical: AppDimens.paddingMedium,
      ),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: AppColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimens.paddingXLarge,
          vertical: AppDimens.paddingMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // Card Theme
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusMedium),
      ),
      color: AppColors.white,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.black,
      size: AppDimens.iconSizeMedium,
    ),
  );

  // Dark Theme (optional - untuk future)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
    ),
    primaryColor: primaryColor,
    scaffoldBackgroundColor: AppColors.black,
    textTheme: textTheme.apply(
      bodyColor: AppColors.white,
      displayColor: AppColors.white,
    ),
  );
}
