import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart';
import 'package:mobile_app_rental/features/checkout/presentation/widgets/payment_method_tile.dart';

class CheckoutScreen extends StatefulWidget {
  // Menerima data booking dari halaman detail
  final Map<String, dynamic> bookingData;

  const CheckoutScreen({super.key, required this.bookingData});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _selectedPaymentMethod = 'bca';
  final bool _isUserVerified = false; // Mock verifikasi; sebaiknya dari server
  bool _isProcessing = false;

  static const double _serviceFee = 50000.0;

  @override
  Widget build(BuildContext context) {
    // Ambil data secara defensif
    final dynamic carData = widget.bookingData['carData'];
    final DateTimeRange? dateRange =
        widget.bookingData['dateRange'] as DateTimeRange?;
    final double totalPriceFromPrevious =
        (widget.bookingData['totalPrice'] as double?) ?? 0.0;
    final int numberOfDays = (widget.bookingData['numberOfDays'] as int?) ?? 1;

    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final dateFormatter = DateFormat('d MMM yyyy', 'id_ID');

    final double grandTotal = totalPriceFromPrevious + _serviceFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ringkasan & Bayar',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.black),
        elevation: 1,
      ),
      backgroundColor: AppColors.formBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        // beri padding bawah agar konten tidak tertutup oleh bottom bar
        // bottom area akan dikontrol oleh bottomNavigationBar SafeArea
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderSummary(carData, dateFormatter, dateRange),
            const SizedBox(height: 16),
            _buildPriceDetails(
              numberOfDays,
              (carData != null && carData['pricePerDay'] != null)
                  ? (carData['pricePerDay'] as double)
                  : 0.0,
              totalPriceFromPrevious,
              currencyFormatter,
            ),
            const SizedBox(height: 16),
            _buildPromoCode(),
            if (!_isUserVerified) ...[
              const SizedBox(height: 16),
              _buildVerificationNotice(),
            ],
            const SizedBox(height: 24),
            _buildSectionTitle('Metode Pembayaran'),
            const SizedBox(height: 16),
            _buildPaymentMethods(),
            const SizedBox(height: 24),
            // catatan kecil
            Text(
              'Dengan menekan bayar, Anda menyetujui syarat & ketentuan sewa.',
              style: TextStyle(color: AppColors.grey, fontSize: 12),
            ),
            const SizedBox(height: 80), // beri ruang sebelum bottom bar
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Ringkasan biaya singkat
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: TextStyle(color: AppColors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currencyFormatter.format(grandTotal),
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Tombol bayar — menampilkan loading state & disabled sesuai kondisi
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: (_isProcessing || !_canProceed())
                      ? null
                      : () => _onPayPressed(
                          context,
                          carData: carData,
                          dateRange: dateRange,
                          amount: grandTotal,
                        ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    minimumSize: const Size(150, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isProcessing
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Memproses...'),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Bayar Sekarang',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _canProceed() {
    // Anda bisa ubah logika ini: boleh dilanjutkan walau belum verifikasi, atau blokir.
    // Di sini kita izinkan lanjut tapi tampilkan peringatan—untuk contoh ini izinkan.
    return true;
  }

  // --- WIDGET BUILDER HELPERS ---

  Widget _buildOrderSummary(
    dynamic carData,
    DateFormat dateFormatter,
    DateTimeRange? dateRange,
  ) {
    final imageAsset =
        (carData != null &&
            carData['images'] != null &&
            (carData['images'] as List).isNotEmpty)
        ? carData['images'][0] as String
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: imageAsset != null
                ? Image.asset(
                    imageAsset,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image),
                    ),
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: Colors.grey[200],
                    child: const Icon(Icons.directions_car),
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  carData != null ? (carData['name'] ?? '-') : '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dateRange != null
                      ? '${dateFormatter.format(dateRange.start)} - ${dateFormatter.format(dateRange.end)}'
                      : '-',
                  style: const TextStyle(color: AppColors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetails(
    int days,
    double pricePerDay,
    double totalPrice,
    NumberFormat formatter,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPriceDetailRow(
            'Harga Sewa ($days hari)',
            formatter.format(pricePerDay * days),
          ),
          const SizedBox(height: 12),
          _buildPriceDetailRow('Biaya Layanan', formatter.format(_serviceFee)),
          const Divider(height: 24, thickness: 1),
          _buildPriceDetailRow(
            'Total Pembayaran',
            formatter.format(totalPrice + _serviceFee),
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetailRow(
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.black,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCode() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.discount_outlined, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Gunakan Kode Promo',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.grey),
        ],
      ),
    );
  }

  Widget _buildVerificationNotice() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.warning, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Rental pertama membutuhkan verifikasi KTP & SIM setelah pembayaran.',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        PaymentMethodTile(
          logoAsset: 'assets/images/bca_logo.png',
          name: 'BCA Virtual Account',
          groupValue: _selectedPaymentMethod,
          value: 'bca',
          onChanged: (value) {
            if (!mounted) return;
            setState(() => _selectedPaymentMethod = value ?? 'bca');
          },
        ),
        PaymentMethodTile(
          logoAsset: 'assets/images/gopay_logo.png',
          name: 'GoPay',
          groupValue: _selectedPaymentMethod,
          value: 'gopay',
          onChanged: (value) {
            if (!mounted) return;
            setState(() => _selectedPaymentMethod = value ?? 'gopay');
          },
        ),
      ],
    );
  }

  // --- ACTIONS ---

  Future<void> _onPayPressed(
    BuildContext context, {
    dynamic carData,
    DateTimeRange? dateRange,
    required double amount,
  }) async {
    // Tampilkan modal konfirmasi singkat
    final bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Konfirmasi Pesanan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(carData != null ? carData['name'] ?? '-' : '-'),
                const SizedBox(height: 8),
                if (dateRange != null)
                  Text(
                    '${DateFormat('d MMM yyyy', 'id_ID').format(dateRange.start)} - ${DateFormat('d MMM yyyy', 'id_ID').format(dateRange.end)}',
                  ),
                const SizedBox(height: 8),
                Text('Metode: ${_paymentMethodLabel(_selectedPaymentMethod)}'),
                const SizedBox(height: 8),
                Text(
                  'Total: ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount)}',
                ),
                if (!_isUserVerified) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Catatan: Anda akan diminta mengunggah KTP & SIM setelah pembayaran.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Konfirmasi'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    // mulai proses pembayaran (simulasi)
    if (!mounted) return;
    setState(() => _isProcessing = true);

    try {
      // Simulasi pemanggilan API / integrasi pembayaran
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      // Anda bisa mengganti ini dengan navigasi ke halaman pembayaran / menampilkan QR / VA
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pembayaran berhasil. Metode: ${_paymentMethodLabel(_selectedPaymentMethod)} — Terima kasih!',
          ),
        ),
      );

      // contoh: kembali ke daftar atau halaman sukses
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  String _paymentMethodLabel(String method) {
    switch (method) {
      case 'bca':
        return 'BCA Virtual Account';
      case 'gopay':
        return 'GoPay';
      default:
        return method;
    }
  }
}
