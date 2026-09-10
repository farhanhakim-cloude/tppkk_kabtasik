// lib/services/pokja2_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class Pokja2Service {
  static final Pokja2Service _instance = Pokja2Service._internal();
  factory Pokja2Service() => _instance;
  Pokja2Service._internal();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  // ============================================================
  // SUBMIT DATA POKJA 2
  // ============================================================
  Future<void> submit({
    required String kecamatan,
    required String judulKegiatan,
    required String deskripsi,
    required int wargaButaL,
    required int wargaButaP,
    required int kelompokBelajarPaketA,
    required int kelompokBelajarPaketB,
    required int kelompokBelajarPaketC,
    required int kf,
    required int paud,
    required int koperasiBerbadanHukum,
    File? foto,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.pokja2}');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Accept'] = 'application/json';
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['kecamatan'] = kecamatan;
    request.fields['judul_kegiatan'] = judulKegiatan;
    request.fields['deskripsi'] = deskripsi;
    request.fields['warga_buta_l'] = wargaButaL.toString();
    request.fields['warga_buta_p'] = wargaButaP.toString();
    request.fields['kelompok_belajar_paket_a'] = kelompokBelajarPaketA.toString();
    request.fields['kelompok_belajar_paket_b'] = kelompokBelajarPaketB.toString();
    request.fields['kelompok_belajar_paket_c'] = kelompokBelajarPaketC.toString();
    request.fields['kf'] = kf.toString();
    request.fields['paud'] = paud.toString();
    request.fields['koperasi_berbadan_hukum'] = koperasiBerbadanHukum.toString();
    request.fields['kategori'] = 'II';

    if (foto != null) {
      try {
        final file = await http.MultipartFile.fromPath('foto', foto.path);
        request.files.add(file);
      } catch (e) {
        print('⚠️ Gagal attach foto: $e');
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 Pokja2 response: ${response.statusCode}');
      print('📡 Pokja2 body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      String pesan = 'Gagal menyimpan data Pokja II (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) pesan = body['message'];
        if (body['errors'] != null) {
          final errors = body['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            pesan = firstError.first;
          }
        }
      } catch (_) {}

      throw Exception(pesan);
    } catch (e) {
      print('⚠️ Error submit pokja2: $e');
      rethrow;
    }
  }

  // ============================================================
  // UPDATE DATA POKJA 2
  // ============================================================
  Future<void> update({
    required int id,
    required String kecamatan,
    required String judulKegiatan,
    required String deskripsi,
    required int wargaButaL,
    required int wargaButaP,
    required int kelompokBelajarPaketA,
    required int kelompokBelajarPaketB,
    required int kelompokBelajarPaketC,
    required int kf,
    required int paud,
    required int koperasiBerbadanHukum,
    File? foto,
  }) async {
    final token = await _getToken();

    final uri = Uri.parse('${AppConstants.baseUrl}${AppConstants.pokja2}/$id');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Accept'] = 'application/json';
    request.headers['X-HTTP-Method-Override'] = 'PUT';
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields['_method'] = 'PUT';
    request.fields['kecamatan'] = kecamatan;
    request.fields['judul_kegiatan'] = judulKegiatan;
    request.fields['deskripsi'] = deskripsi;
    request.fields['warga_buta_l'] = wargaButaL.toString();
    request.fields['warga_buta_p'] = wargaButaP.toString();
    request.fields['kelompok_belajar_paket_a'] = kelompokBelajarPaketA.toString();
    request.fields['kelompok_belajar_paket_b'] = kelompokBelajarPaketB.toString();
    request.fields['kelompok_belajar_paket_c'] = kelompokBelajarPaketC.toString();
    request.fields['kf'] = kf.toString();
    request.fields['paud'] = paud.toString();
    request.fields['koperasi_berbadan_hukum'] = koperasiBerbadanHukum.toString();
    request.fields['kategori'] = 'II';

    if (foto != null) {
      try {
        final file = await http.MultipartFile.fromPath('foto', foto.path);
        request.files.add(file);
      } catch (e) {
        print('⚠️ Gagal attach foto: $e');
      }
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) return;

      String pesan = 'Gagal update data Pokja II (${response.statusCode})';
      try {
        final body = jsonDecode(response.body);
        if (body['message'] != null) pesan = body['message'];
      } catch (_) {}

      throw Exception(pesan);
    } catch (e) {
      rethrow;
    }
  }
}
