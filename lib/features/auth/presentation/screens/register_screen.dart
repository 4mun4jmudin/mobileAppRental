import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart';
import 'package:mobile_app_rental/core/services/api_service.dart';
// import 'package:mobile_app_rental/core/widgets/custom_button.dart';
import 'package:mobile_app_rental/core/widgets/custom_textfield.dart';
import 'package:mobile_app_rental/features/auth/presentation/widgets/auth_background.dart';

// 1. Ubah menjadi StatefulWidget
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 2. Buat controller untuk setiap text field
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  // 3. Buat state untuk mengelola status loading
  bool _isLoading = false;

  // 4. Buat fungsi untuk menangani proses registrasi
  Future<void> _handleRegister() async {
    // Validasi sederhana (bisa dikembangkan lebih lanjut)
    if (_fullNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      showSnackbar(context, 'Semua field wajib diisi.', isError: true);
      return;
    }
    if (_passwordController.text != _passwordConfirmationController.text) {
      showSnackbar(
        context,
        'Konfirmasi kata sandi tidak cocok.',
        isError: true,
      );
      return;
    }

    // Mulai loading
    setState(() => _isLoading = true);

    try {
      final result = await ApiService.register(
        fullName: _fullNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        passwordConfirmation: _passwordConfirmationController.text,
      );

      if (!mounted) return;

      if (result['success']) {
        showSnackbar(context, 'Registrasi berhasil! Silakan masuk.');
        // Arahkan ke halaman login setelah berhasil
        context.go('/login');
      } else {
        // Tampilkan error dari backend (misal: email sudah terdaftar)
        // Laravel mengirimkan error dalam format yang berbeda, kita sesuaikan
        String errorMessage = 'Registrasi gagal. Coba lagi.';
        if (result['message'] is Map) {
          final errors = result['message'] as Map;
          errorMessage = errors.values.first[0]; // Ambil pesan error pertama
        }
        showSnackbar(context, errorMessage, isError: true);
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context, 'Terjadi error: ${e.toString()}', isError: true);
      }
    } finally {
      // Hentikan loading
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // 5. Jangan lupa dispose controller untuk mencegah memory leak
  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
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
                      'Sign up to join',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // 6. Hubungkan controller ke setiap CustomTextField
                    CustomTextField(
                      controller: _fullNameController,
                      hint: 'Username',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                    CustomTextField(
                      // Field baru untuk konfirmasi password
                      controller: _passwordConfirmationController,
                      hint: 'Confirm Password',
                      icon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 32),
                    // 7. Perbarui Tombol untuk menangani loading state
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
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
                            : const Text('Sign up'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    buildLoginLink(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLoginLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Have an account? ",
          style: TextStyle(color: AppColors.grey),
        ),
        GestureDetector(
          onTap: () => context.go('/login'),
          child: const Text(
            'Sign in',
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
