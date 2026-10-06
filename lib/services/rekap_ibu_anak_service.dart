// lib/services/rekap_ibu_anak_service.dart
// ✅ FIXED: parsing manual — tidak butuh fromJson/toJson dari model

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rekap_ibu_anak.dart';
import '../constants/app_constants.dart';

class RekapIbuAnakSummary {
  final int jumlahHamil;
  final int jumlahMelahirkan;
  final int jumlahNifas;
  final int jumlahIbuMeninggal;
  final int jumlahBayiLahir;
  final int jumlahBayiMeninggal;
  final int jumlahBalitaMeninggal;

  RekapIbuAnakSummary({
    required this.jumlahHamil,
    required this.jumlahMelahirkan,
    required this.jumlahNifas,
    required this.jumlahIbuMeninggal,
    required this.jumlahBayiLahir,
    required this.jumlahBayiMeninggal,
    required this.jumlahBalitaMeninggal,
  });
}

class RekapIbuAnakService {
  static final RekapIbuAnakService _instance = RekapIbuAnakService._internal();
  factory RekapIbuAnakService() => _instance;
  RekapIbuAnakService._internal();

  String get _endpoint => '${AppConstants.baseUrl}rekap-bumil';

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

  Future<List<RekapIbuAnak>> getAll({String? query}) async {
    try {
      final url = (query != null && query.isNotEmpty) ? '$_endpoint?search=$query' : _endpoint;
      final response = await http.get(Uri.parse(url), headers: await _headers());

      print('🔍 GET rekap-bumil → ${response.statusCode}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        List list = [];
        if (decoded is List) {
          list = decoded;
        } else if (decoded is Map) {
          final data = decoded['data'];
          if (data is List) {
            list = data;
          } else if (data is Map && data['data'] is List) {
            list = data['data'] as List;
          }
        }

        print('🔍 Parsed ${list.length} bumil');

        // ✅ Parsing manual — tanpa fromJson
        return list.map((e) {
          final m = e as Map<String, dynamic>;
          return RekapIbuAnak(
            id: _toInt(m['id']),
            kelompokDasaWisma: _toStr(m['kelompok_dasa_wisma'] ?? m['kelompokDasaWisma']),
            rt: _toStr(m['rt']),
            rw: _toStr(m['rw']),
            dusun: _toStr(m['dusun']),
            desa: _toStr(m['desa']),
            bulan: _toStr(m['bulan']),
            tahun: _toStr(m['tahun']),
            namaIbu: _toStr(m['nama_ibu'] ?? m['namaIbu']),
            namaSuami: _toStr(m['nama_suami'] ?? m['namaSuami']),
            statusIbu: _toStr(m['status_ibu'] ?? m['statusIbu']),
            adaKelahiran: _toBool(m['ada_kelahiran'] ?? m['adaKelahiran']),
            namaBayi: _toStr(m['nama_bayi'] ?? m['namaBayi']),
            jenisKelaminBayi: _toStr(m['jenis_kelamin_bayi'] ?? m['jenisKelaminBayi']),
            tanggalLahir: _toStr(m['tanggal_lahir'] ?? m['tanggalLahir']),
            hasAktaKelahiran: _toBool(m['has_akta_kelahiran'] ?? m['hasAktaKelahiran']),
            adaKematian: _toBool(m['ada_kematian'] ?? m['adaKematian']),
            statusMeninggal: _toStr(m['status_meninggal'] ?? m['statusMeninggal']),
            keterangan: _toStr(m['keterangan']),
          );
        }).toList();
      }
      return [];
    } catch (e, st) {
      print('❌ rekap-bumil error: $e');
      print('❌ Stack: $st');
      return [];
    }
  }

  /// POST — kirim data rekap bumil
  Future<void> save(RekapIbuAnak item) async {
    try {
      // ✅ Parsing manual — tanpa toJson
      final body = {
        'kelompok_dasa_wisma': item.kelompokDasaWisma,
        'rt': item.rt,
        'rw': item.rw,
        'dusun': item.dusun,
        'desa': item.desa,
        'bulan': item.bulan,
        'tahun': item.tahun,
        'nama_ibu': item.namaIbu,
        'nama_suami': item.namaSuami,
        'status_ibu': item.statusIbu,
        'ada_kelahiran': item.adaKelahiran,
        'nama_bayi': item.namaBayi,
        'jenis_kelamin_bayi': item.jenisKelaminBayi,
        'tanggal_lahir': item.tanggalLahir,
        'has_akta_kelahiran': item.hasAktaKelahiran,
        'ada_kematian': item.adaKematian,
        'status_meninggal': item.statusMeninggal,
        'keterangan': item.keterangan,
      };

      print('📤 POST rekap-bumil → $body');

      await http.post(
        Uri.parse(_endpoint),
        headers: await _headers(),
        body: jsonEncode(body),
      );
    } catch (e) {
      print('❌ POST rekap-bumil error: $e');
    }
  }

  Future<void> delete(int id) async {
    try {
      await http.delete(Uri.parse('$_endpoint/$id'), headers: await _headers());
    } catch (_) {}
  }

  Future<RekapIbuAnakSummary> getSummary() async {
    final list = await getAll();
    int hamil = 0, melahirkan = 0, nifas = 0, ibuMeninggal = 0;
    int bayiLahir = 0, bayiMeninggal = 0, balitaMeninggal = 0;
    for (final item in list) {
      final st = item.statusIbu.toLowerCase();
      if (st.contains('hamil')) hamil++;
      if (st.contains('lahir')) melahirkan++;
      if (st.contains('nifas')) nifas++;
      if (item.adaKelahiran) bayiLahir++;
      if (item.adaKematian) {
        final stK = item.statusMeninggal.toLowerCase();
        if (stK.contains('ibu')) ibuMeninggal++;
        if (stK.contains('bayi')) bayiMeninggal++;
        if (stK.contains('balita')) balitaMeninggal++;
      }
    }
    return RekapIbuAnakSummary(
      jumlahHamil: hamil,
      jumlahMelahirkan: melahirkan,
      jumlahNifas: nifas,
      jumlahIbuMeninggal: ibuMeninggal,
      jumlahBayiLahir: bayiLahir,
      jumlahBayiMeninggal: bayiMeninggal,
      jumlahBalitaMeninggal: balitaMeninggal,
    );
  }

  // ── Helper parsing ──────────────────────────────────
  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  String _toStr(dynamic v) {
    if (v == null) return '';
    return v.toString();
  }

  bool _toBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) return v.toLowerCase() == 'true' || v == '1';
    return false;
  }
}