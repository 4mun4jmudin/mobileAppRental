import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_rental/features/auth/presentation/screens/login_screen.dart';
import 'package:mobile_app_rental/features/auth/presentation/screens/register_screen.dart';
import 'package:mobile_app_rental/features/auth/presentation/screens/welcome_screen.dart';
import 'package:mobile_app_rental/features/car_details/presentation/screens/car_details_screen.dart';
import 'package:mobile_app_rental/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:mobile_app_rental/features/home/presentation/screens/home_screen.dart';

// Import semua file screen kita nanti.
// Untuk sekarang, kita biarkan sebagai komentar agar tidak error.
// import '../../features/auth/presentation/screens/welcome_screen.dart';
// import '../../features/home/presentation/screens/home_screen.dart';
// import '../../features/car_details/presentation/screens/car_details_screen.dart';

// Konfigurasi utama untuk router aplikasi kita.
final GoRouter appRouter = GoRouter(
  // initialLocation adalah rute pertama yang akan dibuka saat aplikasi berjalan.
  initialLocation: '/',

  // Daftar semua rute (halaman) yang ada di aplikasi.
  routes: [
    // Rute untuk halaman Welcome/Splash Screen
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const WelcomeScreen();
      },
    ),

    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) =>
          const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (BuildContext context, GoRouterState state) =>
          const RegisterScreen(),
    ),
    // --- RUTE LAMA UNTUK NANTI ---
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
    ),
    GoRoute(
      path: '/car/:id',
      builder: (BuildContext context, GoRouterState state) {
        // Ambil parameter 'id' dari path. Tanda '!' berarti kita yakin 'id' tidak akan null.
        final String carId = state.pathParameters['id']!;

        // Panggil CarDetailsScreen dan berikan carId yang sudah didapat
        return CarDetailsScreen(carId: carId);
      },
    ),

    // Rute untuk halaman Home
    GoRoute(
      path: '/home',
      // Ganti placeholder Scaffold dengan HomeScreen()
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
    ),

    // Rute untuk halaman Detail Mobil
    // Perhatikan ada ':id' di path. Ini adalah parameter dinamis.
    GoRoute(
      path: '/car/:id',
      builder: (BuildContext context, GoRouterState state) {
        // Mengambil 'id' dari path URL.
        final String carId = state.pathParameters['id']!;
        // Nanti kita ganti dengan CarDetailsScreen(carId: carId)
        return Scaffold(
          body: Center(child: Text("Detail untuk Mobil ID: $carId")),
        );
      },
    ),

    GoRoute(
      path: '/checkout',
      builder: (context, state) {
        // Ambil data yang dikirimkan melalui parameter 'extra'
        final bookingData = state.extra as Map<String, dynamic>;
        return CheckoutScreen(bookingData: bookingData);
      },
    ),

    // Tambahkan rute-rute lain di sini nanti...
    // seperti '/checkout', '/activity', '/profile'
  ],

  // Fungsi untuk menangani error jika rute tidak ditemukan.
  errorBuilder: (context, state) {
    return Scaffold(
      body: Center(child: Text('Halaman tidak ditemukan: ${state.error}')),
    );
  },
);
