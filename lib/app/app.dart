import 'package:flutter/material.dart';
import 'package:mobile_app_rental/app/routes/app_router.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart'; // Ganti 'rental_mobil_app' dengan nama proyekmu

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MaterialApp.router adalah konstruktor khusus untuk digunakan bersama GoRouter.
    return MaterialApp.router(
      // Menghilangkan banner "Debug" di pojok kanan atas.
      debugShowCheckedModeBanner: false,

      // Judul aplikasi yang akan muncul di task manager, dll.
      title: 'Rental Mobil App',

      // Menghubungkan konfigurasi router kita ke aplikasi.
      routerConfig: appRouter,

      // Konfigurasi tema global untuk seluruh aplikasi.
      theme: ThemeData(
        // Menggunakan skema desain Material 3 yang lebih modern.
        useMaterial3: true,

        // Menetapkan font default untuk seluruh aplikasi.
        fontFamily: 'Poppins',

        // Warna dasar dari mana Flutter akan menghasilkan palet warna turunan.
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen, // Diganti dari AppColors.primary
          primary: AppColors.primaryGreen, // Diganti dari AppColors.primary
          background: AppColors.white,
        ),

        // Tema default untuk Scaffold (kerangka dasar halaman).
        scaffoldBackgroundColor: AppColors.white,

        // Tema default untuk AppBar (header di atas halaman).
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.white,
          elevation: 0, // Tanpa bayangan
          titleTextStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Tema default untuk semua ElevatedButton.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            // GANTI WARNA INI
            backgroundColor:
                AppColors.buttonBlue, // Menggunakan warna biru dari desain
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 18,
            ), // Sedikit lebih tinggi
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // Lebih melengkung
            ),
            textStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
