// lib/services/kegiatan_warga_service.dart
// HTTP client ke API Laravel: {baseUrl}dasawisma/kegiatan-warga (auth sanctum).
// Pola ditiru dari DaftarWargaService + timeout/header ala ApiService.
// Endpoint backend mengikuti DasawismaDaftarWargaController.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/kegiatan_warga.dart';

/// Error validasi 422 — membawa pesan per field agar form bisa menampilkannya.
class KegiatanWargaValidationException implements Exception {
  final String message;
  final Map<String, List<String>> errors;

  KegiatanWargaValidationException(this.message, [Map<String, List<String>>? errors])
      : errors = errors ?? {};

  /// Pesan pertama untuk satu field server (mis. 'jumlah_peserta').
  String? firstErrorFor(String field) {
    final list = errors[field];
    if (list == null || list.isEmpty) return null;
    return list.first;
  }

  @override
  String toString() => message;
}

class KegiatanWargaService {
  static final KegiatanWargaService _instance =
      KegiatanWargaService._internal();
  factory KegiatanWargaService() => _instance;
  KegiatanWargaService._internal();

  final http.Client _client = http.Client();

  static const Duration _readTimeout = Duration(seconds: 10);
  static const Duration _writeTimeout = Duration(seconds: 15);

  String get _endpoint =>
      '${AppConstants.baseUrl}${AppConstants.dasawismaKegiatanWarga}';

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

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  Never _throwForStatus(int code, String body, {String? fallback}) {
    String serverMessage() {
      try {
        final decoded = jsonDecode(body);
        if (decoded is Map<String, dynamic>) {
          final m = decoded['message'];
          if (m is String && m.isNotEmpty) return m;
        }
      } catch (_) {}
      return '';
    }

    switch (code) {
      case 401:
        throw Exception('Sesi login kedaluwarsa. Silakan login kembali.');
      case 403:
        final msg = serverMessage();
        throw Exception(msg.isNotEmpty
            ? msg
            : 'Tidak memiliki akses. Data yang sudah disetujui tidak dapat diubah.');
      case 404:
        throw Exception('Data tidak ditemukan di server.');
      case 422:
        throw _validationException(body);
      default:
        if (code >= 500) {
          throw Exception('Server bermasalah (HTTP $code). Coba lagi nanti.');
        }
        final msg = serverMessage();
        throw Exception(
            msg.isNotEmpty ? msg : (fallback ?? 'Gagal (HTTP $code).'));
    }
  }

