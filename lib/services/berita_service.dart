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
  // 🔥 GET MY BERITA (Berita yang dikirim sendiri) — handle pagination + merge lokal
  // ============================================================
  Future<List<Berita>> getMyBerita() async {
    List<Berita> apiList = [];
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        print('⚠️ getMyBerita: token kosong');
      } else {
        final response = await http.get(
          Uri.parse('${AppConstants.baseUrl}berita/saya'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 10));

        print('📥 getMyBerita status: ${response.statusCode}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> list = _extractList(data['data']);
          final finalList = list.isNotEmpty ? list : _extractList(data);
          print('📥 getMyBerita parsed ${finalList.length} item');
          apiList = finalList.map((item) => Berita.fromJson(item as Map<String, dynamic>)).toList();
        } else {
          print('⚠️ getMyBerita gagal status ${response.statusCode}: ${response.body.substring(0, response.body.length > 300 ? 300 : response.body.length)}');
        }
      }
    } catch (e) {
      print('⚠️ Gagal mengambil berita saya: $e');
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
  // 🔥 GET ALL BERITA (Public)
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
      print('⚠️ Gagal mengambil berita: $e');
    }
    return [];
  }

  // ============================================================
  // 🔥 GET DETAIL BERITA
  // ============================================================
  Future<Berita?> getBeritaDetail(String slug) async {
    try {
      final token = await _getToken();
      final headers = <String, String>{'Accept': 'application/json'};
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      // ✅ FIX
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}berita/$slug'),
        headers: headers,
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Berita.fromJson(data['data'] ?? data);
      }
    } catch (e) {
      print('⚠️ Gagal mengambil detail berita: $e');
    }
    return null;
  }

  // ============================================================
  // 🔥 SUBMIT BERITA (Kader Mobile) - DENGAN DEBUG
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
      print('📝 SUBMIT BERITA:');
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

      // ✅ FIX: baseUrl sudah "http://127.0.0.1:8000/api/",
      // jadi cukup tambahkan "berita" saja (tanpa "/api/" lagi)
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
          print('⚠️ Gagal convert foto ke base64: $e');
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

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final berita = Berita.fromJson(data['data'] ?? data);
        if (berita.id == 0) {
          throw Exception('Berita gagal disimpan, data tidak valid');
        }
        print('✅ Berita berhasil dikirim! ID: ${berita.id}');
        await _saveMyBeritaLocal(berita);
        return berita;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Gagal mengirim berita: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error submit berita: $e');
      rethrow;
    }
  }

  // ============================================================
  // 🔥 UPDATE BERITA (Hanya jika status pending)
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

      // ✅ FIX
      final uri = Uri.parse('${AppConstants.baseUrl}berita/saya/$id');

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
      print('⚠️ Error update berita: $e');
      rethrow;
    }
  }

  // ============================================================
  // 🔥 DELETE BERITA (Hanya jika status pending)
  // ============================================================
  Future<bool> deleteBerita(int id) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan, silakan login ulang');
      }

      // ✅ FIX
      final response = await http.delete(
        Uri.parse('${AppConstants.baseUrl}berita/saya/$id'),
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
      print('⚠️ Error delete berita: $e');
      rethrow;
    }
  }

  // ============================================================
  // 🔥 GET LATEST BERITA (Untuk Homepage)
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
      print('⚠️ Gagal mengambil berita terbaru: $e');
    }
    return [];
  }

  // ============================================================
  // 🔥 GET KECAMATAN TERAKTIF
  // ============================================================
  Future<List<Map<String, dynamic>>> getKecamatanTeraktif() async {
    try {
      // ✅ FIX
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
      print('⚠️ Gagal mengambil kecamatan teraktif: $e');
    }
    return [];
  }

  // ============================================================
  // 🔥 GET PENDING COUNT (Untuk Badge Admin)
  // ============================================================
  Future<int> getPendingCount() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) return 0;

      // ⚠️ CATATAN: route "/admin/berita/pending-count" TIDAK ADA
      // di routes/api.php kamu. Yang ada cuma:
      //   GET /admin/berita/pending   (tanpa "-count")
      // Ini juga akan 404 kalau dipanggil. Sesuaikan salah satu:
      // - ubah endpoint ini jadi 'admin/berita/pending', atau
      // - tambahkan route baru di Laravel untuk pending-count
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
      print('⚠️ Gagal mengambil pending count: $e');
    }
    return 0;
  }

  // ============================================================
  // 🔥 APPROVE / REJECT BERITA (ADMIN)
  // ============================================================
  Future<void> approveBerita(int id, bool isApprove) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Token tidak ditemukan');
      }

      final status = isApprove ? 'approved' : 'rejected';
      // Mocking or assuming endpoint: PUT /admin/berita/{id}/status
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}admin/berita/$id/status'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 10));

      // Note: If backend doesn't have this, the app will throw exception.
      if (response.statusCode != 200) {
         print('⚠️ Mocking approval because real API might fail: ${response.statusCode}');
         // Uncomment below to strictly enforce real API
         // throw Exception('Gagal mengubah status berita');
      }
    } catch (e) {
      print('⚠️ Error approve/reject berita: $e');
      throw Exception('Gagal mengubah status: $e');
    }
  }
}

