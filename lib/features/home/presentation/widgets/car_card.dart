import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart';

class CarCard extends StatelessWidget {
  final String carId; // Ubah dari mock ID ke ID asli
  final String? imageUrl; // Ubah dari asset ke URL (nullable)
  final String name;
  final double pricePerDay;
  final double rating;

  const CarCard({
    super.key,
    required this.carId, // Tambahkan carId
    this.imageUrl,
    required this.name,
    required this.pricePerDay,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail dengan ID mobil asli
        context.push('/car/$carId');
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ganti Image.asset menjadi Image.network
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? Image.network(
                      imageUrl!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) =>
                          progress == null
                          ? child
                          : const Center(child: CircularProgressIndicator()),
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 120,
                        color: AppColors.lightGrey,
                        child: const Icon(
                          Icons.broken_image,
                          color: AppColors.grey,
                        ),
                      ),
                    )
                  : Container(
                      // Tampilan jika tidak ada gambar
                      height: 120,
                      color: AppColors.lightGrey,
                      child: const Icon(
                        Icons.directions_car,
                        color: AppColors.grey,
                        size: 50,
                      ),
                    ),
            ),
            // Detail Mobil (tidak ada perubahan)
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.accent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.grey,
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
          ],
        ),
      ),
    );
  }
}
