import 'package:flutter/material.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart';
import 'package:mobile_app_rental/features/auth/presentation/widgets/auth_shape_clipper.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: screenSize.height,
          child: Stack(
            children: [
              Container(color: AppColors.white),

              ClipPath(
                clipper: AuthShapeClipper(),
                child: Container(
                  height: screenSize.height * 0.7,
                  width: double.infinity,
                  color: AppColors.primaryGreen,
                ),
              ),

              // --- PERUBAHAN 1: CORAK MELENGKUNG ---
              // Kita ganti Transform.rotate dengan Container berbentuk lingkaran besar
              // yang diposisikan di luar layar untuk menciptakan efek tepi melengkung.
              Positioned(
                top: -screenSize.height * 0.15,
                left: -screenSize.width * 0.2,
                child: Container(
                  width: screenSize.width * 0.8,
                  height: screenSize.width * 0.8,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              Positioned(top: 60, right: 30, child: buildDotsPattern()),

              Positioned(
                top: screenSize.height * 0.1,
                left: 0,
                right: 0,
                child: buildLogo(),
              ),

              SafeArea(child: child),

              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Text(
                  'cepat, mudah dan solusi keluarga',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.grey.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper untuk membuat logo
  Widget buildLogo() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryGreen,
            ),
            // --- PERUBAHAN 2: TEKS LOGO RAPI ---
            // Kita bungkus Text dengan widget Center agar posisinya
            // dijamin sempurna di tengah lingkaran.
            child: const Center(
              child: Text(
                'FALAH\nRENT CAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  height: 1.2, // Mengatur jarak antar baris
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget helper untuk membuat pola titik-titik (tidak berubah)
  Widget buildDotsPattern() {
    return Row(
      children: List.generate(4, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Column(
            children: List.generate(4, (colIndex) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Container(
                  height: 6,
                  width: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
