import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart';
import 'package:mobile_app_rental/core/services/api_service.dart';
import 'package:mobile_app_rental/features/home/presentation/widgets/car_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Gunakan satu Future untuk mengambil semua data yang dibutuhkan
  late Future<Map<String, dynamic>> _homeDataFuture;
  String selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Fungsi untuk memuat ulang semua data dari API
  Future<void> _loadData() async {
    setState(() {
      _homeDataFuture = _fetchHomeData();
    });
  }

  Future<Map<String, dynamic>> _fetchHomeData() async {
    try {
      // Jalankan semua request API secara paralel untuk efisiensi
      final results = await Future.wait([
        ApiService.fetchUser(),
        ApiService.fetchBanners(),
        ApiService.fetchCars(),
      ]);

      final userResult = results[0];
      final bannersResult = results[1];
      final carsResult = results[2];

      // Periksa jika salah satu request gagal
      if (!userResult['success'] ||
          !bannersResult['success'] ||
          !carsResult['success']) {
        final errorMsg =
            userResult['message'] ??
            bannersResult['message'] ??
            carsResult['message'] ??
            'Gagal memuat data.';
        throw Exception(errorMsg);
      }

      return {
        'user': userResult['data']['user'],
        'banners': bannersResult['data'],
        'cars': carsResult['data'],
      };
    } catch (e) {
      // Tangkap dan lemparkan kembali error agar bisa ditangani FutureBuilder
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.formBackground,
      // Gunakan FutureBuilder sebagai root untuk mengatur semua state
      body: FutureBuilder<Map<String, dynamic>>(
        future: _homeDataFuture,
        builder: (context, snapshot) {
          // 1. Saat data sedang dimuat
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Jika terjadi error
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Terjadi Kesalahan: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loadData,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Jika data berhasil dimuat
          if (snapshot.hasData) {
            final data = snapshot.data!;
            final user = data['user'] as Map<String, dynamic>;
            final banners = List<Map<String, dynamic>>.from(data['banners']);
            final cars = List<Map<String, dynamic>>.from(data['cars']);

            return RefreshIndicator(
              onRefresh: _loadData,
              child: CustomScrollView(
                slivers: [
                  _buildSliverAppBar(user),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSearchBar(),
                      const SizedBox(height: 24),
                      _buildPromoBanners(banners),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Kategori'),
                      const SizedBox(height: 16),
                      _buildCategories(),
                      const SizedBox(height: 24),
                      _buildSectionHeader('Rekomendasi Untukmu'),
                      const SizedBox(height: 16),
                      _buildCarList(cars),
                      const SizedBox(height: 24),
                    ]),
                  ),
                ],
              ),
            );
          }

          // State default jika tidak ada apa-apa
          return const Center(child: Text('Tidak ada data.'));
        },
      ),
    );
  }

  // --- WIDGET BUILDER HELPERS ---

  SliverAppBar _buildSliverAppBar(Map<String, dynamic> user) {
    return SliverAppBar(
      backgroundColor: AppColors.formBackground,
      elevation: 0,
      pinned: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selamat Datang,',
            style: TextStyle(color: AppColors.grey, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            user['full_name'] ?? 'Pengguna',
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppColors.black,
            size: 28,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari mobil impianmu...',
          prefixIcon: const Icon(Icons.search, color: AppColors.grey),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildPromoBanners(List<Map<String, dynamic>> banners) {
    if (banners.isEmpty) return const SizedBox.shrink();

    final storageUrlBase = ApiService.getBaseUrl().replaceAll(
      '/api/',
      '/storage/',
    );

    return CarouselSlider.builder(
      itemCount: banners.length,
      itemBuilder: (context, index, realIndex) {
        final banner = banners[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: NetworkImage('$storageUrlBase${banner['image_path']}'),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 150,
        autoPlay: banners.length > 1,
        enlargeCenterPage: true,
        viewportFraction: 0.85,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const Text(
            'Lihat semua',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    final categories = ['Semua', 'SUV', 'MPV', 'Sedan', 'Hatchback'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = category;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : AppColors.white,
                borderRadius: BorderRadius.circular(30),
                border: isSelected
                    ? null
                    : Border.all(color: AppColors.lightGrey),
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarList(List<Map<String, dynamic>> cars) {
    if (cars.isEmpty) {
      return const SizedBox(
        height: 280,
        child: Center(child: Text('Tidak ada mobil tersedia saat ini.')),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: cars.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final car = cars[index];
          return CarCard(carData: car);
        },
      ),
    );
  }
}
