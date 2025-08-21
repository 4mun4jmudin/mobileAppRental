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
  late Future<List<Map<String, dynamic>>> _carsFuture;

  final List<String> bannerImages = [
    'assets/images/promo_banner_1.png',
    'assets/images/promo_banner_1.png',
  ];
  final List<String> categories = ['Semua', 'SUV', 'MPV', 'Sedan', 'Hatchback'];
  String selectedCategory = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _carsFuture = _fetchCarsFromApi();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchCarsFromApi() async {
    final result = await ApiService.fetchCars();
    if (result['success'] == true && result['data'] != null) {
      return List<Map<String, dynamic>>.from(result['data']);
    } else {
      throw Exception(result['message'] ?? 'Gagal memuat data mobil');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.formBackground,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildPromoBanners(),
              const SizedBox(height: 24),
              _buildSectionHeader('Kategori'),
              const SizedBox(height: 16),
              _buildCategories(),
              const SizedBox(height: 24),
              _buildSectionHeader('Rekomendasi Untukmu'),
              const SizedBox(height: 16),
              _buildCarList(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.formBackground,
      elevation: 0,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lokasi Anda',
            style: TextStyle(color: AppColors.grey, fontSize: 12),
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.location_on, color: AppColors.primaryGreen, size: 16),
              SizedBox(width: 4),
              Text(
                'Jakarta, Indonesia',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
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

  Widget _buildPromoBanners() {
    return CarouselSlider.builder(
      itemCount: bannerImages.length,
      itemBuilder: (context, index, realIndex) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage(bannerImages[index]),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 150,
        autoPlay: true,
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

  Widget _buildCarList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _carsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: 280,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Gagal memuat data: ${snapshot.error}'),
              ),
            ),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 280,
            child: Center(child: Text('Tidak ada mobil tersedia saat ini.')),
          );
        }

        final cars = snapshot.data!;
        return SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cars.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final car = cars[index];
              final baseUrl = ApiService.getBaseUrl().replaceAll('/api/', '');
              final imageUrl = (car['image_urls'] as List).isNotEmpty
                  ? '$baseUrl/storage/${car['image_urls'][0]}'
                  : null;

              return CarCard(
                carId: car['id'].toString(),
                imageUrl: imageUrl,
                name: '${car['brand']} ${car['model']}',
                rating:
                    double.tryParse(
                      car['reviews_avg_rating']?.toString() ?? '0.0',
                    ) ??
                    0.0,
                pricePerDay:
                    double.tryParse(car['price_per_day'].toString()) ?? 0.0,
              );
            },
          ),
        );
      },
    );
  }
}
