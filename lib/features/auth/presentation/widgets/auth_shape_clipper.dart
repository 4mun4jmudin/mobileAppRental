import 'package:flutter/material.dart';

class AuthShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Mulai dari pojok kiri atas, gambar garis ke bawah hingga 55% tinggi layar
    path.lineTo(0, size.height * 0.55); // Diubah dari 0.45

    // Buat kurva yang puncaknya berada di 65% tinggi layar
    path.quadraticBezierTo(
      size.width / 2,
      size.height * 0.65, // Diubah dari 0.55
      size.width,
      size.height * 0.55, // Diubah dari 0.45
    );

    // Selesaikan path ke pojok kanan atas
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
