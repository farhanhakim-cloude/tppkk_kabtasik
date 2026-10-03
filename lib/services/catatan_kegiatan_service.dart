// ignore_for_file: avoid_print, no_leading_underscores_for_local_identifiers
// lib/services/catatan_kegiatan_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/catatan_kegiatan.dart';

class CatatanKegiatanService {
  static final CatatanKegiatanService _instance =
      CatatanKegiatanService._internal();
  factory CatatanKegiatanService() => _instance;
  CatatanKegiatanService._internal();

  final List<CatatanKegiatan> _data = [
    CatatanKegiatan(
      id: 1,
      judul: 'Penyuluhan Pola Asuh Anak & Remaja (PAAR)',
      deskripsiSingkat:
          'Sosialisasi pembinaan pola asuh anak dengan cinta kasih dan pencegahan kekerasan dalam rumah tangga bagi warga Singaparna.',
      kategori: PokjaKategori.pokja1,
      kecamatan: 'Singaparna',
      desa: 'Cikunten',
      tanggal: DateTime.now().subtract(const Duration(days: 1)),
      status: StatusKegiatan.dibaca,
    ),
    CatatanKegiatan(
      id: 2,
      judul: 'Pelatihan Olahan Pangan Lokal UP2K PKK',
      deskripsiSingkat:
          'Pelatihan pembuatan keripik pisang aneka rasa dan kemasan higienis untuk peningkatan ekonomi kelompok UP2K.',
      kategori: PokjaKategori.pokja2,
      kecamatan: 'Rajapolah',
      desa: 'Manggungjaya',
      tanggal: DateTime.now().subtract(const Duration(days: 3)),
      status: StatusKegiatan.terkirim,
    ),
    CatatanKegiatan(
      id: 3,
      judul:
          'Gerakan Menanam Halaman Asri Teratur Indah dan Nyaman (HATINYA PKK)',
      deskripsiSingkat:
          'Penanaman bibit cabai, sayuran hidroponik, dan tanaman obat keluarga (TOGA) di pekarangan warga.',
      kategori: PokjaKategori.pokja3,
      kecamatan: 'Cisayong',
      desa: 'Nusawangi',
      tanggal: DateTime.now().subtract(const Duration(days: 5)),
      status: StatusKegiatan.terkirim,
    ),
    CatatanKegiatan(
      id: 4,
      judul: 'Penimbangan Balita & Pemeriksaan Ibu Hamil di Posyandu Melati',
      deskripsiSingkat:
          'Pelaksanaan posyandu rutin balita gizi terpantau, pemberian vitamin A, dan penyuluhan sanitasi jamban sehat.',
      kategori: PokjaKategori.pokja4,
      kecamatan: 'Manonjaya',
      desa: 'Pasirbatang',
      tanggal: DateTime.now().subtract(const Duration(days: 7)),
      status: StatusKegiatan.dibaca,
    ),
  ];

  // ============================================================
  // AMBIL TOKEN
  // ============================================================
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  // ============================================================
  // ✅ FIX — _apiUri() — gabung baseUrl + endpoint
  // ============================================================
  Uri _apiUri(String endpoint) {
    return Uri.parse('${AppConstants.baseUrl}$endpoint');
  }

