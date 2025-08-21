import 'package:flutter/material.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart';

enum BookingStatus { berjalan, akanDatang, selesai }

class BookingCard extends StatelessWidget {
  final BookingStatus status;
  final String carName;
  final String? carImage; // PERBAIKAN 1: Ubah menjadi String nullable
  final String dateRange;
  final double totalPrice;

  const BookingCard({
    super.key,
    required this.status,
    required this.carName,
    this.carImage, // Hapus 'required'
    required this.dateRange,
    required this.totalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                // PERBAIKAN 2: Ganti Image.asset menjadi Image.network dan tangani jika null
                child: (carImage != null && carImage!.isNotEmpty)
                    ? Image.network(
                        carImage!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) =>
                            progress == null
                            ? child
                            : const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70,
                          height: 70,
                          color: AppColors.lightGrey,
                          child: const Icon(
                            Icons.broken_image,
                            color: AppColors.grey,
                          ),
                        ),
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: AppColors.lightGrey,
                        child: const Icon(
                          Icons.directions_car,
                          color: AppColors.grey,
                        ),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateRange,
                      style: const TextStyle(
                        color: AppColors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    switch (status) {
      case BookingStatus.berjalan:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.support_agent),
            label: const Text('Hubungi Bantuan'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
          ),
        );
      case BookingStatus.akanDatang:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                child: const Text('Batalkan'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Lihat Detail'),
              ),
            ),
          ],
        );
      case BookingStatus.selesai:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                child: const Text('Beri Ulasan'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Sewa Lagi'),
              ),
            ),
          ],
        );
    }
  }
}
