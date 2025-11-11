class Validators {
  // Email validator
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email tidak boleh kosong';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Format email tidak valid';
    }

    return null;
  }

  // Required field validator
  static String? required(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Field'} tidak boleh kosong';
    }
    return null;
  }

  // Password validator
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }

    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }

    return null;
  }

  // Password confirmation validator
  static String? passwordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }

    if (value != password) {
      return 'Password tidak cocok';
    }

    return null;
  }

  // Phone number validator (Indonesia format)
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon tidak boleh kosong';
    }

    // Remove spaces and dashes
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');

    // Check if starts with +62, 62, or 0
    final phoneRegex = RegExp(r'^(\+62|62|0)[0-9]{9,12}$');

    if (!phoneRegex.hasMatch(cleanValue)) {
      return 'Format nomor telepon tidak valid';
    }

    return null;
  }

  // Name validator (allow letters, spaces, and some special chars)
  static String? name(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Nama'} tidak boleh kosong';
    }

    if (value.trim().length < 2) {
      return '${fieldName ?? 'Nama'} minimal 2 karakter';
    }

    // Allow letters (including Indonesian chars), spaces, apostrophes, and hyphens
    final nameRegex = RegExp(r"^[a-zA-Z\s'\-]+$");

    if (!nameRegex.hasMatch(value.trim())) {
      return '${fieldName ?? 'Nama'} hanya boleh berisi huruf';
    }

    return null;
  }

  // Age validator
  static String? age(String? value) {
    if (value == null || value.isEmpty) {
      return 'Usia tidak boleh kosong';
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

  // Date validator (for birth date)
  static String? birthDate(DateTime? value) {
    if (value == null) {
      return 'Tanggal lahir tidak boleh kosong';
    }

    final now = DateTime.now();
    final age = now.year - value.year;

    if (value.isAfter(now)) {
      return 'Tanggal lahir tidak valid';
    }

    if (age > 150) {
      return 'Tanggal lahir tidak valid';
    }

    return null;
  }

  // Pregnancy week validator
  static String? pregnancyWeek(String? value) {
    if (value == null || value.isEmpty) {
      return 'Minggu kehamilan tidak boleh kosong';
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

  // Weight validator (in kg)
  static String? weight(String? value) {
    if (value == null || value.isEmpty) {
      return 'Berat badan tidak boleh kosong';
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

  // Height validator (in cm)
  static String? height(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tinggi badan tidak boleh kosong';
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

  // General number validator
  static String? number(String? value, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Field'} tidak boleh kosong';
    }

    if (double.tryParse(value) == null) {
      return '${fieldName ?? 'Field'} harus berupa angka';
    }

    return null;
  }

  // Min length validator
  static String? minLength(String? value, int minLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Field'} tidak boleh kosong';
    }

    if (value.length < minLength) {
      return '${fieldName ?? 'Field'} minimal $minLength karakter';
    }

    return null;
  }

  // Max length validator
  static String? maxLength(String? value, int maxLength, {String? fieldName}) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Field'} tidak boleh kosong';
    }

    if (value.length > maxLength) {
      return '${fieldName ?? 'Field'} maksimal $maxLength karakter';
    }

    return null;
  }
}
