import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart';
import 'package:mobile_app_rental/core/services/api_service.dart';

class CarCard extends StatelessWidget {
  final Map<String, dynamic> carData;

  const CarCard({super.key, required this.carData});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final carId = carData['id']?.toString() ?? '0';
    final name = '${carData['brand'] ?? ''} ${carData['model'] ?? ''}';
    final pricePerDay =
        double.tryParse(carData['price_per_day']?.toString() ?? '0.0') ?? 0.0;
    final rating =
        double.tryParse(carData['reviews_avg_rating']?.toString() ?? '0.0') ??
        0.0;

    final imageUrls = (carData['image_urls'] is List)
        ? List<String>.from(carData['image_urls'])
        : <String>[];
    final imageUrl = imageUrls.isNotEmpty ? imageUrls.first : null;

    // --- INI CARA PALING AMAN MEMBANGUN URL ---
    final storageUrlBase = ApiService.getBaseUrl().replaceAll(
      '/api/',
      '/storage/',
    );
    final fullImageUrl = imageUrl != null ? '$storageUrlBase$imageUrl' : null;

    return GestureDetector(
      onTap: () {
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
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: fullImageUrl != null
                  ? Image.network(
                      fullImageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 120,
                          color: AppColors.lightGrey,
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        );
                      },
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
                      height: 120,
                      color: AppColors.lightGrey,
                      child: const Icon(
                        Icons.directions_car,
                        color: AppColors.grey,
                        size: 50,
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.accent, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        rating.toStringAsFixed(1),
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
          ],
        ),
      ),
    );
  }
}