  KegiatanWargaValidationException _validationException(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final rawErrors = decoded['errors'];
        final errors = <String, List<String>>{};
        if (rawErrors is Map) {
          rawErrors.forEach((key, value) {
            if (value is List) {
              errors[key.toString()] =
                  value.map((e) => e.toString()).toList();
            } else if (value != null) {
              errors[key.toString()] = [value.toString()];
            }
          });
        }
        final first = errors.values.isNotEmpty ? errors.values.first.first : null;
        final msg = decoded['message'];
        return KegiatanWargaValidationException(
          first ??
              (msg is String && msg.isNotEmpty
                  ? msg
                  : 'Periksa kembali isian form.'),
          errors,
        );
      }
    } catch (_) {}
    return KegiatanWargaValidationException('Periksa kembali isian form.');
  }

  /// GET dengan penanganan: tidak ada koneksi, timeout, JSON rusak.
  Future<http.Response> _get(Uri uri) async {
    try {
      return await _client
          .get(uri, headers: await _headers())
          .timeout(_readTimeout);
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.');
    } on TimeoutException {
      throw Exception('Server tidak merespons (timeout). Coba lagi.');
    } on FormatException {
      throw Exception('Respons server tidak valid.');
    }
  }

  Future<http.Response> _send(
    String method,
    Uri uri, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final headers = await _headers();
      final payload = body == null ? null : jsonEncode(body);
      late http.Response res;
      if (method == 'POST') {
        res = await _client
            .post(uri, headers: headers, body: payload)
            .timeout(_writeTimeout);
      } else if (method == 'PUT') {
        res = await _client
            .put(uri, headers: headers, body: payload)
            .timeout(_writeTimeout);
      } else {
        res = await _client
            .delete(uri, headers: headers)
            .timeout(_writeTimeout);
      }
      return res;
    } on SocketException {
      throw Exception('Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.');
    } on TimeoutException {
      throw Exception('Server tidak merespons (timeout). Coba lagi.');
    } on FormatException {
      throw Exception('Respons server tidak valid.');
    }
  }

  /// Mendukung 3 format: List langsung, {data: [...]}, {data: {data: [...]} paginate}.
  List _extractList(dynamic decoded) {
    if (decoded is List) return decoded;
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is List) return data;
      if (data is Map<String, dynamic> && data['data'] is List) {
        return data['data'] as List;
      }
    }
    return [];
  }

  bool _hasNextPage(dynamic decoded) {
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        final current = data['current_page'];
        final last = data['last_page'];
        final nextUrl = data['next_page_url'];
        if (current is int && last is int) return current < last;
        return nextUrl != null;
      }
    }
    return false;
  }

  // ============================================================
  // GET ALL — ikut pagination server (per_page 100, maks 20 halaman)
  // ============================================================
  Future<List<KegiatanWarga>> getAll({
    String query = '',
    String? tahun,
    String? desa,
  }) async {
    final items = <KegiatanWarga>[];
    var page = 1;

    while (page <= 20) {
      final params = <String, String>{
        'per_page': '100',
        'page': '$page',
      };
      if (query.trim().isNotEmpty) params['search'] = query.trim();
      if (desa != null && desa.isNotEmpty) params['desa'] = desa;

      final uri = Uri.parse(_endpoint).replace(queryParameters: params);
      final res = await _get(uri);

      if (res.statusCode != 200) {
        _throwForStatus(res.statusCode, res.body,
            fallback: 'Gagal memuat data kegiatan warga.');
      }

      dynamic decoded;
      try {
        decoded = jsonDecode(res.body);
      } catch (_) {
        throw Exception('Respons server tidak valid.');
      }

      for (final e in _extractList(decoded)) {
        if (e is Map<String, dynamic>) {
          try {
            items.add(KegiatanWarga.fromJson(e));
          } catch (_) {
            // Lewati 1 baris rusak tanpa menggagalkan seluruh list.
          }
        }
      }

      if (!_hasNextPage(decoded)) break;
      page++;
    }

    if (tahun != null && tahun.isNotEmpty) {
      return items.where((e) => e.tahun == tahun).toList();
    }
    return items;
  }

  Future<KegiatanWarga?> getById(String id) async {
    final res = await _get(Uri.parse('$_endpoint/$id'));
    if (res.statusCode == 200) {
      try {
        final decoded = jsonDecode(res.body);
        final data = decoded is Map<String, dynamic>
            ? (decoded['data'] ?? decoded)
            : decoded;
        if (data is Map<String, dynamic>) {
          return KegiatanWarga.fromJson(data);
        }
        throw Exception('Respons server tidak valid.');
      } catch (e) {
        if (e is Exception && e.toString().contains('Respons server')) rethrow;
        throw Exception('Respons server tidak valid.');
      }
    }
    if (res.statusCode == 404) return null;
    _throwForStatus(res.statusCode, res.body,
        fallback: 'Gagal memuat detail kegiatan warga.');
  }

  // ============================================================
  // SAVE / ADD / UPDATE — id kosong/'0' -> POST, selain itu PUT.
  // Tidak pernah mengirim status/approval (server yang menentukan).
  // ============================================================
  Future<void> save(KegiatanWarga data) async {
    final isCreate = data.id.isEmpty || data.id == '0';
    final uri = isCreate
        ? Uri.parse(_endpoint)
        : Uri.parse('$_endpoint/${data.id}');
    final res = await _send(isCreate ? 'POST' : 'PUT', uri,
        body: data.toJson());

    if (res.statusCode == 200 || res.statusCode == 201) return;
    _throwForStatus(res.statusCode, res.body,
        fallback: isCreate
            ? 'Gagal menyimpan kegiatan warga.'
            : 'Gagal memperbarui kegiatan warga.');
  }

  Future<void> add(KegiatanWarga data) => save(data);
  Future<void> update(KegiatanWarga data) => save(data);

  Future<void> delete(String id) async {
    final res = await _send('DELETE', Uri.parse('$_endpoint/$id'));
    if (res.statusCode == 200 ||
        res.statusCode == 204 ||
        res.statusCode == 404) {
      if (res.statusCode == 404) {
        throw Exception('Data tidak ditemukan di server.');
      }
      return;
    }
    _throwForStatus(res.statusCode, res.body,
        fallback: 'Gagal menghapus kegiatan warga.');
  }

  Future<List<KegiatanWarga>> getByWilayah({
    String? rt,
    String? rw,
    String? dusun,
    String? desa,
    String? kecamatan,
    String? tahun,
  }) async {
    final all = await getAll();
    return all.where((e) {
      if (rt != null && rt.isNotEmpty && e.rt != rt) return false;
      if (rw != null && rw.isNotEmpty && e.rw != rw) return false;
      if (dusun != null &&
          dusun.isNotEmpty &&
          e.dusun.toLowerCase() != dusun.toLowerCase()) {
        return false;
      }
      if (desa != null &&
          desa.isNotEmpty &&
          e.desa.toLowerCase() != desa.toLowerCase()) {
        return false;
      }
      if (kecamatan != null &&
          kecamatan.isNotEmpty &&
          e.kecamatan.toLowerCase() != kecamatan.toLowerCase()) {
        return false;
      }
      if (tahun != null && tahun.isNotEmpty && e.tahun != tahun) return false;
      return true;
    }).toList();
  }

  Future<Map<String, int>> getStatistik() async {
    final all = await getAll();
    final map = <String, int>{
      'total': all.length,
      'pending': 0,
      'approved': 0,
      'rejected': 0,
      'totalPeserta': 0,
      'totalAktif': 0,
    };
    for (final d in all) {
      map[d.status] = (map[d.status] ?? 0) + 1;
      map['totalPeserta'] = (map['totalPeserta'] ?? 0) + d.jumlahPeserta;
      map['totalAktif'] = (map['totalAktif'] ?? 0) + d.jumlahPeserta;
      map['kegiatan:${d.kegiatan}'] = (map['kegiatan:${d.kegiatan}'] ?? 0) + 1;
    }
    return map;
  }
}
