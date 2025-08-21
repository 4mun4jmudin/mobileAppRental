import 'package:flutter/material.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart'; // Ganti nama proyekmu
import 'package:mobile_app_rental/features/activity/presentation/screens/activity_hub_screen.dart'; // Ganti nama proyekmu
import 'package:mobile_app_rental/features/favorite/presentation/screens/favorite_screen.dart';
import 'package:mobile_app_rental/features/home/presentation/screens/home_page.dart';
import 'package:mobile_app_rental/features/profile/presentation/screens/profile_screen.dart'; // Ganti nama proyekmu

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Indeks untuk tab yang aktif

  // Daftar halaman yang akan ditampilkan sesuai tab
  static const List<Widget> _pages = <Widget>[
    HomePage(), // Halaman Beranda (konten yang kita pindahkan tadi)
    ActivityHubScreen(), // Halaman Aktivitas
    FavoriteScreen(),
    ProfileScreen(),
    // Placeholder untuk halaman Favorit & Profil
    // Center(child: Text('Halaman Favorit')),
    // Center(child: Text('Halaman Profil')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Body akan berubah sesuai dengan tab yang dipilih
      body: _pages.elementAt(_selectedIndex),

      // Navigasi Bawah
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, // Agar semua label terlihat
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Aktivitas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Favorit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
