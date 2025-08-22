import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ApiService bertanggung jawab untuk semua komunikasi antara Flutter dan Laravel API.
class ApiService {
  // PENTING: Base URL sekarang dinamis untuk menangani berbagai platform.
  static final String _baseUrl = getBaseUrl();
  static const Duration _timeout = Duration(seconds: 20);

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Helper untuk menentukan base URL berdasarkan platform
  static String getBaseUrl() {
    if (kIsWeb) {
      // Untuk web (Chrome, Firefox, dll)
      return 'http://localhost:8000/api/';
    } else if (Platform.isAndroid) {
      // Untuk Android Emulator, gunakan alamat khusus ini untuk mengakses localhost komputer
      return 'http://10.0.2.2:8000/api/';
    } else {
      // Default untuk perangkat fisik (iOS/Android) atau iOS Simulator
      // Ganti IP ini dengan alamat IP lokal komputer Anda.
      // Contoh: 'http://192.168.1.5:8000/api/'
      return 'http://192.168.137.1:8000/api/'; // PASTIKAN IP INI SESUAI
    }
  }

  // --- Helpers ---
  static Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  static Future<Map<String, String>> _headers() async {
    final token = await getToken();
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    // Tangani kasus di mana respons bukan JSON (misalnya, halaman error HTML dari Laravel)
    if (!response.headers['content-type']!.contains('application/json')) {
      return {
        'success': false,
        'message': 'Respons server tidak valid. Cek log Laravel untuk error.',
      };
    }

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        'success': true,
        // Backend Anda mungkin membungkus data dalam key 'data' atau tidak,
        // kode ini menangani keduanya.
        'data': body['data'] ?? body,
        'message': body['message'] ?? 'Sukses',
      };
    } else {
      String errorMessage = 'Terjadi kesalahan.';
      if (body['message'] is String) {
        errorMessage = body['message'];
      } else if (body['errors'] is Map) {
        // Ambil pesan error validasi pertama dari Laravel
        errorMessage = (body['errors'] as Map).values.first[0];
      }
      return {'success': false, 'message': errorMessage};
    }
  }

  // --- Token Management ---
  static Future<void> saveToken(String token) async =>
      _secureStorage.write(key: 'access_token', value: token);
  static Future<String?> getToken() => _secureStorage.read(key: 'access_token');
  static Future<void> clearToken() =>
      _secureStorage.delete(key: 'access_token');

  // --- Generic Request Methods ---
  static Future<Map<String, dynamic>> _get(String path) async {
    try {
      final response = await http
          .get(_uri(path), headers: await _headers())
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'Tidak ada koneksi internet.'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi masalah: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(_uri(path), headers: await _headers(), body: jsonEncode(body))
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'Tidak ada koneksi internet.'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi masalah: ${e.toString()}'};
    }
  }

  // --- Auth Endpoints ---
  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    final result = await _post('register', {
      'full_name': fullName,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'role': 'penyewa',
    });
    // Simpan token setelah registrasi berhasil
    if (result['success'] == true && result['data']?['access_token'] != null) {
      await saveToken(result['data']['access_token']);
    }
    return result;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _post('login', {'email': email, 'password': password});
    // Simpan token setelah login berhasil
    if (result['success'] == true && result['data']?['access_token'] != null) {
      final userRole = result['data']?['user']?['role'];
      if (userRole != 'penyewa') {
        return {
          'success': false,
          'message': 'Hanya customer yang dapat login.',
        };
      }
      await saveToken(result['data']['access_token']);
    }
    return result;
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      await _post('logout', {});
    } catch (e) {
      // Abaikan error saat logout, yang penting token lokal dihapus
    } finally {
      await clearToken();
    }
    return {'success': true, 'message': 'Logout berhasil.'};
  }

  // --- App Data Endpoints ---
  static Future<Map<String, dynamic>> fetchCars() => _get('cars');

  static Future<Map<String, dynamic>> fetchBanners() => _get('banners');

  static Future<Map<String, dynamic>> fetchCarDetails(String carId) =>
      _get('cars/$carId');

  static Future<Map<String, dynamic>> fetchMyBookings() => _get('my-bookings');

  static Future<Map<String, dynamic>> fetchUser() => _get('user');
}

// --- Helper untuk Snackbar ---
void showSnackbar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(10),
    ),
  );
}
