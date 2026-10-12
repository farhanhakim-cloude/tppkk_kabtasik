// lib/services/notifikasi_service.dart
// HTTP client ke API Laravel: {baseUrl}notifikasi (auth sanctum).
// Pola sama seperti CatatanKegiatanService: token + timeout + pesan Indonesia.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/notifikasi.dart';

class NotifikasiService {
  final http.Client _client = http.Client();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Map<String, String> _headers(String? token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      };

  /// List notifikasi milik sendiri (terbaru dulu).
  Future<List<Notifikasi>> getNotifikasi() async {
    final token = await _getToken();
    final res = await _client
        .get(
          Uri.parse('${AppConstants.baseUrl}${AppConstants.notifikasi}'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 15));

    if (res.statusCode == 401) {
      throw Exception('Sesi habis. Silakan login kembali.');
    }
    if (res.statusCode != 200) {
      throw Exception('Gagal memuat notifikasi (${res.statusCode}).');
    }

    final body = jsonDecode(res.body);
    final data = body is Map ? body['data'] : null;
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Notifikasi.fromJson)
        .toList();
  }

  /// Jumlah belum dibaca (untuk badge lonceng). Gagal = 0 (jangan ganggu dashboard).
  Future<int> getUnreadCount() async {
    try {
      final token = await _getToken();
      final res = await _client
          .get(
            Uri.parse('${AppConstants.baseUrl}${AppConstants.notifikasi}/unread-count'),
            headers: _headers(token),
          )
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return 0;
      final body = jsonDecode(res.body);
      final data = body is Map ? body['data'] : null;
      final n = data is Map ? data['unread_count'] : 0;
      return (n is int) ? n : int.tryParse(n.toString()) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Tandai satu notifikasi dibaca.
  Future<void> tandaiBaca(String id) async {
    final token = await _getToken();
    final res = await _client
        .post(
          Uri.parse('${AppConstants.baseUrl}${AppConstants.notifikasi}/$id/baca'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Gagal menandai dibaca (${res.statusCode}).');
    }
  }

  /// Tandai semua dibaca.
  Future<void> bacaSemua() async {
    final token = await _getToken();
    final res = await _client
        .post(
          Uri.parse('${AppConstants.baseUrl}${AppConstants.notifikasi}/baca-semua'),
          headers: _headers(token),
        )
        .timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('Gagal menandai semua dibaca (${res.statusCode}).');
    }
  }

  void dispose() => _client.close();
}
