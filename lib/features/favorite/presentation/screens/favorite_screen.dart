import 'package:flutter/material.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart'; // Ganti nama proyekmu
import 'package:mobile_app_rental/features/favorite/presentation/widgets/favorite_car_tile.dart'; // Ganti nama proyekmu

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data untuk mobil favorit.
    // Di aplikasi nyata, data ini akan diambil dari database lokal atau server.
    final List<Map<String, dynamic>> favoriteCars = [
      {
        'imageUrl': 'assets/images/xpander.png',
        'name': 'Mitsubishi Xpander',
        'rating': 4.8,
        'pricePerDay': 400000.0,
      },
      {
        'imageUrl': 'assets/images/avanza.png',
        'name': 'Toyota Avanza',
        'rating': 4.6,
        'pricePerDay': 350000.0,
      },
    ];

    // Untuk mencoba tampilan kosong, ganti list di atas dengan:
    // final List<Map<String, dynamic>> favoriteCars = [];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favorit Saya',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        elevation: 1,
      ),
      backgroundColor: AppColors.formBackground,
      body: favoriteCars.isEmpty
          ? _buildEmptyState()
          : _buildFavoriteList(favoriteCars),
    );
  }

  // Widget untuk menampilkan daftar mobil favorit
  Widget _buildFavoriteList(List<Map<String, dynamic>> cars) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cars.length,
      itemBuilder: (context, index) {
        final car = cars[index];
        return FavoriteCarTile(
          imageUrl: car['imageUrl'],
          name: car['name'],
          pricePerDay: car['pricePerDay'],
          rating: car['rating'],
        );
      },
    );
  }

  // Widget untuk ditampilkan jika daftar favorit kosong
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: AppColors.lightGrey),
          SizedBox(height: 16),
          Text(
            'Daftar Favorit Kosong',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Simpan mobil impianmu agar mudah ditemukan.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}