  Map<String, String> _authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };

  // ============================================================
  // ✅ KONVERSI POKJA KE KODE — pakai getter dari model
  // ============================================================
  // ignore: unused_element
  String _kodePokja(PokjaKategori kategori) {
    return kategori.kategoriPokja;
  }

  // ============================================================
  // 🔥 PERSISTENCE
  // ============================================================
  static const String _localKey = 'catatan_kegiatan_local';

  Future<void> _saveLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _data.map((e) => e.toJson()).toList();
      await prefs.setString(_localKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  List<dynamic> _parseMyLaporanResponse(String responseBody) {
    final decoded = jsonDecode(responseBody);
    if (decoded is! Map || decoded['success'] != true) {
      throw const FormatException('Format respons laporan saya tidak valid.');
    }

    final page = decoded['data'];
    if (page is! Map || page['data'] is! List) {
      throw const FormatException('Data paginasi laporan saya tidak valid.');
    }

    for (final key in ['current_page', 'last_page', 'per_page', 'total']) {
      if (int.tryParse(page[key]?.toString() ?? '') == null) {
        throw FormatException('Metadata paginasi "$key" tidak valid.');
      }
    }

    return page['data'] as List<dynamic>;
  }

  // ============================================================
  // GET ALL LAPORAN
  // ============================================================
  Future<List<CatatanKegiatan>> getAll({
    String? query,
    PokjaKategori? kategori,
  }) async {
    List<CatatanKegiatan> apiList = [];
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw StateError('Token tidak ditemukan. Silakan login ulang.');
      }

      final uri = _apiUri(AppConstants.myLaporan);
      print('🔍 GET LAPORAN SAYA: $uri');

      final response = await http
          .get(uri, headers: _authHeaders(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal memuat laporan saya (${response.statusCode}): ${response.body}',
        );
      }
      final raw = _parseMyLaporanResponse(response.body);
      apiList = raw
          .map(
            (item) => CatatanKegiatan.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
      print('📥 Loaded ${apiList.length} laporan dari API');
    } catch (e) {
      print('Error get laporan saya: $e');
      rethrow;
    }

    List<CatatanKegiatan> list = apiList;

    if (kategori != null) {
      list = list.where((c) => c.kategori == kategori).toList();
    }
    if (query != null && query.isNotEmpty) {
      list = list
          .where(
            (c) =>
                c.judul.toLowerCase().contains(query.toLowerCase()) ||
                c.kecamatan.toLowerCase().contains(query.toLowerCase()) ||
                c.deskripsiSingkat.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return list;
  }

  Future<CatatanKegiatan?> getById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _data.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(CatatanKegiatan catatan) async {
    await kirim(catatan);
  }

  Future<void> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _data.removeWhere((c) => c.id == id);
    await _saveLocal();
  }

  Future<void> updateStatus(int id, StatusKegiatan status) async {
    final idx = _data.indexWhere((c) => c.id == id);
    if (idx >= 0) {
      _data[idx] = _data[idx].copyWith(status: status);
      await _saveLocal();
    }
  }

  // ============================================================
  // 🔥 KIRIM LAPORAN
  // ============================================================
  Future<void> kirim(CatatanKegiatan catatan) async {
    final index = _data.indexWhere((c) => c.id == catatan.id && c.id != 0);
    if (index >= 0) {
      _data[index] = catatan;
    } else {
      final newId = _data.isEmpty
          ? 1
          : _data.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
      _data.insert(
        0,
        catatan.copyWith(id: catatan.id == 0 ? newId : catatan.id),
      );
    }
    await _saveLocal();

    final token = await _getToken();
    print('🔍 TOKEN SAAT SUBMIT: "$token"');

    if (token == null || token.isEmpty) {
      print('⚠️ Token kosong — disimpan lokal saja, anggap sukses offline');
      return;
    }

    final uri = _apiUri(AppConstants.laporanKegiatan);
    print('📤 POST KE: $uri');

    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    final String desaFinal = (catatan.desa != null && catatan.desa!.isNotEmpty)
        ? catatan.desa!
        : catatan.kecamatan;

    request.fields['judul'] = catatan.judul;
    request.fields['deskripsi'] = catatan.ceritaSingkat;
    request.fields['kategori_pokja'] = catatan.kategori.kategoriPokja;
    request.fields['kecamatan'] = catatan.kecamatan;
    request.fields['desa_kelurahan'] = desaFinal;

    print('📤 SEND DATA:');
    print('  - Judul: ${catatan.judul}');
    print('  - Kategori: ${catatan.kategori.kategoriPokja}');
    print('  - Kecamatan: ${catatan.kecamatan}');
    print('  - Desa: $desaFinal');

    Map<String, dynamic> validDataAngka = {};
    catatan.dataAngka.forEach((key, value) {
      validDataAngka[key] = value;
    });

    if (validDataAngka.isEmpty) {
      validDataAngka['_dummy'] = 0;
    }

    final jsonString = jsonEncode(validDataAngka);
    request.fields['data_angka'] = jsonString;

    if (catatan.fotoPath != null && catatan.fotoPath!.isNotEmpty) {
      try {
        final file = await http.MultipartFile.fromPath(
          'foto',
          catatan.fotoPath!,
        );
        request.files.add(file);
      } catch (e) {
        print('⚠️ Gagal attach foto: $e');
      }
    }

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('✅ Berhasil mengirim catatan kegiatan ke server!');
        return;
      }

      String pesan =
          'Gagal mengirim ke server (${response.statusCode}), tapi data tetap tersimpan lokal';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) {
          pesan = body['message'];
        }
        if (body['errors'] != null) {
          final errors = body['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            pesan = firstError.first;
          }
        }
        if (body['error'] != null && body['error'] is String) {
          pesan = body['error'];
        }
      } catch (_) {}

      if (response.statusCode == 422) {
        throw Exception(pesan);
      }
      print('⚠️ $pesan — data lokal tetap disimpan, tidak throw');
      return;
    } catch (e) {
      if (e.toString().contains('Exception:') && e.toString().contains('422'))
        rethrow;
      print('⚠️ Error kirim catatan kegiatan (diabaikan, lokal tetap): $e');
      return;
    }
  }
}