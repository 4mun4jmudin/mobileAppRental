// import 'package.carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart';
import 'package:mobile_app_rental/core/services/api_service.dart';
import 'package:mobile_app_rental/features/car_details/presentation/widgets/review_tile.dart';
import 'package:table_calendar/table_calendar.dart';

class CarDetailsScreen extends StatefulWidget {
  final String carId;

  const CarDetailsScreen({super.key, required this.carId});

  @override
  State<CarDetailsScreen> createState() => _CarDetailsScreenState();
}

class _CarDetailsScreenState extends State<CarDetailsScreen> {
  // Cukup satu Future untuk menampung proses pengambilan data dari API
  late final Future<Map<String, dynamic>> _carDetailsFuture;

  // State untuk data booking yang akan dikirim ke halaman checkout
  DateTimeRange? _selectedDateRange;
  int _numberOfDays = 0;
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    // Panggil API untuk mengambil detail mobil saat halaman pertama kali dibuka
    _carDetailsFuture = ApiService.fetchCarDetails(widget.carId);
  }

  // Fungsi untuk menghitung total harga berdasarkan data mobil dari API
  void _calculatePrice(double pricePerDay) {
    if (_selectedDateRange != null) {
      final duration = _selectedDateRange!.end.difference(
        _selectedDateRange!.start,
      );
      _numberOfDays = duration.inDays + 1;
      _totalPrice = _numberOfDays * pricePerDay;
    } else {
      _numberOfDays = 0;
      _totalPrice = 0.0;
    }
    // Panggil setState untuk memperbarui UI, terutama bottom bar
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Detail Mobil',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        iconTheme: const IconThemeData(color: AppColors.black),
        elevation: 1,
      ),
      // Gunakan FutureBuilder sebagai root dari body untuk mengelola state
      body: FutureBuilder<Map<String, dynamic>>(
        future: _carDetailsFuture,
        builder: (context, snapshot) {
          // 1. Saat data sedang dimuat
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Jika terjadi error atau request gagal
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !(snapshot.data?['success'] ?? false)) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Gagal memuat detail mobil: ${snapshot.error ?? snapshot.data?['message']}',
                ),
              ),
            );
          }

          // 3. Jika data berhasil dimuat
          final carData = snapshot.data!['data'] as Map<String, dynamic>;
          final pricePerDay =
              double.tryParse(carData['price_per_day'].toString()) ?? 0.0;

          return Stack(
            children: [
              // Konten utama yang bisa di-scroll
              SingleChildScrollView(
                padding: const EdgeInsets.only(
                  bottom: 120,
                ), // Beri ruang untuk bottom bar
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSlider(carData['image_urls'] as List?),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(carData),
                          const SizedBox(height: 16),
                          _buildFeatures(
                            carData['features'] as Map<String, dynamic>?,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            carData['description'] ?? 'Tidak ada deskripsi.',
                            style: const TextStyle(
                              color: AppColors.grey,
                              height: 1.5,
                            ),
                          ),
                          const Divider(height: 32),
                          _buildSectionTitle('Ulasan Pengguna'),
                          const SizedBox(height: 8),
                          const ReviewTile(
                            reviewData: {},
                          ), // Ulasan masih statis untuk saat ini
                          const Divider(height: 32),
                          _buildSectionTitle('Pilih Tanggal Sewa'),
                          const SizedBox(height: 16),
                          _buildCalendar(pricePerDay),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Bottom bar diposisikan di bawah layar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomBar(context, carData),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET BUILDER HELPERS ---

  Widget _buildImageSlider(List? images) {
    final imageUrls = (images is List) ? List<String>.from(images) : <String>[];
    final storageUrlBase = ApiService.getBaseUrl().replaceAll(
      '/api/',
      '/storage/',
    );

    if (imageUrls.isEmpty) {
      return Container(
        height: 250,
        color: AppColors.lightGrey,
        child: const Icon(
          Icons.directions_car,
          size: 80,
          color: AppColors.grey,
        ),
      );
    }

    return CarouselSlider.builder(
      itemCount: imageUrls.length,
      itemBuilder: (context, index, realIndex) => Image.network(
        '$storageUrlBase${imageUrls[index]}',
        fit: BoxFit.cover,
        width: double.infinity,
      ),
      options: CarouselOptions(
        height: 250,
        viewportFraction: 1.0,
        autoPlay:
            imageUrls.length >
            1, // Aktifkan autoPlay jika gambar lebih dari satu
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> carData) {
    final name = '${carData['brand'] ?? ''} ${carData['model'] ?? ''}';
    final rating =
        double.tryParse(carData['reviews_avg_rating']?.toString() ?? '0.0') ??
        0.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Row(
          children: [
            const Icon(Icons.star, color: AppColors.accent, size: 20),
            const SizedBox(width: 4),
            Text(
              rating.toStringAsFixed(1),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatures(Map<String, dynamic>? features) {
    if (features == null || features.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada fitur tambahan.',
          style: TextStyle(color: AppColors.grey),
        ),
      );
    }

    // Fitur dari JSON Laravel Anda adalah object, bukan array, jadi kita cek key-nya
    final featureWidgets = <Widget>[
      if (features['ac'] == true) _buildFeatureIcon(Icons.ac_unit, 'AC Dingin'),
      if (features['gps'] == true) _buildFeatureIcon(Icons.gps_fixed, 'GPS'),
      if (features['bluetooth'] == true)
        _buildFeatureIcon(Icons.bluetooth, 'Bluetooth'),
      if (features['usb'] == true) _buildFeatureIcon(Icons.usb, 'USB Port'),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: featureWidgets,
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.grey),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCalendar(double pricePerDay) {
    return TableCalendar(
      locale: 'id_ID', // Menampilkan kalender dalam Bahasa Indonesia
      focusedDay: DateTime.now(),
      firstDay: DateTime.now(),
      lastDay: DateTime.now().add(const Duration(days: 365)),
      rangeSelectionMode: RangeSelectionMode.toggledOn,
      onRangeSelected: (start, end, focusedDay) {
        if (start != null) {
          _selectedDateRange = DateTimeRange(start: start, end: end ?? start);
        } else {
          _selectedDateRange = null;
        }
        _calculatePrice(pricePerDay);
      },
      selectedDayPredicate: (day) {
        if (_selectedDateRange == null) return false;
        return isSameDay(_selectedDateRange!.start, day) ||
            isSameDay(_selectedDateRange!.end, day) ||
            (day.isAfter(_selectedDateRange!.start) &&
                day.isBefore(_selectedDateRange!.end));
      },
      calendarStyle: CalendarStyle(
        selectedDecoration: const BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
        ),
        rangeStartDecoration: const BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
        ),
        rangeEndDecoration: const BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
        ),
        rangeHighlightColor: AppColors.primaryGreen.withAlpha(51),
        todayDecoration: BoxDecoration(
          color: AppColors.grey.withAlpha(128),
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, Map<String, dynamic> carData) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Harga ($_numberOfDays hari)',
                    style: const TextStyle(color: AppColors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormatter.format(_totalPrice),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _selectedDateRange == null
                  ? null
                  : () {
                      final bookingData = {
                        'carData': carData,
                        'dateRange': _selectedDateRange,
                        'totalPrice': _totalPrice,
                        'numberOfDays': _numberOfDays,
                      };
                      context.push('/checkout', extra: bookingData);
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Lanjutkan'),
            ),
          ],
        ),
      ),
    );
  }
}
