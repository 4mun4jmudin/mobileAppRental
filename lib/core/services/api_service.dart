import 'dart:convert';
import 'dart:io'; // HAPUS/UBAH jika targetnya Flutter Web
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ApiService bertanggung jawab untuk semua komunikasi antara Flutter dan Laravel API.
class ApiService {
  // NOTE: jangan panggil getBaseUrl() di saat inisialisasi statis jika kamu butuh build web tanpa dart:io.
  // Kita gunakan getter supaya lebih fleksibel.
  static String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api/'; // ubah jika perlu
    }
    // Untuk safety, bungkus penggunaan Platform dengan try/catch
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api/';
      }
      // default untuk perangkat fisik / simulator iOS atau Android lainnya
      return 'http://192.168.1.89:8000/api/';
    } catch (e) {
      // Jika Platform tidak tersedia (mis. build web) fallback ke localhost
      return 'http://localhost:8000/api/';
    }
  }

  static const Duration _timeout = Duration(seconds: 20);
  static final FlutterSecureStorage _secureStorage =
      const FlutterSecureStorage();

  // Helper untuk membuat URI
  static Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  // Headers, sertakan Authorization jika ada token
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

  // Tangani response dengan aman
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final contentType = response.headers['content-type'] ?? '';

    // Jika header content-type tidak menyebutkan JSON, coba tetap parse tapi siapkan fallback
    if (!contentType.toLowerCase().contains('application/json')) {
      // debug log
      debugPrint('WARNING: content-type bukan JSON: $contentType');
      debugPrint(
        'Response body (truncated): ${response.body.length > 500 ? response.body.substring(0, 500) + '...' : response.body}',
      );
      // coba parse jika body terlihat seperti JSON
      try {
        final maybe = jsonDecode(response.body);
        // lanjutkan normal dengan 'maybe' sebagai body
        return _processDecodedBody(response.statusCode, maybe);
      } catch (e) {
        return {
          'success': false,
          'message':
              'Respons server tidak valid (bukan JSON). Cek log Laravel atau network proxy.',
          'statusCode': response.statusCode,
          'raw': response.body,
        };
      }
    }

    // Jika content-type JSON, coba decode dengan aman
    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (e) {
      debugPrint('JSON decode error: ${e.toString()}');
      return {
        'success': false,
        'message': 'Gagal mem-parse JSON dari server: ${e.toString()}',
        'statusCode': response.statusCode,
        'raw': response.body,
      };
    }

    return _processDecodedBody(response.statusCode, decoded);
  }

  // Proses body yang sudah didecode menjadi bentuk Map yang konsisten
  static Map<String, dynamic> _processDecodedBody(
    int statusCode,
    dynamic body,
  ) {
    // Ambil data jika backend membungkus di 'data', jika tidak gunakan seluruh body
    dynamic data;
    String message = 'Sukses';
    if (body is Map && body.containsKey('data')) {
      data = body['data'];
      message = (body['message'] is String) ? body['message'] : message;
    } else {
      data = body;
      if (body is Map && body['message'] is String) {
        message = body['message'];
      }
    }

    if (statusCode >= 200 && statusCode < 300) {
      return {'success': true, 'data': data, 'raw': body, 'message': message};
    } else {
      // Coba ambil pesan error dari berbagai bentuk Laravel
      String errorMessage = 'Terjadi kesalahan (status $statusCode).';

      if (body is String && body.isNotEmpty) {
        errorMessage = body;
      } else if (body is Map) {
        if (body['message'] is String) {
          errorMessage = body['message'];
        } else if (body['errors'] is Map) {
          // body['errors'] biasanya Map<String, List<String>>
          final first = (body['errors'] as Map).values.first;
          if (first is List && first.isNotEmpty) {
            errorMessage = first.first.toString();
          } else if (first is String) {
            errorMessage = first;
          }
        }
      }

      return {
        'success': false,
        'message': errorMessage,
        'statusCode': statusCode,
        'raw': body,
      };
    }
  }

  // --- Token Management ---
  static Future<void> saveToken(String token) async =>
      _secureStorage.write(key: 'access_token', value: token);
  static Future<String?> getToken() => _secureStorage.read(key: 'access_token');
  static Future<void> clearToken() =>
      _secureStorage.delete(key: 'access_token');

  // Helper kecil untuk mengekstrak token dari berbagai format respons
  static String? _extractTokenFromRaw(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map) {
      // cek beberapa lokasi umum
      if (raw['token'] != null && raw['token'] is String) return raw['token'];
      if (raw['access_token'] != null && raw['access_token'] is String)
        return raw['access_token'];

      if (raw['data'] is Map) {
        final d = raw['data'] as Map;
        if (d['token'] != null && d['token'] is String) return d['token'];
        if (d['access_token'] != null && d['access_token'] is String)
          return d['access_token'];
      }
    }
    return null;
  }

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
    });

    if (result['success'] == true) {
      final token = _extractTokenFromRaw(result['raw']);
      if (token != null) await saveToken(token);
    }
    return result;
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _post('login', {'email': email, 'password': password});
    if (result['success'] == true) {
      final token = _extractTokenFromRaw(result['raw']);
      if (token != null) await saveToken(token);
    }
    return result;
  }

  static Future<Map<String, dynamic>> logout() async {
    try {
      await _post('logout', {});
    } catch (e) {
      // Abaikan error saat logout, yang penting token lokal dihapus
      debugPrint('Logout request error: ${e.toString()}');
    } finally {
      await clearToken();
    }
    return {'success': true, 'message': 'Logout berhasil.'};
  }

  // --- App Data Endpoints ---
  static Future<Map<String, dynamic>> fetchCars() => _get('cars');
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
