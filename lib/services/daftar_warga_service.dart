// lib/services/daftar_warga_service.dart
// ✅ FINAL — pakai AppConstants, konsisten dengan auth_service

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_keluarga_dasawisma.dart';
import '../constants/app_constants.dart';

class DaftarWargaService {
  static final DaftarWargaService _instance = DaftarWargaService._internal();
  factory DaftarWargaService() => _instance;
  DaftarWargaService._internal();

  // ✅ Pakai AppConstants.baseUrl + endpoint baru
  String get _endpoint => '${AppConstants.baseUrl}dasawisma/daftar-warga';

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// GET semua daftar warga
  Future<List<DataKeluargaDasawisma>> getAll({String query = ''}) async {
    try {
      final url = query.isNotEmpty ? '$_endpoint?search=$query' : _endpoint;
      final response = await http.get(Uri.parse(url), headers: await _headers());

      print('🔍 GET $url → ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Handle 3 format response
        List list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map) {
          final data = decoded['data'];
          if (data is List) {
            list = data;
          } else if (data is Map && data['data'] is List) {
            list = data['data'] as List; // paginate
          }
        }

        print('🔍 Parsed ${list.length} items');

        return list
            .map((e) => DataKeluargaDasawisma.fromDaftarWargaJson(e as Map<String, dynamic>))
            .toList();
      } else {
        print('❌ GET daftar-warga failed: ${response.statusCode}');
        print('❌ Body: ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ GET daftar-warga error: $e');
      return [];
    }
  }

  /// GET by ID
  Future<DataKeluargaDasawisma?> getById(int id) async {
    try {
      final response = await http.get(Uri.parse('$_endpoint/$id'), headers: await _headers());
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = decoded is Map ? (decoded['data'] ?? decoded) : decoded;
        return DataKeluargaDasawisma.fromDaftarWargaJson(data as Map<String, dynamic>);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// POST — kirim data KK baru
  Future<bool> save(DataKeluargaDasawisma item) async {
    try {
      final body = item.toDaftarWargaJson();
      // Pastikan kategori wajib ada (sesuai validasi backend)
      body['kategori'] = body['kategori'] ?? 'warga';

      print('📤 POST $_endpoint');
      print('📤 Body: $body');

      final response = await http.post(
        Uri.parse(_endpoint),
        headers: await _headers(),
        body: jsonEncode(body),
      );

      print('📤 Response: ${response.statusCode}');
      print('📤 Body: ${response.body}');

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('❌ POST error: $e');
      return false;
    }
  }

  /// DELETE
  Future<bool> delete(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_endpoint/$id'), headers: await _headers());
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}