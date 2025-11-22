import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_router.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // _isInit untuk tidak menampilkan error sebelum user mulai input
  bool _isEmailInit = true;
  bool _isPasswordInit = true;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _validateEmail(String value) {
    setState(() {
      _isEmailInit = false;
      if (value.isEmpty) {
        _emailError = 'Isian tidak boleh kosong';
      } else if (!EmailValidator.validate(value)) {
        _emailError = 'Mohon masukan email yang benar';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      _isPasswordInit = false;
      if (value.isEmpty) {
        _passwordError = 'Isian tidak boleh kosong';
      } else {
        _passwordError = null;
      }
    });
  }

  bool get _canProceed {
    return _emailError == null &&
           _passwordError == null &&
           !_isEmailInit &&
           !_isPasswordInit &&
           _emailController.text.isNotEmpty &&
           _passwordController.text.isNotEmpty;
  }

  Future<void> _handleLogin() async {
    // Validate all fields first
    _validateEmail(_emailController.text);
    _validatePassword(_passwordController.text);

    if (!_canProceed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ada yang belum valid')),
      );
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      context.go(AppRoutes.home);
    } else {
      Fluttertoast.showToast(
        msg: 'Email atau password salah',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Logo dan Header
              Container(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Container(
                      margin: const EdgeInsets.only(top: 60),
                      child: Image.asset(
                        'assets/images/logo_app_color.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, stack) => Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.pink300.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite,
                            size: 50,
                            color: AppColors.pink300,
                          ),
                        ),
                      ),
                    ),
                    // Welcome text
                    Container(
                      margin: const EdgeInsets.only(top: 60),
                      child: Text(
                        'Selamat Datang Bunda',
                        style: SibTextStyles.header1,
                      ),
                    ),
                  ],
                ),
              ),

              // Form Fields
              Column(
                children: [
                  // Email field
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: TextField(
                      controller: _emailController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enableSuggestions: false,
                      onChanged: _validateEmail,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(width: 2),
                        ),
                        errorText: _isEmailInit ? null : _emailError,
                        labelText: 'Email',
                        hintText: 'Email',
                      ),
                    ),
                  ),

                  // Password field
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: TextField(
                      controller: _passwordController,
                      enabled: !isLoading,
                      obscureText: true,
                      autocorrect: false,
                      enableSuggestions: false,
                      onChanged: _validatePassword,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(width: 2),
                        ),
                        errorText: _isPasswordInit ? null : _passwordError,
                        labelText: 'Password',
                        hintText: 'Password',
                      ),
                    ),
                  ),

                  // Submit Button (FAB like repo lama)
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: FloatingActionButton(
                      backgroundColor: _canProceed ? AppColors.pink300 : AppColors.grey,
                      onPressed: isLoading
                          ? null
                          : (_canProceed ? _handleLogin : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ada yang belum valid')),
                              );
                            }),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.arrow_forward_rounded),
                    ),
                  ),
                ],
              ),

              // Error message area (like repo lama's LiveDataObserver)
              authState.errorMessage != null
                  ? Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        authState.errorMessage!,
                        style: SibTextStyles.size_0.copyWith(color: Colors.red),
                      ),
                    )
                  : const SizedBox.shrink(),

              // Register link section
              Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 30),
                    child: Text(
                      'Bunda belum punya akun?',
                      style: SibTextStyles.regular_grey,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: InkWell(
                      onTap: isLoading ? null : () => context.push(AppRoutes.register),
                      child: Text(
                        'Daftar Disini Yuk',
                        style: SibTextStyles.regular_colorPrimary,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Text styles yang match dengan repo lama (fonts.dart)
class SibTextStyles {
  static TextStyle header1 = const TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static TextStyle size_0 = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );

  static TextStyle regular_grey = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.grey,
  );

  static TextStyle regular_colorPrimary = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: AppColors.pink300,
  );

  static TextStyle default_ = const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: Colors.black,
  );
}
