import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // 1. Tambahkan import ini
import 'app/app.dart';

// 2. Ubah main menjadi async dan tambahkan kode inisialisasi
void main() async {
  // Baris ini memastikan semua plugin Flutter siap sebelum aplikasi berjalan
  WidgetsFlutterBinding.ensureInitialized();

  // Baris ini memuat data lokal untuk bahasa Indonesia
  await initializeDateFormatting('id_ID', null);

  // Setelah data siap, jalankan aplikasi seperti biasa
  runApp(const MyApp());
}
