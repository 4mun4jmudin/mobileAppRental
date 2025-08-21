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
  late Future<Map<String, dynamic>> _carDetailsFuture;
  Map<String, dynamic>? _carData;

  DateTimeRange? _selectedDateRange;
  int _numberOfDays = 0;
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _carDetailsFuture = _fetchCarDetailsFromApi();
  }

  // --- PERBAIKAN UTAMA DI SINI ---
  // Fungsi ini sekarang hanya memanggil ApiService, bukan mencoba mengimplementasikan logikanya sendiri.
  Future<Map<String, dynamic>> _fetchCarDetailsFromApi() async {
    final result = await ApiService.fetchCarDetails(widget.carId);
    if (result['success'] == true && result['data'] != null) {
      // Simpan data ke state agar bisa diakses oleh widget lain seperti bottom bar
      _carData = Map<String, dynamic>.from(result['data']);
      return _carData!;
    } else {
      throw Exception(result['message'] ?? 'Gagal memuat detail mobil');
    }
  }

  void _calculatePrice() {
    if (_selectedDateRange != null && _carData != null) {
      final duration = _selectedDateRange!.end.difference(
        _selectedDateRange!.start,
      );
      _numberOfDays = duration.inDays + 1;
      final pricePerDay =
          double.tryParse(_carData!['price_per_day'].toString()) ?? 0.0;
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: _carDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Terjadi kesalahan: ${snapshot.error}'),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Data mobil tidak ditemukan.'));
          }
          // Jika data berhasil dimuat, bangun konten utama
          return _buildContent(snapshot.data!);
        },
      ),
      // Tampilkan bottom bar hanya jika data mobil sudah berhasil dimuat
      bottomNavigationBar: _carData != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildContent(Map<String, dynamic> car) {
    final reviews = (car['reviews'] as List? ?? [])
        .map((r) => Map<String, dynamic>.from(r))
        .toList();
    final double bottomBarHeight = 90.0;
    final double safeBottom = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: bottomBarHeight + safeBottom + 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSlider(car),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(car),
                const SizedBox(height: 16),
                _buildFeatures(car),
                const SizedBox(height: 16),
                Text(
                  car['description'] ?? 'Tidak ada deskripsi.',
                  style: const TextStyle(color: AppColors.grey, height: 1.5),
                ),
                const Divider(height: 32),
                _buildSectionTitle('Ulasan Pengguna (${reviews.length})'),
                const SizedBox(height: 8),
                if (reviews.isNotEmpty)
                  // PERBAIKAN: Menghapus .toList() yang tidak perlu saat menggunakan spread operator (...)
                  ...reviews.map((review) => ReviewTile(reviewData: review))
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'Belum ada ulasan untuk mobil ini.',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  ),
                const Divider(height: 32),
                _buildSectionTitle('Pilih Tanggal Sewa'),
                const SizedBox(height: 16),
                _buildCalendar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlider(Map<String, dynamic> car) {
    final images = (car['image_urls'] as List? ?? []);
    if (images.isEmpty) {
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
    final baseUrl = ApiService.getBaseUrl().replaceAll('/api/', '');
    return CarouselSlider.builder(
      itemCount: images.length,
      itemBuilder: (context, index, realIndex) {
        final imageUrl = '$baseUrl/storage/${images[index]}';
        return Image.network(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          loadingBuilder: (context, child, progress) => progress == null
              ? child
              : const Center(child: CircularProgressIndicator()),
          errorBuilder: (context, error, stack) =>
              const Icon(Icons.broken_image, size: 50, color: AppColors.grey),
        );
      },
      options: CarouselOptions(
        height: 250,
        viewportFraction: 1.0,
        autoPlay: images.length > 1,
      ),
    );
  }

  Widget _buildHeader(Map<String, dynamic> car) {
    final rating =
        double.tryParse(car['reviews_avg_rating']?.toString() ?? '0.0') ?? 0.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            '${car['brand']} ${car['model']}',
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

  Widget _buildFeatures(Map<String, dynamic> car) {
    final features = (car['features'] as List? ?? [])
        .map((f) => f.toString())
        .toList();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildFeatureIcon(Icons.ac_unit, 'AC', features.contains('AC')),
        _buildFeatureIcon(
          Icons.bluetooth,
          'Bluetooth',
          features.contains('Bluetooth'),
        ),
        _buildFeatureIcon(Icons.gps_fixed, 'GPS', features.contains('GPS')),
        _buildFeatureIcon(Icons.usb, 'USB Port', features.contains('USB Port')),
      ],
    );
  }

  Widget _buildFeatureIcon(IconData icon, String label, bool isAvailable) {
    return Column(
      children: [
        Icon(
          icon,
          color: isAvailable ? AppColors.primaryGreen : AppColors.lightGrey,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isAvailable ? AppColors.grey : AppColors.lightGrey,
          ),
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

  Widget _buildCalendar() {
    return TableCalendar(
      locale: 'id_ID',
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
        _calculatePrice();
      },
      selectedDayPredicate: (day) {
        if (_selectedDateRange == null) return false;
        return isSameDay(_selectedDateRange!.start, day) ||
            isSameDay(_selectedDateRange!.end, day) ||
            (day.isAfter(_selectedDateRange!.start) &&
                day.isBefore(_selectedDateRange!.end));
      },
      calendarStyle: const CalendarStyle(
        selectedDecoration: BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
        ),
        rangeStartDecoration: BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
        ),
        rangeEndDecoration: BoxDecoration(
          color: AppColors.primaryGreen,
          shape: BoxShape.circle,
        ),
        rangeHighlightColor: Color(0x26009C22), // primaryGreen with opacity
        todayDecoration: BoxDecoration(
          color: AppColors.lightGrey,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
      ),
    );
  }

  Widget _buildBottomBar() {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final double bottomBarHeight = 90.0;
    final double safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      height: bottomBarHeight + safeBottom,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + safeBottom * 0.5),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          // PERBAIKAN: Mengganti .withOpacity() yang deprecated
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Total Harga (${_numberOfDays > 0 ? '$_numberOfDays hari' : '-'})',
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
          SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _selectedDateRange == null
                  ? null
                  : () {
                      final bookingData = {
                        'carData': _carData,
                        'dateRange': _selectedDateRange,
                        'totalPrice': _totalPrice,
                        'numberOfDays': _numberOfDays,
                      };
                      context.push('/checkout', extra: bookingData);
                    },
              child: const Text('Lanjutkan'),
            ),
          ),
        ],
      ),
    );
  }
}
