import 'package:flutter/material.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart'; // Ganti nama proyekmu

class PaymentMethodTile extends StatelessWidget {
  final String logoAsset;
  final String name;
  final String groupValue;
  final String value;
  final ValueChanged<String?> onChanged;

  const PaymentMethodTile({
    super.key,
    required this.logoAsset,
    required this.name,
    required this.groupValue,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.lightGrey,
            width: isSelected ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Image.asset(logoAsset, height: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppColors.primaryGreen,
            ),
          ],
        ),
      ),
    );
  }
}
