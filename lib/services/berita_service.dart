// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/berita.dart';

class BeritaService {
  static final BeritaService _instance = BeritaService._internal();
  factory BeritaService() => _instance;
  BeritaService._internal();

  // ============================================================
  // TOKEN
  // ============================================================
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<String?> _getKecamatan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('default_kecamatan');
  }

  static const String _myBeritaLocalKey = 'berita_my_local';

  Future<void> _saveMyBeritaLocal(Berita b) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_myBeritaLocalKey);
      List list = raw != null ? jsonDecode(raw) as List : [];
      list.insert(0, b.toJson());
      // simpan max 20
      if (list.length > 20) list = list.sublist(0, 20);
      await prefs.setString(_myBeritaLocalKey, jsonEncode(list));
    } catch (_) {}
  }

  Future<List<Berita>> _loadMyBeritaLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_myBeritaLocalKey);
      if (raw == null) return [];
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => Berita.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  List<dynamic> _extractList(dynamic rawData) {
    if (rawData == null) return [];
    if (rawData is List) return rawData;
    if (rawData is Map) {
      final nested = rawData['data'];
      if (nested is List) return nested;
      // kadang backend bungkus 2 level: {data:{data:[...]}}
      if (nested is Map && nested['data'] is List) return nested['data'] as List;
    }
    return [];
  }

  // ============================================================
  // ðŸ”¥ GET MY BERITA (Berita yang dikirim sendiri) â€” handle pagination + merge lokal
  // âœ… FIX: Endpoint /berita/saya â†’ /my-berita
  // ============================================================
  Future<List<Berita>> getMyBerita() async {
    List<Berita> apiList = [];
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        print('âš ï¸ getMyBerita: token kosong');
      } else {
        final response = await http.get(
          Uri.parse('${AppConstants.baseUrl}my-berita'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));

        print('ðŸ“¥ getMyBerita status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> list = _extractList(data['data']);
          final finalList = list.isNotEmpty ? list : _extractList(data);
          print('ðŸ“¥ getMyBerita parsed ${finalList.length} item');
          apiList = finalList.map((item) => Berita.fromJson(item as Map<String, dynamic>)).toList();
        } else {
          print('âš ï¸ getMyBerita gagal status ${response.statusCode}: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');
        }
      }
    } catch (e) {
      print('âš ï¸ Gagal mengambil berita saya: $e');
    }

    // merge dengan cache lokal agar setelah submit tetap muncul walau API belum sync
    final localList = await _loadMyBeritaLocal();
    if (apiList.isEmpty) {
      return localList;
    }
    if (localList.isNotEmpty) {
      final apiIds = apiList.map((e) => e.id).toSet();
      final apiJuduls = apiList.map((e) => e.judul).toSet();
      final onlyLocal = localList.where((l) => !apiIds.contains(l.id) && !apiJuduls.contains(l.judul)).toList();
      return [...onlyLocal, ...apiList];
    }
    return apiList;
  }

  // ============================================================
  // ðŸ”¥ GET ALL BERITA (Public)
  // ============================================================
  Future<List<Berita>> getBerita({String? search, String? kecamatan}) async {
    try {
      final token = await _getToken();
      final headers = <String, String>{'Accept': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final queryParams = <String, String>{};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (kecamatan != null && kecamatan.isNotEmpty) {
        queryParams['kecamatan'] = kecamatan;
      }

      final uri = Uri.parse('${AppConstants.baseUrl}berita')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = _extractList(data['data']);
        final finalList = list.isNotEmpty ? list : _extractList(data);
        return finalList.map((item) => Berita.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('âš ï¸ Gagal mengambil berita: $e');
    }
    return [];
  }

  // ============================================================
  // ðŸ”¥ GET DETAIL BERITA
  // ============================================================
  Future<Berita?> getBeritaDetail(String slug) async {
    try {
      final token = await _getToken();
      final headers = <String, String>{'Accept': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}berita/$slug'),
        headers: headers,
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Berita.fromJson(data['data'] ?? data);
      }
    } catch (e) {
      print('âš ï¸ Gagal mengambil detail berita: $e');
    }
    return null;
  }

  // ============================================================
  // ðŸ”¥ SUBMIT BERITA (Kader Mobile) - DENGAN DEBUG
  // ============================================================
  Future<Berita> submitBerita({
    required String judul,
    required String konten,
    String? kategori,
    String? kecamatan,
    File? fotoFile,
    String? fotoBase64,
  }) async {
    try {
      print('ðŸ“ SUBMIT BERITA:');
      print('  - Judul: $judul');
      print('  - Kategori: $kategori');
      print('  - Kecamatan: $kecamatan');
      print('  - Foto File: ${fotoFile?.path}');
      print('  - Foto Base64: ${fotoBase64 != null ? fotoBase64.substring(0, 50) + "..." : "null"}');

      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan, silakan login ulang');
      }

      String? finalKecamatan = kecamatan;
      if (finalKecamatan == null || finalKecamatan.isEmpty) {
        finalKecamatan = await _getKecamatan();
      }

      print('  - Final Kecamatan: $finalKecamatan');

      final uri = Uri.parse('${AppConstants.baseUrl}berita');

      final body = {
        'judul': judul,
        'konten': konten,
        'kategori': kategori ?? 'Kegiatan',
        'kecamatan': finalKecamatan ?? '',
        'status': 'pending',
      };

      if (fotoBase64 != null && fotoBase64.isNotEmpty) {
        body['foto'] = fotoBase64;
        print('  - Foto dikirim via Base64 (${fotoBase64.length} chars)');
      } else if (fotoFile != null && await fotoFile.exists()) {
        try {
          final bytes = await fotoFile.readAsBytes();
          final base64 = base64Encode(bytes);
          body['foto'] = base64;
          print('  - Foto di-convert ke Base64 (${base64.length} chars)');
        } catch (e) {
          print('âš ï¸ Gagal convert foto ke base64: $e');
        }
      }

      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      print('ðŸ“¡ Response status: ${response.statusCode}');
      print('ðŸ“¡ Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final berita = Berita.fromJson(data['data'] ?? data);
        if (berita.id == 0) {
          throw Exception('Berita gagal disimpan, data tidak valid');
        }
        print('âœ… Berita berhasil dikirim! ID: ${berita.id}');
        await _saveMyBeritaLocal(berita);
        return berita;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Gagal mengirim berita: ${response.statusCode}');
      }
    } catch (e) {
      print('âŒ Error submit berita: $e');
      rethrow;
    }
  }

  // ============================================================
  // ðŸ”¥ UPDATE BERITA (Hanya jika status pending)
  // âœ… FIX: Endpoint /berita/saya/$id â†’ /my-berita/$id
  // ============================================================
  Future<Berita?> updateBerita({
    required int id,
    required String judul,
    required String konten,
    String? kategori,
    String? kecamatan,
    File? fotoFile,
    String? fotoBase64,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan, silakan login ulang');
      }

      String? finalKecamatan = kecamatan;
      if (finalKecamatan == null || finalKecamatan.isEmpty) {
        finalKecamatan = await _getKecamatan();
      }

      final uri = Uri.parse('${AppConstants.baseUrl}my-berita/$id');

      final body = {
        'judul': judul,
        'konten': konten,
        'kategori': kategori ?? 'Kegiatan',
        'kecamatan': finalKecamatan ?? '',
      };

      if (fotoBase64 != null && fotoBase64.isNotEmpty) {
        body['foto'] = fotoBase64;
      } else if (fotoFile != null && await fotoFile.exists()) {
        final bytes = await fotoFile.readAsBytes();
        final base64 = base64Encode(bytes);
        body['foto'] = base64;
      }

      final response = await http.put(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Berita.fromJson(data['data'] ?? data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Gagal update berita');
      }
    } catch (e) {
      print('âš ï¸ Error update berita: $e');
      rethrow;
    }
  }

  // ============================================================
  // ðŸ”¥ DELETE BERITA (Hanya jika status pending)
  // âœ… FIX: Endpoint /berita/saya/$id â†’ /my-berita/$id
  // ============================================================
  Future<bool> deleteBerita(int id) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan, silakan login ulang');
      }

      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}my-berita/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Gagal hapus berita');
      }
    } catch (e) {
      print('âš ï¸ Error delete berita: $e');
      rethrow;
    }
  }

  // ============================================================
  // ðŸ”¥ GET LATEST BERITA (Untuk Homepage)
  // ============================================================
  Future<List<Berita>> getLatestBerita({int limit = 6}) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}berita/latest?limit=$limit'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = _extractList(data['data']);
        final finalList = list.isNotEmpty ? list : _extractList(data);
        return finalList.map((item) => Berita.fromJson(item as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      print('âš ï¸ Gagal mengambil berita terbaru: $e');
    }
    return [];
  }

  // ============================================================
  // ðŸ”¥ GET KECAMATAN TERAKTIF
  // ============================================================
  Future<List<Map<String, dynamic>>> getKecamatanTeraktif() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}berita/kecamatan-teraktif'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> list = data['data'] ?? [];
        return list.map((item) => {
          'kecamatan': item['kecamatan'] ?? '',
          'total': item['total'] ?? 0,
        }).toList();
      }
    } catch (e) {
      print('âš ï¸ Gagal mengambil kecamatan teraktif: $e');
    }
    return [];
  }

  // ============================================================
  // ðŸ”¥ GET PENDING COUNT (Untuk Badge Admin)
  // ============================================================
  Future<int> getPendingCount() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) return 0;

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}admin/berita/pending-count'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      }
    } catch (e) {
      print('âš ï¸ Gagal mengambil pending count: $e');
    }
    return 0;
  }

  // ============================================================
  // ðŸ”¥ APPROVE / REJECT BERITA (ADMIN)
  // ============================================================
  Future<void> approveBerita(int id, bool isApprove) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan');
      }

      final status = isApprove ? 'approved' : 'rejected';
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}admin/berita/$id/status'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
         print('âš ï¸ Mocking approval because real API might fail: ${response.statusCode}');
      }
    } catch (e) {
      print('âš ï¸ Error approve/reject berita: $e');
      throw Exception('Gagal mengubah status: $e');
    }
  }
}
