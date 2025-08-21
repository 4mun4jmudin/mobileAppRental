import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
// import 'package:go_router/go_router.dart';
// Ganti 'rental_mobil_app' dengan nama proyekmu
import 'package:mobile_app_rental/core/widgets/custom_button.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil informasi ukuran layar
    final screenSize = MediaQuery.of(context).size;
    // Mengambil informasi tema
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // --- Bagian Ilustrasi ---
              SvgPicture.asset(
                'assets/images/welcome_illustration.svg', // Pastikan path ini benar
                height: screenSize.height * 0.3,
              ),
              const SizedBox(height: 48),

              // --- Bagian Teks Judul & Subjudul ---
              Text(
                'Selamat Datang di RentGo',
                textAlign: TextAlign.center,
                style: textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Solusi rental mobil terbaik untuk setiap perjalanan dan kebutuhan Anda.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey,
                  height: 1.5, // Jarak antar baris
                ),
              ),
              const Spacer(flex: 3),

              // --- Bagian Tombol Aksi ---
              CustomButton(
                text: 'Buat Akun Baru',
                onPressed: () {
                  // Aksi navigasi saat tombol ditekan (akan kita buat rutenya nanti)
                  context.push('/register');
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Masuk',
                isOutline: true,
                onPressed: () {
                  // Aksi navigasi saat tombol ditekan (akan kita buat rutenya nanti)
                  context.push('/login');
                },
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}
