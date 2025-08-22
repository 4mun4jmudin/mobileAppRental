import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static final String _baseUrl = getBaseUrl();
  static const Duration _timeout = Duration(seconds: 20);
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static String getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:8000/api/';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/';
    } else {
      return 'http://192.168.1.89:8000/api/';
    }
  }

  // --- Helpers ---
  static Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  static Future<Map<String, String>> _getHeaders({bool isPost = false}) async {
    final token = await getToken();
    final headers = {
      'Accept': 'application/json',
      if (isPost) 'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (!response.headers['content-type']!.contains('application/json')) {
      return {'success': false, 'message': 'Respons server tidak valid.'};
    }

    final body = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return {
        'success': true,
        'data': body,
        'message': body['message'] ?? 'Sukses',
      };
    } else {
      return {
        'success': false,
        'message': body['message'] ?? 'Terjadi kesalahan.',
      };
    }
  }

  // --- Token Management ---
  static Future<void> saveToken(String token) async =>
      _secureStorage.write(key: 'access_token', value: token);
  static Future<String?> getToken() => _secureStorage.read(key: 'access_token');
  static Future<void> clearToken() =>
      _secureStorage.delete(key: 'access_token');

  static Future<Map<String, dynamic>> _get(String path) async {
    try {
      final response = await http
          .get(_uri(path), headers: await _getHeaders())
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
          .post(
            _uri(path),
            headers: await _getHeaders(isPost: true),
            body: jsonEncode(body),
          )
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
    // Backend tidak mengirim body JSON untuk register, jadi kita gunakan cara lama
    try {
      final response = await http
          .post(
            _uri('register'),
            headers: {'Accept': 'application/json'},
            body: {
              'full_name': fullName,
              'email': email,
              'password': password,
              'password_confirmation': passwordConfirmation,
              'role': 'penyewa',
            },
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } on SocketException {
      return {'success': false, 'message': 'Tidak ada koneksi internet.'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi masalah: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // Backend juga tidak mengirim body JSON untuk login
    try {
      final response = await http
          .post(
            _uri('login'),
            headers: {'Accept': 'application/json'},
            body: {'email': email, 'password': password},
          )
          .timeout(_timeout);

      final result = _handleResponse(response);

      // --- PERBAIKAN UTAMA DI SINI ---
      // Simpan token dari key 'access_token' yang benar
      if (result['success'] == true &&
          result['data']?['access_token'] != null) {
        await saveToken(result['data']['access_token']);
      }
      return result;
    } on SocketException {
      return {'success': false, 'message': 'Tidak ada koneksi internet.'};
    } catch (e) {
      return {'success': false, 'message': 'Terjadi masalah: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      await _post('logout', {});
    } catch (e) {
      // Abaikan error saat logout
    } finally {
      await clearToken();
    }
    return {'success': true, 'message': 'Logout berhasil.'};
  }

  // --- App Data Endpoints (Tidak Berubah) ---
  static Future<Map<String, dynamic>> fetchCars() => _get('cars');
  static Future<Map<String, dynamic>> fetchBanners() => _get('banners');
  static Future<Map<String, dynamic>> fetchCarDetails(String carId) =>
      _get('cars/$carId');
  static Future<Map<String, dynamic>> fetchMyBookings() => _get('my-bookings');
  static Future<Map<String, dynamic>> fetchUser() => _get('user');
}

// --- Helper untuk Snackbar (Tidak Berubah) ---
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
    ),
  );
}
