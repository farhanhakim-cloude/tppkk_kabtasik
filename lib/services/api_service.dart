// lib/services/api_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/pokja_1_model.dart';
import '../models/pokja_2_model.dart';
import '../models/pokja_3_model.dart';
import '../models/pokja_4_model.dart';
import '../models/sekretariat_model.dart';
import '../models/berita.dart';
// ignore_for_file: avoid_print, unused_import
import '../models/user.dart';
import 'berita_service.dart';

class ApiService {
  final http.Client _client = http.Client();

  // ============================================================
  // HELPER: Handle pagination response
  // Laravel paginate() return: { data: { data: [...], current_page, ... } }
  // ============================================================
  List<dynamic> _extractList(dynamic rawData) {
    // Kalau null / bukan Map/List → return empty
    if (rawData == null) return [];

    // Kalau langsung List → return
    if (rawData is List) return rawData;

    // Kalau Map (pagination) → ambil 'data'-nya
    if (rawData is Map) {
      final nested = rawData['data'];
      if (nested is List) return nested;
    }

    return [];
  }

  // ============================================================
  // AUTH
  // ============================================================
  Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await _client.post(
      Uri.parse('${AppConstants.baseUrl}login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login gagal: ${response.statusCode}');
    }
  }

  Future<void> logout(String token) async {
    final response = await _client.post(
      Uri.parse('${AppConstants.baseUrl}logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Logout gagal: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal load profile: ${response.statusCode}');
    }
  }

  // ============================================================
  // POKJA 1
  // ============================================================
  Future<Pokja1Response> getPokja1() async {
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.pokja1}'),
    );
    return _handlePokja1Response(response);
  }

  // ============================================================
  // POKJA 2
  // ============================================================
  Future<Pokja2Response> getPokja2() async {
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.pokja2}'),
    );
    return _handlePokja2Response(response);
  }

  // ============================================================
  // POKJA 3
  // ============================================================
  Future<Pokja3Response> getPokja3() async {
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.pokja3}'),
    );
    return _handlePokja3Response(response);
  }

  // ============================================================
  // POKJA 4
  // ============================================================
  Future<Pokja4Response> getPokja4() async {
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.pokja4}'),
    );
    return _handlePokja4Response(response);
  }

  // ============================================================
  // SEKRETARIAT
  // ============================================================
  Future<SekretariatResponse> getSekretariat() async {
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.sekretariat}'),
    );
    return _handleSekretariatResponse(response);
  }

  // ============================================================
  // BERITA
  // ============================================================
  Future<List<Berita>> getBerita() async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.berita}'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 🔥 FIX: pakai helper
        final list = _extractList(data['data']);
        return list.map((item) => Berita.fromJson(item)).toList();
      } else {
        throw Exception('Gagal load berita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal load berita: $e');
    }
  }

  Future<List<Berita>> getBeritaLatest() async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.beritaLatest}'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 🔥 FIX: pakai helper
        final list = _extractList(data['data']);
        return list.map((item) => Berita.fromJson(item)).toList();
      } else {
        throw Exception('Gagal load berita terbaru: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal load berita terbaru: $e');
    }
  }

  Future<Berita> getBeritaDetail(String slug) async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.berita}/$slug'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Berita.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Gagal load detail berita: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal load detail berita: $e');
    }
  }

  // ============================================================
  // 🔥 SUBMIT BERITA
  // ============================================================
  Future<Berita> submitBerita({
    required String judul,
    required String ringkasan,
    String? konten,
    String? kategori,
    String? kecamatan,
    File? fotoFile,
    String? fotoBase64,
  }) async {
    try {
      final beritaService = BeritaService();
      final kontenFinal = konten ?? ringkasan;

      final result = await beritaService.submitBerita(
        judul: judul,
        konten: kontenFinal,
        kategori: kategori,
        kecamatan: kecamatan,
        fotoFile: fotoFile,
        fotoBase64: fotoBase64,
      );

      if (result.id == 0) {
        throw Exception('Berita gagal disimpan, data tidak valid');
      }

      return result;
    } catch (e) {
      print('❌ ApiService.submitBerita error: $e');
      throw Exception('Gagal submit berita: $e');
    }
  }

  // ============================================================
  // 🔥 MY BERITA
  // ✅ FIX: Endpoint /berita/saya → /my-berita
  // ============================================================
  Future<List<Berita>> getMyBerita(String token) async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}my-berita'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 🔥 FIX: pakai helper untuk handle pagination
        final list = _extractList(data['data']);
        return list.map((item) => Berita.fromJson(item)).toList();
      } else {
        throw Exception('Gagal load berita saya: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal load berita saya: $e');
    }
  }

  // ============================================================
  // GALERI
  // ============================================================
  Future<List<dynamic>> getGaleri() async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.galeri}'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 🔥 FIX: pakai helper
        return _extractList(data['data']);
      } else {
        throw Exception('Gagal load galeri: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal load galeri: $e');
    }
  }

  // ============================================================
  // AGENDA
  // ============================================================
  Future<List<dynamic>> getAgenda() async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.agenda}'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 🔥 FIX: pakai helper
        return _extractList(data['data']);
      } else {
        throw Exception('Gagal load agenda: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal load agenda: $e');
    }
  }

  // ============================================================
  // LAPORAN KEGIATAN
  // ============================================================
  Future<List<dynamic>> getLaporanKegiatan() async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.laporanKegiatan}'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // 🔥 FIX: pakai helper untuk handle pagination
        return _extractList(data['data']);
      } else {
        throw Exception('Gagal load laporan kegiatan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal load laporan kegiatan: $e');
    }
  }

  Future<Map<String, dynamic>> createLaporanKegiatan(
      Map<String, dynamic> data, String token) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.laporanKegiatan}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Gagal buat laporan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal buat laporan: $e');
    }
  }

  // ============================================================
  // HANDLE RESPONSE
  // ============================================================
  Pokja1Response _handlePokja1Response(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Pokja1Response.fromJson(data);
    } else {
      throw Exception('Gagal load Pokja 1: ${response.statusCode}');
    }
  }

  Pokja2Response _handlePokja2Response(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Pokja2Response.fromJson(data);
    } else {
      throw Exception('Gagal load Pokja 2: ${response.statusCode}');
    }
  }

  Pokja3Response _handlePokja3Response(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Pokja3Response.fromJson(data);
    } else {
      throw Exception('Gagal load Pokja 3: ${response.statusCode}');
    }
  }

  Pokja4Response _handlePokja4Response(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Pokja4Response.fromJson(data);
    } else {
      throw Exception('Gagal load Pokja 4: ${response.statusCode}');
    }
  }

  SekretariatResponse _handleSekretariatResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SekretariatResponse.fromJson(data);
    } else {
      throw Exception('Gagal load Sekretariat: ${response.statusCode}');
    }
  }

  void dispose() {
    _client.close();
  }
}