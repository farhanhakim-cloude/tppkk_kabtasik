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
  // âœ… KONVERSI POKJA KE KODE â€” pakai getter dari model
  // ============================================================
  // ignore: unused_element
  String _kodePokja(PokjaKategori kategori) {
    // Pakai getter `kategoriPokja` dari extension â€” otomatis handle 7 value
    return kategori.kategoriPokja;
  }

  // ============================================================
  // ðŸ”¥ PERSISTENCE
  // ============================================================
  static const String _localKey = 'catatan_kegiatan_local';

  Future<void> _saveLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _data.map((e) => e.toJson()).toList();
      await prefs.setString(_localKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<void> _loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_localKey);
      if (raw == null || raw.isEmpty) return;
      final List decoded = jsonDecode(raw);
      if (decoded.isEmpty) return;

      PokjaKategori _parseKategoriDynamic(dynamic v) {
        if (v is int) {
          if (v >= 0 && v < PokjaKategori.values.length)
            return PokjaKategori.values[v];
          return PokjaKategori.pokja1;
        }
        return CatatanKegiatan.parseKategori(v);
      }

      // âœ… Helper: decode dataAngka â€” jangan cast paksa ke int
      Map<String, dynamic> _decodeDataAngka(dynamic raw) {
        if (raw is Map) {
          return Map<String, dynamic>.from(raw);
        }
        if (raw is String) {
          try {
            final decoded = jsonDecode(raw);
            if (decoded is Map) {
              return Map<String, dynamic>.from(decoded);
            }
          } catch (_) {}
        }
        return {};
      }

      for (final item in decoded) {
        Map<String, dynamic>? m;
        if (item is Map<String, dynamic>) {
          m = item;
        } else if (item is Map) {
          m = item.cast<String, dynamic>();
        }
        if (m == null) continue;

        final restored = CatatanKegiatan(
          id: m['id'] ?? 0,
          judul: m['judul']?.toString() ?? '',
          deskripsiSingkat:
              m['cerita_singkat']?.toString() ??
              m['deskripsi']?.toString() ??
              '',
          kategori: _parseKategoriDynamic(m['kategori'] ?? m['kategori_pokja']),
          dataAngka: _decodeDataAngka(m['data_angka']),
          kecamatan: m['kecamatan']?.toString() ?? '',
          desa: m['desa']?.toString() ?? m['desa_kelurahan']?.toString(),
          fotoPath: m['foto_path']?.toString() ?? m['foto']?.toString(),
          tanggal:
              DateTime.tryParse(m['tanggal']?.toString() ?? '') ??
              DateTime.now(),
          status: StatusKegiatan.terkirim,
        );
        final exists = _data.any(
          (d) => d.id == restored.id && d.judul == restored.judul,
        );
        if (!exists) _data.add(restored);
      }
    } catch (_) {}
  }

  // ============================================================
  // HELPER: Extract list dari response (handle pagination)
  // ============================================================
  List<dynamic> _extractList(dynamic rawData) {
    if (rawData == null) return [];
    if (rawData is List) return rawData;
    if (rawData is Map) {
      final nested = rawData['data'];
      if (nested is List) return nested;
      if (nested is Map && nested['data'] is List)
        return nested['data'] as List;
      if (nested is Map &&
          nested['data'] is Map &&
          (nested['data'] as Map)['data'] is List) {
        return (nested['data'] as Map)['data'] as List;
      }
    }
    return [];
  }

  // ============================================================
  // GET ALL LAPORAN
  // ============================================================
  Future<List<CatatanKegiatan>> getAll({
    String? query,
    PokjaKategori? kategori,
  }) async {
    await _loadLocal();

    List<CatatanKegiatan> apiList = [];
    try {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        final response = await http
            .get(
              Uri.parse(
                '${AppConstants.baseUrl}${AppConstants.laporanKegiatan}',
              ),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> raw = _extractList(data['data']);
          apiList = raw.map((item) => CatatanKegiatan.fromJson(item)).toList();
          print('ðŸ“¥ Loaded ${apiList.length} laporan dari API');
        } else {
          print(
            'âš ï¸ API laporan status ${response.statusCode}: ${response.body}',
          );
        }
      }
    } catch (e) {
      print('âš ï¸ Error get laporan API: $e');
    }

    List<CatatanKegiatan> list;
    if (apiList.isEmpty) {
      list = List<CatatanKegiatan>.from(_data);
    } else {
      final apiIds = apiList.map((e) => e.id).toSet();
      final apiJuduls = apiList.map((e) => e.judul).toSet();
      final localOnly = _data
          .where((d) => !apiIds.contains(d.id) && !apiJuduls.contains(d.judul))
          .toList();
      list = [...apiList, ...localOnly];
    }

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
  // ðŸ”¥ KIRIM LAPORAN â€” simpan lokal dulu, API jangan bikin gagal lokal
  // ============================================================
  Future<void> kirim(CatatanKegiatan catatan) async {
    // Simpan ke data lokal agar langsung muncul di list kader
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
    print('ðŸ” TOKEN SAAT SUBMIT: "$token"');

    if (token == null || token.isEmpty) {
      print(
        'âš ï¸ Token kosong â€” disimpan lokal saja, anggap sukses offline',
      );
      return;
    }

    final uri = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.laporanKegiatan}',
    );

    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // FIELD WAJIB
    final String desaFinal = (catatan.desa != null && catatan.desa!.isNotEmpty)
        ? catatan.desa!
        : catatan.kecamatan;

    request.fields['judul'] = catatan.judul;
    request.fields['deskripsi'] = catatan.ceritaSingkat;
    // âœ… FIX: pakai `kategori.kategoriPokja` â€” handle IV-PYD, IV-POSYANDU, IV-REKAP
    request.fields['kategori_pokja'] = catatan.kategori.kategoriPokja;
    request.fields['kecamatan'] = catatan.kecamatan;
    request.fields['desa_kelurahan'] = desaFinal;

    print('ðŸ“¤ SEND DATA:');
    print('  - Judul: ${catatan.judul}');
    print('  - Kategori: ${catatan.kategori.kategoriPokja}');
    print('  - Kecamatan: ${catatan.kecamatan}');
    print('  - Desa: $desaFinal');

    // KONVERSI DATA_ANGKA
    Map<String, dynamic> validDataAngka = {};
    catatan.dataAngka.forEach((key, value) {
      validDataAngka[key] = value;
    });

    if (validDataAngka.isEmpty) {
      validDataAngka['_dummy'] = 0;
    }

    final jsonString = jsonEncode(validDataAngka);
    request.fields['data_angka'] = jsonString;

    // Kirim foto jika ada
    if (catatan.fotoPath != null && catatan.fotoPath!.isNotEmpty) {
      try {
        final file = await http.MultipartFile.fromPath(
          'foto',
          catatan.fotoPath!,
        );
        request.files.add(file);
      } catch (e) {
        print('âš ï¸ Gagal attach foto: $e');
      }
    }

    try {
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 15),
      );
      final response = await http.Response.fromStream(streamedResponse);

      print('ðŸ“¡ Response status: ${response.statusCode}');
      print('ðŸ“¡ Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('âœ… Berhasil mengirim catatan kegiatan ke server!');
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
      print('âš ï¸ $pesan â€” data lokal tetap disimpan, tidak throw');
      return;
    } catch (e) {
      if (e.toString().contains('Exception:') && e.toString().contains('422'))
        rethrow;
      print('âš ï¸ Error kirim catatan kegiatan (diabaikan, lokal tetap): $e');
      return;
    }
  }
}
