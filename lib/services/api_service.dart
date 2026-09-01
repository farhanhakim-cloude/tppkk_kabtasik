// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import '../models/pokja_1_model.dart';
import '../models/pokja_2_model.dart';
import '../models/pokja_3_model.dart';
import '../models/pokja_4_model.dart';
import '../models/sekretariat_model.dart';
import '../models/berita.dart';
import '../models/user.dart';

class ApiService {
  final http.Client _client = http.Client();

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
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.berita}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['data'] ?? [];
      return list.map((item) => Berita.fromJson(item)).toList();
    } else {
      throw Exception('Gagal load berita: ${response.statusCode}');
    }
  }

  Future<List<Berita>> getBeritaLatest() async {
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.beritaLatest}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> list = data['data'] ?? [];
      return list.map((item) => Berita.fromJson(item)).toList();
    } else {
      throw Exception('Gagal load berita terbaru: ${response.statusCode}');
    }
  }

  Future<Berita> getBeritaDetail(String slug) async {
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.berita}/$slug'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Berita.fromJson(data);
    } else {
      throw Exception('Gagal load detail berita: ${response.statusCode}');
    }
  }

  // ============================================================
  // GALERI
  // ============================================================
  Future<List<dynamic>> getGaleri() async {
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.galeri}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Gagal load galeri: ${response.statusCode}');
    }
  }

  // ============================================================
  // AGENDA
  // ============================================================
  Future<List<dynamic>> getAgenda() async {
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.agenda}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Gagal load agenda: ${response.statusCode}');
    }
  }

  // ============================================================
  // LAPORAN KEGIATAN
  // ============================================================
  Future<List<dynamic>> getLaporanKegiatan() async {
    final response = await _client.get(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.laporanKegiatan}'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'] ?? [];
    } else {
      throw Exception('Gagal load laporan kegiatan: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createLaporanKegiatan(Map<String, dynamic> data, String token) async {
    final response = await _client.post(
      Uri.parse('${AppConstants.baseUrl}${AppConstants.laporanKegiatan}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal buat laporan: ${response.statusCode}');
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