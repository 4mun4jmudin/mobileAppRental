import 'package:flutter/material.dart';

import 'package:mobile_app_rental/core/constants/app_colors.dart'; // Ganti nama proyekmu

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDanger; // Untuk memberi warna merah pada menu logout

  const ProfileMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDanger ? AppColors.error : AppColors.primaryGreen,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDanger ? AppColors.error : AppColors.black,
                ),
              ),
            ),
            if (!isDanger)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.grey,
              ),
          ],
        ),
      ),
    );
  }
}
