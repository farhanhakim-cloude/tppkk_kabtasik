// lib/services/catatan_kegiatan_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/catatan_kegiatan.dart';

class CatatanKegiatanService {
  static final CatatanKegiatanService _instance = CatatanKegiatanService._internal();
  factory CatatanKegiatanService() => _instance;
  CatatanKegiatanService._internal();

  final List<CatatanKegiatan> _data = [
    CatatanKegiatan(
      id: 1,
      judul: 'Penyuluhan Pola Asuh Anak & Remaja (PAAR)',
      deskripsiSingkat: 'Sosialisasi pembinaan pola asuh anak dengan cinta kasih dan pencegahan kekerasan dalam rumah tangga bagi warga Singaparna.',
      kategori: PokjaKategori.pokja1,
      kecamatan: 'Singaparna',
      desa: 'Cikunten',
      tanggal: DateTime.now().subtract(const Duration(days: 1)),
      status: StatusKegiatan.dibaca,
    ),
    CatatanKegiatan(
      id: 2,
      judul: 'Pelatihan Olahan Pangan Lokal UP2K PKK',
      deskripsiSingkat: 'Pelatihan pembuatan keripik pisang aneka rasa dan kemasan higienis untuk peningkatan ekonomi kelompok UP2K.',
      kategori: PokjaKategori.pokja2,
      kecamatan: 'Rajapolah',
      desa: 'Manggungjaya',
      tanggal: DateTime.now().subtract(const Duration(days: 3)),
      status: StatusKegiatan.terkirim,
    ),
    CatatanKegiatan(
      id: 3,
      judul: 'Gerakan Menanam Halaman Asri Teratur Indah dan Nyaman (HATINYA PKK)',
      deskripsiSingkat: 'Penanaman bibit cabai, sayuran hidroponik, dan tanaman obat keluarga (TOGA) di pekarangan warga.',
      kategori: PokjaKategori.pokja3,
      kecamatan: 'Cisayong',
      desa: 'Nusawangi',
      tanggal: DateTime.now().subtract(const Duration(days: 5)),
      status: StatusKegiatan.terkirim,
    ),
    CatatanKegiatan(
      id: 4,
      judul: 'Penimbangan Balita & Pemeriksaan Ibu Hamil di Posyandu Melati',
      deskripsiSingkat: 'Pelaksanaan posyandu rutin balita gizi terpantau, pemberian vitamin A, dan penyuluhan sanitasi jamban sehat.',
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
  // KONVERSI POKJA KE ROMAWI
  // ============================================================
  String _kodePokja(PokjaKategori kategori) {
    switch (kategori) {
      case PokjaKategori.pokja1:
        return 'I';
      case PokjaKategori.pokja2:
        return 'II';
      case PokjaKategori.pokja3:
        return 'III';
      case PokjaKategori.pokja4:
        return 'IV';
    }
  }

  // ============================================================
  // GET ALL LAPORAN
  // ============================================================
  Future<List<CatatanKegiatan>> getAll({String? query, PokjaKategori? kategori}) async {
    List<CatatanKegiatan> list = [];
    try {
      final token = await _getToken();
      if (token != null && token.isNotEmpty) {
        final response = await http.get(
          Uri.parse('${AppConstants.baseUrl}${AppConstants.laporanKegiatan}'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final List<dynamic> apiList = data['data'] ?? [];
          list = apiList.map((item) => CatatanKegiatan.fromJson(item)).toList();
        }
      }
    } catch (e) {
      print('⚠️ Error get laporan API: $e');
    }

    // Jika API kosong atau gagal, gunakan data lokal
    if (list.isEmpty) {
      list = List<CatatanKegiatan>.from(_data);
    }

    if (kategori != null) {
      list = list.where((c) => c.kategori == kategori).toList();
    }
    if (query != null && query.isNotEmpty) {
      list = list
          .where((c) =>
              c.judul.toLowerCase().contains(query.toLowerCase()) ||
              c.kecamatan.toLowerCase().contains(query.toLowerCase()) ||
              c.deskripsiSingkat.toLowerCase().contains(query.toLowerCase()))
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
  }

  // ============================================================
  // KIRIM LAPORAN
  // ============================================================
  Future<void> kirim(CatatanKegiatan catatan) async {
    // Simpan ke data lokal agar langsung muncul
    final index = _data.indexWhere((c) => c.id == catatan.id && c.id != 0);
    if (index >= 0) {
      _data[index] = catatan;
    } else {
      final newId = _data.isEmpty ? 1 : _data.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
      _data.insert(0, catatan.copyWith(id: catatan.id == 0 ? newId : catatan.id));
    }

    final token = await _getToken();
    print('🔍 TOKEN SAAT SUBMIT: "$token"');

    if (token == null || token.isEmpty) {
      // Jika belum ada token, simpan di data lokal saja
      return;
    }

    final uri = Uri.parse(
      '${AppConstants.baseUrl}${AppConstants.laporanKegiatan}',
    );

    final request = http.MultipartRequest('POST', uri);

    // Headers
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // FIELD WAJIB
    request.fields['judul'] = catatan.judul;
    request.fields['deskripsi'] = catatan.ceritaSingkat;
    request.fields['kategori_pokja'] = _kodePokja(catatan.kategori);
    request.fields['kecamatan'] = catatan.kecamatan;
    if (catatan.desa != null && catatan.desa!.isNotEmpty) {
      request.fields['desa'] = catatan.desa!;
    }

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
        print('⚠️ Gagal attach foto: $e');
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return;
      }

      String pesan = 'Gagal mengirim catatan kegiatan (${response.statusCode})';
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

      throw Exception(pesan);
    } catch (e) {
      // Jika request offline, data lokal sudah tersimpan
      if (e is Exception && e.toString().contains('Gagal mengirim catatan')) {
        rethrow;
      }
    }
  }
}