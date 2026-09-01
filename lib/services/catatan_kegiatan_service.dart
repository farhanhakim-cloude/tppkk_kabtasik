// lib/services/catatan_kegiatan_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../models/catatan_kegiatan.dart';

class CatatanKegiatanService {
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
  Future<List<CatatanKegiatan>> getAll() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        return [];
      }

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
        final List<dynamic> list = data['data'] ?? [];
        return list.map((item) => CatatanKegiatan.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('⚠️ Error get laporan: $e');
      return [];
    }
  }

  // ============================================================
  // KIRIM LAPORAN
  // ============================================================
  Future<void> kirim(CatatanKegiatan catatan) async {
    final token = await _getToken();
    print('🔍 TOKEN SAAT SUBMIT: "$token"');

    if (token == null || token.isEmpty) {
      throw Exception('Sesi login sudah habis. Silakan login ulang.');
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

    // 🔥🔥🔥 KONVERSI DATA_ANGKA
    Map<String, dynamic> validDataAngka = {};

    catatan.dataAngka.forEach((key, value) {
      int parsedValue = 0;
      
      // 🔥 CEK TIPE DATA
      if (value is int) {
        parsedValue = value;
      } else if (value is String) {
        // 🔥 FIX: value sudah String, aman
        parsedValue = int.tryParse(value.toString()) ?? 0;
      } else {
        parsedValue = 0;
      }
      
      validDataAngka[key] = parsedValue;
    });

    // Pastikan tidak kosong
    if (validDataAngka.isEmpty) {
      if (catatan.dataAngka.isNotEmpty) {
        final firstKey = catatan.dataAngka.keys.first;
        validDataAngka[firstKey] = 0;
      } else {
        validDataAngka['_dummy'] = 0;
      }
    }

    final jsonString = jsonEncode(validDataAngka);
    print('📤 DATA_ANGKA JSON: $jsonString');

    try {
      jsonDecode(jsonString);
    } catch (e) {
      throw Exception('Format JSON tidak valid: $e');
    }

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

    // Eksekusi request
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('📡 Response status: ${response.statusCode}');
    print('📡 Response body: ${response.body}');

    // Handle response
    if (response.statusCode == 201 || response.statusCode == 200) {
      return;
    }

    // Parsing error message
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
    } catch (_) {
      // biarkan pesan default
    }

    throw Exception(pesan);
  }
}