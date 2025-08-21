import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart';
import 'package:mobile_app_rental/core/services/api_service.dart';
import 'package:mobile_app_rental/features/activity/presentation/widgets/booking_card.dart';

class ActivityHubScreen extends StatefulWidget {
  const ActivityHubScreen({super.key});

  @override
  State<ActivityHubScreen> createState() => _ActivityHubScreenState();
}

class _ActivityHubScreenState extends State<ActivityHubScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late Future<List<Map<String, dynamic>>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _bookingsFuture = _fetchBookingsFromApi();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchBookingsFromApi() async {
    final result = await ApiService.fetchMyBookings();
    if (result['success'] == true && result['data'] != null) {
      return List<Map<String, dynamic>>.from(result['data']);
    } else {
      throw Exception(result['message'] ?? 'Gagal memuat riwayat pesanan');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  BookingStatus _getBookingStatus(
    String status,
    String startDate,
    String endDate,
  ) {
    final now = DateTime.now();
    // Pastikan parsing tanggal aman
    final start = DateTime.tryParse(startDate) ?? now;
    final end = DateTime.tryParse(endDate) ?? now;

    if (status == 'confirmed' &&
        (now.isAfter(start) || now.isAtSameMomentAs(start)) &&
        now.isBefore(end)) {
      return BookingStatus.berjalan;
    } else if (status == 'confirmed' && now.isBefore(start)) {
      return BookingStatus.akanDatang;
    } else {
      return BookingStatus.selesai;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Aktivitas Saya',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        elevation: 1,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryGreen,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primaryGreen,
          indicatorWeight: 3,
          tabs: const <Widget>[
            Tab(text: 'Berjalan'),
            Tab(text: 'Akan Datang'),
            Tab(text: 'Riwayat'),
          ],
        ),
      ),
      backgroundColor: AppColors.formBackground,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookingsFuture,
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
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Anda belum memiliki pesanan.',
                style: TextStyle(color: AppColors.grey, fontSize: 16),
              ),
            );
          }

          final allBookings = snapshot.data!;

          return TabBarView(
            controller: _tabController,
            children: <Widget>[
              _buildBookingList(allBookings, BookingStatus.berjalan),
              _buildBookingList(allBookings, BookingStatus.akanDatang),
              _buildBookingList(allBookings, BookingStatus.selesai),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBookingList(
    List<Map<String, dynamic>> allBookings,
    BookingStatus status,
  ) {
    final filteredBookings = allBookings
        .where(
          (b) =>
              _getBookingStatus(b['status'], b['start_date'], b['end_date']) ==
              status,
        )
        .toList();

    if (filteredBookings.isEmpty) {
      return Center(
        child: Text(
          'Tidak ada pesanan dalam kategori ini.',
          style: TextStyle(color: AppColors.grey, fontSize: 16),
        ),
      );
    }

    final dateFormatter = DateFormat('dd MMM yyyy', 'id_ID');

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          final car = Map<String, dynamic>.from(booking['car']);
          final baseUrl = ApiService.getBaseUrl().replaceAll('/api/', '');
          final imageUrl = (car['image_urls'] as List).isNotEmpty
              ? '$baseUrl/storage/${car['image_urls'][0]}'
              : null;

          return BookingCard(
            status: status,
            carName: '${car['brand']} ${car['model']}',
            carImage: imageUrl,
            dateRange:
                '${dateFormatter.format(DateTime.parse(booking['start_date']))} - ${dateFormatter.format(DateTime.parse(booking['end_date']))}',
            totalPrice:
                double.tryParse(booking['total_price'].toString()) ?? 0.0,
          );
        },
      ),
    );
  }
}
