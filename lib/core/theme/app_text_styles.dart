import 'package:flutter/material.dart';
import 'app_colors.dart';

/// ========================================
/// APP TEXT STYLES - SiBunda Text Styles
/// Matching repo lama fonts.dart
/// ========================================
class AppTextStyles {
  AppTextStyles._();

  // Base font family (Nunito from repo lama)
  static const String fontFamily = 'Nunito';

  // ========================================
  // HEADERS (from repo lama)
  // ========================================
  static const TextStyle header1 = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: AppColors.black,
  );

  static const TextStyle header2 = TextStyle(
    fontSize: 23,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  static const TextStyle header3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  // ========================================
  // SIZE VARIANTS (from repo lama)
  // ========================================
  static const TextStyle size0 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );

  static const TextStyle size1 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );

  static const TextStyle size2 = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );

  static const TextStyle sizeMin1 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );

  static const TextStyle sizeMin2 = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );

  // ========================================
  // COLOR VARIANTS
  // ========================================
  static TextStyle get regularGrey => size0.copyWith(color: AppColors.grey);

  static TextStyle get regularPrimary => size0.copyWith(color: AppColors.primary);

  static TextStyle get boldBlack => size0.copyWith(fontWeight: FontWeight.bold);

  static TextStyle get boldPrimary => size0.copyWith(
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  // ========================================
  // BUTTON STYLES
  // ========================================
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // ========================================
  // FORM STYLES
  // ========================================
  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.black,
  );

  static const TextStyle inputText = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.black,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.grey,
  );

  static TextStyle get inputError => sizeMin1.copyWith(color: AppColors.error);

  // ========================================
  // HOME PAGE STYLES (matching repo lama)
  // ========================================
  static TextStyle get size0Bold => size0.copyWith(fontWeight: FontWeight.bold);

  static TextStyle get size0BoldColorPrimary => size0.copyWith(
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static TextStyle get sizeMin1BoldColorPrimary => sizeMin1.copyWith(
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
  );

  static TextStyle get sizeMin1ColorPrimary => sizeMin1.copyWith(
    color: AppColors.primary,
  );

  static TextStyle get sizeMin2ColorPrimary => sizeMin2.copyWith(
    color: AppColors.primary,
  );

  static TextStyle get sizePlus2ColorOnPrimary => TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );
}
