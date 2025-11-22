import '../constants/string_constants.dart';

/// ========================================
/// VALIDATORS - SiBunda Form Validators
/// Centralized validation logic
/// ========================================
class Validators {
  Validators._();

  // ========================================
  // CONSTANTS
  // ========================================
  static const int minPasswordLength = 6;
  static const int minNameLength = 3;

  // Email regex pattern
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Name regex (letters, spaces, apostrophes, hyphens)
  static final RegExp _nameRegex = RegExp(r"^[a-zA-Z\s'\-]+$");

  // Phone regex (Indonesia format)
  static final RegExp _phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{9,12}$');

  // ========================================
  // EMAIL VALIDATOR
  // ========================================
  /// Validates email format
  /// Returns error message or null if valid
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldCanNotBeEmpty;
    }

    if (!_emailRegex.hasMatch(value.trim())) {
      return AppStrings.pleaseTypeCorrectEmail;
    }

    return null;
  }

  /// Validates email but allows empty (for real-time validation)
  static String? emailOptional(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Allow empty during typing
    }

    if (!_emailRegex.hasMatch(value.trim())) {
      return AppStrings.pleaseTypeCorrectEmail;
    }

    return null;
  }

  // ========================================
  // PASSWORD VALIDATORS
  // ========================================
  /// Validates password (required, min 6 chars)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldCanNotBeEmpty;
    }

    if (value.length < minPasswordLength) {
      return AppStrings.passwordMinLength;
    }

    return null;
  }

  /// Validates password confirmation
  static String? passwordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldCanNotBeEmpty;
    }

    if (value != password) {
      return AppStrings.passwordReDoesNotMatch;
    }

    return null;
  }

  // ========================================
  // NAME VALIDATOR
  // ========================================
  /// Validates name (required, min 3 chars, letters only)
  static String? name(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldCanNotBeEmpty;
    }

    if (value.trim().length < minNameLength) {
      return AppStrings.nameMinLength;
    }

    if (!_nameRegex.hasMatch(value.trim())) {
      return AppStrings.nameOnlyLetters;
    }

    return null;
  }

  // ========================================
  // REQUIRED FIELD VALIDATOR
  // ========================================
  /// Generic required field validator
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.fieldCanNotBeEmpty;
    }
    return null;
  }

  // ========================================
  // PHONE NUMBER VALIDATOR
  // ========================================
  /// Validates Indonesian phone number format
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldCanNotBeEmpty;
    }

    // Remove spaces and dashes
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');

    if (!_phoneRegex.hasMatch(cleanValue)) {
      return AppStrings.invalidPhoneFormat;
    }

    return null;
  }

  // ========================================
  // NUMERIC VALIDATORS
  // ========================================
  /// Validates age (0-150)
  static String? age(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldCanNotBeEmpty;
    }

    final age = int.tryParse(value);
    if (age == null) {
      return 'Usia harus berupa angka';
    }

    if (age < 0 || age > 150) {
      return 'Usia tidak valid';
    }

    return null;
  }

  /// Validates pregnancy week (1-42)
  static String? pregnancyWeek(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldCanNotBeEmpty;
    }

    final week = int.tryParse(value);
    if (week == null) {
      return 'Minggu kehamilan harus berupa angka';
    }

    if (week < 1 || week > 42) {
      return 'Minggu kehamilan harus antara 1-42';
    }

    return null;
  }

  /// Validates weight in kg (0-500)
  static String? weight(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldCanNotBeEmpty;
    }

    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Berat badan harus berupa angka';
    }

    if (weight < 0 || weight > 500) {
      return 'Berat badan tidak valid';
    }

    return null;
  }

  /// Validates height in cm (0-300)
  static String? height(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldCanNotBeEmpty;
    }

    final height = double.tryParse(value);
    if (height == null) {
      return 'Tinggi badan harus berupa angka';
    }

    if (height < 0 || height > 300) {
      return 'Tinggi badan tidak valid';
    }

    return null;
  }

  // ========================================
  // DATE VALIDATORS
  // ========================================
  /// Validates birth date
  static String? birthDate(DateTime? value) {
    if (value == null) {
      return AppStrings.fieldCanNotBeEmpty;
    }

    final now = DateTime.now();

    if (value.isAfter(now)) {
      return 'Tanggal lahir tidak valid';
    }

    final age = now.year - value.year;
    if (age > 150) {
      return 'Tanggal lahir tidak valid';
    }

    return null;
  }

  // ========================================
  // LENGTH VALIDATORS
  // ========================================
  /// Validates minimum length
  static String? minLength(String? value, int min, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldCanNotBeEmpty;
    }

    if (value.length < min) {
      return '${fieldName ?? 'Field'} minimal $min karakter';
    }

    return null;
  }

  /// Validates maximum length
  static String? maxLength(String? value, int max, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return AppStrings.fieldCanNotBeEmpty;
    }

    if (value.length > max) {
      return '${fieldName ?? 'Field'} maksimal $max karakter';
    }

    return null;
  }

  // ========================================
  // HELPER METHODS
  // ========================================
  /// Check if email format is valid (without returning error message)
  static bool isValidEmail(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  /// Check if password meets requirements
  static bool isValidPassword(String password) {
    return password.length >= minPasswordLength;
  }

  /// Check if name meets requirements
  static bool isValidName(String name) {
    return name.trim().length >= minNameLength && _nameRegex.hasMatch(name.trim());
  }
}
