import 'package:flutter/material.dart';

import 'package:mobile_app_rental/core/constants/app_colors.dart'; // Ganti nama proyekmu

class FavoriteCarTile extends StatelessWidget {
  // Mock data, nantinya akan diganti dengan objek mobil
  final String imageUrl;
  final String name;
  final double pricePerDay;
  final double rating;

  const FavoriteCarTile({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.pricePerDay,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Mobil
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              imageUrl,
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          // Detail Mobil
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.accent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Rp${pricePerDay.toInt()}',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      TextSpan(
                        text: ' / hari',
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Ikon Favorit
          IconButton(
            onPressed: () {
              // Logika untuk menghapus dari favorit
            },
            icon: const Icon(Icons.favorite, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
