// lib/services/bumil_service.dart
// HTTP client ke API Laravel: {baseUrl}dasawisma/bumil (auth sanctum).
// 1 baris = 1 ibu + 1 status per bulan.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';
import '../models/bumil_ibu.dart';
import 'api_exception.dart';

class BumilSummary {
  final int hamil;
  final int melahirkan;
  final int nifas;
  final int meninggal;
  final int bayiLahir;
  final int bayiMeninggal;
  final int balitaMeninggal;

  BumilSummary({
    this.hamil = 0,
    this.melahirkan = 0,
    this.nifas = 0,
    this.meninggal = 0,
    this.bayiLahir = 0,
    this.bayiMeninggal = 0,
    this.balitaMeninggal = 0,
  });
}

class BumilService {
  static final BumilService _instance = BumilService._internal();
  factory BumilService() => _instance;
  BumilService._internal();

  final http.Client _client = http.Client();

  static const Duration _readTimeout = Duration(seconds: 10);
  static const Duration _writeTimeout = Duration(seconds: 15);

  String get _endpoint =>
      '${AppConstants.baseUrl}${AppConstants.dasawismaBumil}';

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
        throw ApiException('Sesi login kedaluwarsa. Silakan login kembali.');
      case 403:
        final msg = serverMessage();
        throw ApiException(msg.isNotEmpty
            ? msg
            : 'Tidak memiliki akses. Data yang sudah disetujui tidak dapat diubah.');
      case 404:
        throw ApiException('Data tidak ditemukan di server.');
      case 409:
        final msg = serverMessage();
        throw ApiException(msg.isNotEmpty
            ? msg
            : 'Data sudah ada (duplikat).');
      case 422:
        throw _validationException(body);
      default:
        if (code >= 500) {
          throw ApiException('Server bermasalah (HTTP $code). Coba lagi nanti.');
        }
        final msg = serverMessage();
        throw ApiException(
            msg.isNotEmpty ? msg : (fallback ?? 'Gagal (HTTP $code).'));
    }
  }

  ApiValidationException _validationException(String body) {
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
        final first =
            errors.values.isNotEmpty ? errors.values.first.first : null;
        final msg = decoded['message'];
        return ApiValidationException(
          first ??
              (msg is String && msg.isNotEmpty
                  ? msg
                  : 'Periksa kembali isian form.'),
          errors,
        );
      }
    } catch (_) {}
    return ApiValidationException('Periksa kembali isian form.');
  }

  Future<http.Response> _get(Uri uri) async {
    try {
      return await _client
          .get(uri, headers: await _headers())
          .timeout(_readTimeout);
    } on SocketException {
      throw ApiException(
          'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.');
    } on TimeoutException {
      throw ApiException('Server tidak merespons (timeout). Coba lagi.');
    } on FormatException {
      throw ApiException('Respons server tidak valid.');
    }
  }

  Future<http.Response> _send(String method, Uri uri,
      {Map<String, dynamic>? body}) async {
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
      throw ApiException(
          'Tidak ada koneksi internet. Periksa jaringan lalu coba lagi.');
    } on TimeoutException {
      throw ApiException('Server tidak merespons (timeout). Coba lagi.');
    } on FormatException {
      throw ApiException('Respons server tidak valid.');
    }
  }

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

  Future<List<BumilIbu>> getAll({
    String query = '',
    int? tahun,
    int? bulan,
    String? statusIbu,
  }) async {
    final items = <BumilIbu>[];
    var page = 1;

    while (page <= 20) {
      final params = <String, String>{
        'per_page': '100',
        'page': '$page',
      };
      if (query.trim().isNotEmpty) params['search'] = query.trim();
      if (tahun != null) params['tahun'] = '$tahun';
      if (bulan != null) params['bulan'] = '$bulan';
      if (statusIbu != null && statusIbu.isNotEmpty) {
        params['status_ibu'] = statusIbu;
      }

      final uri = Uri.parse(_endpoint).replace(queryParameters: params);
      final res = await _get(uri);

      if (res.statusCode != 200) {
        _throwForStatus(res.statusCode, res.body,
            fallback: 'Gagal memuat data bumil.');
      }

      dynamic decoded;
      try {
        decoded = jsonDecode(res.body);
      } catch (_) {
        throw ApiException('Respons server tidak valid.');
      }

      for (final e in _extractList(decoded)) {
        if (e is Map<String, dynamic>) {
          try {
            items.add(BumilIbu.fromJson(e));
          } catch (_) {}
        }
      }

      if (!_hasNextPage(decoded)) break;
      page++;
    }

    return items;
  }

  Future<BumilIbu?> getById(String id) async {
    final res = await _get(Uri.parse('$_endpoint/$id'));
    if (res.statusCode == 200) {
      try {
        final decoded = jsonDecode(res.body);
        final data = decoded is Map<String, dynamic>
            ? (decoded['data'] ?? decoded)
            : decoded;
        if (data is Map<String, dynamic>) {
          return BumilIbu.fromJson(data);
        }
        throw ApiException('Respons server tidak valid.');
      } catch (e) {
        if (e is ApiException) rethrow;
        throw ApiException('Respons server tidak valid.');
      }
    }
    if (res.statusCode == 404) return null;
    _throwForStatus(res.statusCode, res.body,
        fallback: 'Gagal memuat detail ibu.');
  }

  /// Simpan — mengembalikan daftar peringatan non-blokir dari server
  /// (mis. aturan nifas). Kosong bila tidak ada.
  Future<List<String>> save(BumilIbu data) async {
    final isCreate = data.id.isEmpty || data.id == '0';
    final uri =
        isCreate ? Uri.parse(_endpoint) : Uri.parse('$_endpoint/${data.id}');
    final res =
        await _send(isCreate ? 'POST' : 'PUT', uri, body: data.toJson());

    if (res.statusCode == 200 || res.statusCode == 201) {
      return _warningsOf(res.body);
    }
    _throwForStatus(res.statusCode, res.body,
        fallback: isCreate
            ? 'Gagal menyimpan data ibu.'
            : 'Gagal memperbarui data ibu.');
  }

  List<String> _warningsOf(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final w = decoded['warnings'];
        if (w is List) return w.map((e) => e.toString()).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<String>> add(BumilIbu data) => save(data);
  Future<List<String>> update(BumilIbu data) => save(data);

  Future<void> delete(String id) async {
    final res = await _send('DELETE', Uri.parse('$_endpoint/$id'));
    if (res.statusCode == 200 || res.statusCode == 204) return;
    if (res.statusCode == 404) {
      throw ApiException('Data tidak ditemukan di server.');
    }
    _throwForStatus(res.statusCode, res.body,
        fallback: 'Gagal menghapus data ibu.');
  }

  /// 7 penghitung rekap bulan berjalan (client-side, dari data sendiri).
  /// Ibu dihitung unik per status; kematian ibu dari kolom kematian.
  Future<BumilSummary> getSummary({int? tahun, int? bulan}) async {
    final now = DateTime.now();
    final list =
        await getAll(tahun: tahun ?? now.year, bulan: bulan ?? now.month);
    var hamil = 0,
        melahirkan = 0,
        nifas = 0,
        meninggal = 0,
        bayiLahir = 0,
        bayiMeninggal = 0,
        balitaMeninggal = 0;
    for (final b in list) {
      switch (b.statusIbu) {
        case 'hamil':
          hamil++;
          break;
        case 'melahirkan':
          melahirkan++;
          if (b.bayiJenisKelamin == 'L' || b.bayiJenisKelamin == 'P') {
            bayiLahir++;
          }
          break;
        case 'nifas':
          nifas++;
          break;
      }
      if (b.kematianKategori == 'ibu') meninggal++;
      if (b.kematianKategori == 'bayi') bayiMeninggal++;
      if (b.kematianKategori == 'balita') balitaMeninggal++;
    }
    return BumilSummary(
      hamil: hamil,
      melahirkan: melahirkan,
      nifas: nifas,
      meninggal: meninggal,
      bayiLahir: bayiLahir,
      bayiMeninggal: bayiMeninggal,
      balitaMeninggal: balitaMeninggal,
    );
  }
}
