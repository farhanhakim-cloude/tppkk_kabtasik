// lib/services/wilayah_service.dart
// Master kecamatan → desa Kab. Tasikmalaya dari backend
// (GET /api/wilayah/desa?kecamatan=X, sumber: AdminDesaSeeder::DATA_DESA).
// Hasil di-cache per kecamatan di SharedPreferences agar picker desa
// tetap jalan offline. Gagal total → lempar, UI fallback ke ketik manual.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class WilayahService {
  static final WilayahService _instance = WilayahService._internal();
  factory WilayahService() => _instance;
  WilayahService._internal();

  String get _endpoint => '${AppConstants.baseUrl}wilayah/desa';

  static String _cacheKey(String kecamatan) =>
      'wilayah_desa_${kecamatan.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}';

  Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// List desa pada [kecamatan]. Urutan ikut backend.
  Future<List<String>> getDesa(String kecamatan) async {
    final kec = kecamatan.trim();
    if (kec.isEmpty) return [];
    try {
      final url = '$_endpoint?kecamatan=${Uri.encodeQueryComponent(kec)}';
      final res = await http
          .get(Uri.parse(url), headers: await _headers())
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        final data = decoded is Map ? decoded['data'] : null;
        if (data is List) {
          final list =
              data.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
          if (list.isNotEmpty) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString(_cacheKey(kec), jsonEncode(list));
            return list;
          }
        }
      }
    } catch (_) {}
    // Fallback: cache lokal terakhir.
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey(kec));
      if (raw != null && raw.isNotEmpty) {
        final cached = jsonDecode(raw);
        if (cached is List) {
          return cached.map((e) => e.toString()).toList();
        }
      }
    } catch (_) {}
    return [];
  }
}
