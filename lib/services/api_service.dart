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

// ⚠️ SESUAIKAN — import model 3 sheet baru
// Kalau nama file / class beda — ubah di sini
// import '../models/data_umum_pkk.dart';
// import '../models/rekap_kegiatan_warga_berjenjang.dart';
// import '../models/rekap_bumil_berjenjang.dart';

class ApiService {
  final http.Client _client = http.Client();

  // ============================================================
  // HELPER: Handle pagination response
  // ============================================================
  List<dynamic> _extractList(dynamic rawData) {
    if (rawData == null) return [];
    if (rawData is List) return rawData;
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
  // POKJA 1-4
  // ============================================================
  Future<Pokja1Response> getPokja1() async {
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.pokja1}'),
    );
    return _handlePokja1Response(response);
  }

  Future<Pokja2Response> getPokja2() async {
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.pokja2}'),
    );
    return _handlePokja2Response(response);
  }

  Future<Pokja3Response> getPokja3() async {
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.pokja3}'),
    );
    return _handlePokja3Response(response);
  }

  Future<Pokja4Response> getPokja4() async {
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.pokja4}'),
    );
    return _handlePokja4Response(response);
  }

  Future<SekretariatResponse> getSekretariat() async {
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.sekretariat}'),
    );
    return _handleSekretariatResponse(response);
  }

  // ============================================================
  // ✅ TAMBAH — DATA UMUM PKK
  // ============================================================

  /// GET /api/data-umum-pkk
  /// Ambil semua data umum PKK — filter tahun, level, wilayah
  Future<List<Map<String, dynamic>>> getDataUmumPkk({
    String? tahun,
    String? level,
    int? wilayahId,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (tahun != null) queryParams['tahun'] = tahun;
      if (level != null) queryParams['level'] = level;
      if (wilayahId != null) queryParams['wilayah_id'] = wilayahId.toString();
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.dataUmumPkk}',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = _extractList(data['data']);
        return list.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Gagal load data umum PKK: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal load data umum PKK: $e');
    }
  }

  /// GET /api/data-umum-pkk/{id}
  Future<Map<String, dynamic>> getDataUmumPkkDetail(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.dataUmumPkk}/$id'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else {
        throw Exception('Gagal load detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal load detail: $e');
    }
  }

  /// POST /api/data-umum-pkk — butuh token
  Future<Map<String, dynamic>> createDataUmumPkk(
    Map<String, dynamic> payload,
    String token,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.dataUmumPkk}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 422) {
        final err = jsonDecode(response.body);
        throw Exception('Validasi gagal: ${err['errors'] ?? err['message']}');
      } else if (response.statusCode == 409) {
        throw Exception('Data sudah ada — duplikat');
      } else {
        throw Exception('Gagal simpan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal simpan: $e');
    }
  }

  /// PUT /api/data-umum-pkk/{id}
  Future<Map<String, dynamic>> updateDataUmumPkk(
    int id,
    Map<String, dynamic> payload,
    String token,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.dataUmumPkk}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else {
        throw Exception('Gagal update: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal update: $e');
    }
  }

  /// DELETE /api/data-umum-pkk/{id}
  Future<void> deleteDataUmumPkk(int id, String token) async {
    try {
      final response = await _client.delete(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.dataUmumPkk}/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Gagal hapus: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal hapus: $e');
    }
  }

  // ============================================================
  // ✅ TAMBAH — REKAP KEGIATAN WARGA
  // ============================================================

  Future<List<Map<String, dynamic>>> getRekapKegiatanWarga({
    String? tahun,
    String? level,
    int? wilayahId,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (tahun != null) queryParams['tahun'] = tahun;
      if (level != null) queryParams['level'] = level;
      if (wilayahId != null) queryParams['wilayah_id'] = wilayahId.toString();
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.rekapKegiatanWarga}',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = _extractList(data['data']);
        return list.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Gagal load rekap kegiatan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal load rekap kegiatan: $e');
    }
  }

  Future<Map<String, dynamic>> createRekapKegiatanWarga(
    Map<String, dynamic> payload,
    String token,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.rekapKegiatanWarga}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else {
        throw Exception('Gagal simpan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal simpan: $e');
    }
  }

  Future<Map<String, dynamic>> updateRekapKegiatanWarga(
    int id,
    Map<String, dynamic> payload,
    String token,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.rekapKegiatanWarga}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else {
        throw Exception('Gagal update: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal update: $e');
    }
  }

  Future<void> deleteRekapKegiatanWarga(int id, String token) async {
    try {
      final response = await _client.delete(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.rekapKegiatanWarga}/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Gagal hapus: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal hapus: $e');
    }
  }

  // ============================================================
  // ✅ TAMBAH — REKAP BUMIL
  // ============================================================

  Future<List<Map<String, dynamic>>> getRekapBumil({
    String? tahun,
    String? bulan,
    String? level,
    int? wilayahId,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (tahun != null) queryParams['tahun'] = tahun;
      if (bulan != null) queryParams['bulan'] = bulan;
      if (level != null) queryParams['level'] = level;
      if (wilayahId != null) queryParams['wilayah_id'] = wilayahId.toString();
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse(
        '${AppConstants.baseUrl}${AppConstants.rekapBumil}',
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      final response = await _client.get(uri).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final list = _extractList(data['data']);
        return list.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Gagal load rekap bumil: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal load rekap bumil: $e');
    }
  }

  Future<Map<String, dynamic>> createRekapBumil(
    Map<String, dynamic> payload,
    String token,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.rekapBumil}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else if (response.statusCode == 422) {
        final err = jsonDecode(response.body);
        throw Exception('Validasi gagal: ${err['errors'] ?? err['message']}');
      } else if (response.statusCode == 409) {
        throw Exception('Data sudah ada — duplikat');
      } else {
        throw Exception('Gagal simpan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal simpan: $e');
    }
  }

  Future<Map<String, dynamic>> updateRekapBumil(
    int id,
    Map<String, dynamic> payload,
    String token,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.rekapBumil}/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? data;
      } else {
        throw Exception('Gagal update: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal update: $e');
    }
  }

  Future<void> deleteRekapBumil(int id, String token) async {
    try {
      final response = await _client.delete(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.rekapBumil}/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw Exception('Gagal hapus: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Gagal hapus: $e');
    }
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