import 'package:flutter/material.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart';
// import 'package.rental_mobil_app/core/constants/app_colors.dart'; // Ganti nama proyekmu

class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Desain baru tidak lagi menggunakan label di atas,
    // jadi kita hapus widget Column dan Text sebelumnya.
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        // Style baru sesuai desain
        filled: true,
        fillColor: AppColors.white,
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.grey),
        prefixIcon: Icon(icon, color: AppColors.grey),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none, // Tidak ada border saat normal
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          // Beri border biru saat di-klik/fokus
          borderSide: const BorderSide(color: AppColors.buttonBlue, width: 2),
        ),
      ),
    );
  }
}
