import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/constants/string_constants.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';

/// ========================================
/// REGISTER SCREEN - SiBunda
/// Clean Architecture Implementation
/// ========================================
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordReController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isPasswordReVisible = false;
  File? _profileImage;

  // Field-specific error messages (real-time validation)
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _passwordReError;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordReController.dispose();
    super.dispose();
  }

  // ========================================
  // VALIDATION METHODS (using Validators class)
  // ========================================

  void _validateName() {
    setState(() {
      _nameError = Validators.name(_nameController.text.trim());
    });
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    setState(() {
      // Use optional email validation during typing
      _emailError = email.isEmpty ? null : Validators.emailOptional(email);
    });
  }

  void _validatePassword() {
    setState(() {
      _passwordError = Validators.password(_passwordController.text);
      // Re-validate password confirmation when password changes
      if (_passwordReController.text.isNotEmpty) {
        _validatePasswordRe();
      }
    });
  }

  void _validatePasswordRe() {
    setState(() {
      _passwordReError = Validators.passwordConfirmation(
        _passwordReController.text,
        _passwordController.text,
      );
    });
  }

  // Check if form is valid for button state
  bool get _canSubmit {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final passwordRe = _passwordReController.text;

    return Validators.isValidName(name) &&
        Validators.isValidEmail(email) &&
        Validators.isValidPassword(password) &&
        password == passwordRe;
  }

  // ========================================
  // IMAGE PICKER
  // ========================================

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(AppStrings.pickImgCamera),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 75,
                );
                if (image != null) {
                  setState(() {
                    _profileImage = File(image.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppStrings.pickImgGallery),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 75,
                );
                if (image != null) {
                  setState(() {
                    _profileImage = File(image.path);
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ========================================
  // REGISTRATION HANDLER
  // ========================================

  Future<void> _handleRegister() async {
    // Validate all fields first
    _validateName();
    setState(() {
      _emailError = Validators.email(_emailController.text.trim());
    });
    _validatePassword();
    _validatePasswordRe();

    if (!_canSubmit) {
      return;
    }

    // Clear previous errors
    ref.read(authControllerProvider.notifier).clearError();

    // Attempt registration via provider
    final success = await ref.read(authControllerProvider.notifier).register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
      profileImage: _profileImage,
    );

    if (!mounted) return;

    if (success) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.registerSuccess),
          backgroundColor: AppColors.primary,
        ),
      );

      // Navigate to home (or login based on your flow)
      context.go(AppRoutes.home);
    }
    // Error is handled by watching authControllerProvider
  }

  // ========================================
  // BUILD METHOD
  // ========================================

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        iconTheme: const IconThemeData(color: AppColors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.screenPaddingH,
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Title
              Text(
                AppStrings.makeNewMotherAccount,
                style: AppTextStyles.header1,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              // Profile Image Picker
              GestureDetector(
                onTap: isLoading ? null : _pickImage,
                child: Container(
                  width: AppDimensions.profileImageSize,
                  height: AppDimensions.profileImageSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.greyCalmer,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: _profileImage != null
                      ? ClipOval(
                          child: Image.file(
                            _profileImage!,
                            fit: BoxFit.cover,
                            width: AppDimensions.profileImageSize,
                            height: AppDimensions.profileImageSize,
                          ),
                        )
                      : Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: AppColors.grey,
                        ),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                AppStrings.pickImg,
                style: AppTextStyles.sizeMin1.copyWith(color: AppColors.grey),
              ),

              const SizedBox(height: 30),

              // Name Field
              _buildTextField(
                controller: _nameController,
                labelText: AppStrings.name,
                hintText: 'Nama lengkap',
                prefixIcon: Icons.person_outline,
                errorText: _nameError,
                enabled: !isLoading,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) {
                  _validateName();
                },
              ),

              const SizedBox(height: 20),

              // Email Field
              _buildTextField(
                controller: _emailController,
                labelText: AppStrings.email,
                hintText: 'contoh@email.com',
                prefixIcon: Icons.email_outlined,
                errorText: _emailError,
                enabled: !isLoading,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) {
                  _validateEmail();
                },
              ),

              const SizedBox(height: 20),

              // Password Field
              _buildTextField(
                controller: _passwordController,
                labelText: AppStrings.password,
                hintText: 'Minimal 6 karakter',
                prefixIcon: Icons.lock_outline,
                errorText: _passwordError,
                enabled: !isLoading,
                obscureText: !_isPasswordVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? CupertinoIcons.eye_slash_fill
                        : CupertinoIcons.eye_fill,
                    color: AppColors.iconGrey,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
                onChanged: (_) {
                  _validatePassword();
                },
              ),

              const SizedBox(height: 20),

              // Password Confirmation Field
              _buildTextField(
                controller: _passwordReController,
                labelText: AppStrings.passwordRe,
                hintText: 'Ulangi password',
                prefixIcon: Icons.lock_outline,
                errorText: _passwordReError,
                enabled: !isLoading,
                obscureText: !_isPasswordReVisible,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordReVisible
                        ? CupertinoIcons.eye_slash_fill
                        : CupertinoIcons.eye_fill,
                    color: AppColors.iconGrey,
                    size: 22,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordReVisible = !_isPasswordReVisible;
                    });
                  },
                ),
                onChanged: (_) {
                  _validatePasswordRe();
                },
              ),

              const SizedBox(height: 10),

              // Error message from auth provider
              if (authState.errorMessage != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    color: AppColors.redWarning,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                  child: Text(
                    authState.errorMessage!,
                    style: AppTextStyles.sizeMin1.copyWith(color: AppColors.error),
                  ),
                ),

              const SizedBox(height: 30),

              // Submit Button (FAB like login screen)
              FloatingActionButton(
                onPressed: _canSubmit && !isLoading ? _handleRegister : null,
                backgroundColor: _canSubmit && !isLoading
                    ? AppColors.primary
                    : AppColors.grey,
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.white,
                      ),
              ),

              const SizedBox(height: 30),

              // Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.alreadyHaveAccount,
                    style: AppTextStyles.regularGrey,
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    onTap: isLoading ? null : () => context.pop(),
                    child: Text(
                      AppStrings.loginHere,
                      style: AppTextStyles.regularPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ========================================
  // TEXTFIELD BUILDER (matching repo lama style)
  // ========================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required IconData prefixIcon,
    String? errorText,
    bool enabled = true,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TextField with repo lama styling
        Container(
          margin: EdgeInsets.all(AppDimensions.inputFieldMargin),
          child: TextField(
            controller: controller,
            enabled: enabled,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            autocorrect: false,
            enableSuggestions: false,
            onChanged: onChanged,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                borderSide: BorderSide(width: AppDimensions.inputBorderWidth),
              ),
              prefixIcon: Icon(prefixIcon, color: AppColors.iconGrey),
              suffixIcon: suffixIcon,
              labelText: labelText,
              hintText: hintText,
              // No errorText in TextField - we show it separately below
            ),
          ),
        ),

        // Error message (shown separately like repo lama)
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 22, top: 4),
            child: Text(
              errorText,
              style: AppTextStyles.inputError,
            ),
          ),
      ],
    );
  }
}
