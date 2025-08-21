import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_rental/core/constants/app_colors.dart';
import 'package:mobile_app_rental/core/services/api_service.dart';
import 'package:mobile_app_rental/features/profile/presentation/widgets/profile_menu_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    setState(() {
      _userFuture = ApiService.fetchUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.white,
        elevation: 1,
      ),
      backgroundColor: AppColors.formBackground,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data?['success'] != true) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Gagal memuat profil.'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadUserData,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final userData = snapshot.data!['data'];
          final name = userData['full_name'] ?? 'Pengguna';
          final email = userData['email'] ?? '-';

          return RefreshIndicator(
            onRefresh: () async => _loadUserData(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 24),
                _buildProfileHeader(
                  name: name,
                  email: email,
                  avatarUrl:
                      userData['avatar_url'] ??
                      '', // Ganti jika Anda punya kolom avatar
                ),
                const SizedBox(height: 24),
                _buildMenuList(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader({
    required String name,
    required String email,
    required String avatarUrl,
  }) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: AppColors.primaryGreen,
          backgroundImage: avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
          child: avatarUrl.isEmpty
              ? Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'A',
                  style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: const TextStyle(fontSize: 16, color: AppColors.grey),
        ),
      ],
    );
  }

  Widget _buildMenuList(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          ProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profil',
            onTap: () {
              // Navigasi ke halaman edit profil (buat nanti)
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ProfileMenuItem(
            icon: Icons.lock_outline,
            title: 'Ubah Kata Sandi',
            onTap: () {
              // Navigasi ke halaman ubah kata sandi
            },
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Pusat Bantuan',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ProfileMenuItem(
            icon: Icons.logout,
            title: 'Keluar',
            isDanger: true,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Panggil API untuk logout dari server
                await ApiService.logout();

                if (!mounted) return;
                // Arahkan ke halaman welcome dan hapus semua halaman sebelumnya
                context.go('/');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}
