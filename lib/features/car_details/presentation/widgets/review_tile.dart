import 'package:flutter/material.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart';

class ReviewTile extends StatelessWidget {
  final Map<String, dynamic> reviewData; // Terima data review asli
  const ReviewTile({super.key, required this.reviewData});

  @override
  Widget build(BuildContext context) {
    final userName = reviewData['user']?['full_name'] ?? 'Pengguna';
    final rating = reviewData['rating'] ?? 0;
    final comment = reviewData['comment'] ?? 'Tidak ada komentar.';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.lightGrey,
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'P',
              style: const TextStyle(
                color: AppColors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: AppColors.accent,
                      size: 16,
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text(
                  comment,
                  style: const TextStyle(color: AppColors.grey, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
