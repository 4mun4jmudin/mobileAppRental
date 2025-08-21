import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart';
import 'package:mobile_app_rental/core/services/api_service.dart';
// import 'package:mobile_app_rental/core/widgets/custom_button.dart';
import 'package:mobile_app_rental/core/widgets/custom_textfield.dart';
import 'package:mobile_app_rental/features/auth/presentation/widgets/auth_background.dart';
// import 'package:mobile_app_rental/features/auth/presentation/widgets/social_login_button.dart';

// 1. Ubah menjadi StatefulWidget
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 2. Buat controller untuk email dan password
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 3. Buat state untuk mengelola status loading
  bool _isLoading = false;

  // 4. Buat fungsi untuk menangani proses login
  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      showSnackbar(context, 'Email dan kata sandi wajib diisi.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await ApiService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (result['success']) {
        showSnackbar(context, 'Login berhasil!');
        // Arahkan ke halaman utama setelah berhasil login
        // context.go akan mereset riwayat navigasi
        context.go('/home');
      } else {
        showSnackbar(
          context,
          result['message'] ?? 'Login Gagal.',
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context, 'Terjadi error: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 5. Jangan lupa dispose controller
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthBackground(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.formBackground,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Sign in to join',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 6. Hubungkan controller ke setiap CustomTextField
                    CustomTextField(
                      controller: _emailController,
                      hint: 'Email Address',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _passwordController,
                      hint: 'Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 32),
                    // 7. Perbarui Tombol untuk menangani loading state
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Sign in'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    buildRegisterLink(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Don't have an account yet? ",
          style: TextStyle(color: AppColors.grey),
        ),
        GestureDetector(
          onTap: () => context.go('/register'),
          child: const Text(
            'Sign up now',
            style: TextStyle(
              color: AppColors.linkBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
