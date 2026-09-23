// lib/services/data_umum_pkk_service.dart
// ✅ HYBRID: API + method lama (autoGenerateFromRekap) + token opsional

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_umum_pkk.dart';
import '../models/rekap_kegiatan_warga_berjenjang.dart';
import 'data_keluarga_dasawisma_service.dart';
import 'rekap_kegiatan_warga_berjenjang_service.dart';
import 'api_service.dart';

class DataUmumPkkService {
  static final DataUmumPkkService _instance = DataUmumPkkService._internal();
  factory DataUmumPkkService() => _instance;
  DataUmumPkkService._internal();

  final ApiService _api = ApiService();

  static const String _cacheKey = 'cache_data_umum_pkk_v1';
  List<DataUmumPkkItem> _cache = [];
  DateTime? _lastFetch;

  // ============================================================
  // GET — dari API
  // ============================================================
  Future<List<DataUmumPkkItem>> getAll({
    String? tahun,
    String? level,
    int? wilayahId,
    String? search,
  }) async {
    try {
      final rawList = await _api.getDataUmumPkk(
        tahun: tahun,
        level: level,
        wilayahId: wilayahId,
        search: search,
      );
      final list = rawList
          .map((item) => DataUmumPkkItem.fromJson(item))
          .toList();
      _cache = list;
      _lastFetch = DateTime.now();
      await _saveToCache(list);
      return list;
    } catch (e) {
      if (_cache.isEmpty) {
        await _loadFromCache();
      }
      if (_cache.isNotEmpty) return _cache;
      rethrow;
    }
  }

  /// Ambil by level — 'desa' atau 'kecamatan'
  Future<List<DataUmumPkkItem>> getByLevel(String level) async {
    return getAll(level: level);
  }

  Future<List<DataUmumPkkItem>> getByTahun(String tahun) async {
    return getAll(tahun: tahun);
  }

  Future<DataUmumPkkItem?> getById(int id) async {
    try {
      final json = await _api.getDataUmumPkkDetail(id);
      return DataUmumPkkItem.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // SAVE — token OPSIONAL
  // ============================================================
  Future<DataUmumPkkItem> save(DataUmumPkkItem item, [String? token]) async {
    token ??= await _token();
    if (item.id > 0) {
      // Update
      if (token.isEmpty) {
        // Tanpa token — simpan lokal
        await _updateCache(item);
        return item;
      }

      final json = await _api.updateDataUmumPkk(item.id, item.toJson(), token);
      final updated = DataUmumPkkItem.fromJson(json);
      await _updateCache(updated);
      return updated;
    } else {
      // Create
      if (token.isEmpty) {
        // Tanpa token — simpan lokal
        final newId = DateTime.now().millisecondsSinceEpoch % 100000;
        final newItem = item.copyWith(id: newId);
        _cache.insert(0, newItem);
        await _saveToCache(_cache);
        return newItem;
      }
      final json = await _api.createDataUmumPkk(item.toJson(), token);
      final created = DataUmumPkkItem.fromJson(json);
      _cache.insert(0, created);
      await _saveToCache(_cache);
      return created;
    }
  }

  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? '';
  }

  // ============================================================
  // DELETE — token OPSIONAL
  // ============================================================
  Future<void> delete(int id, [String? token]) async {
    if (token != null && token.isNotEmpty) {
      try {
        await _api.deleteDataUmumPkk(id, token);
      } catch (_) {
        // Silent — lanjut hapus lokal
      }
    }
    _cache.removeWhere((e) => e.id == id);
    await _saveToCache(_cache);
  }

  // ============================================================
  // ✅ METHOD LAMA — autoGenerateFromRekap — biar screen jalan
  // ============================================================
  Future<void> autoGenerateFromRekap(String level) async {
    final binaan = await DataKeluargaDasawismaService().getAll();
    final dataKk = binaan;

    if (binaan.isEmpty && dataKk.isEmpty) {
      throw StateError(
        'Belum ada data Keluarga Binaan atau Data KK untuk dihitung.',
      );
    }

    final wilayah = binaan.isNotEmpty ? binaan.first : null;
    final distinctRw = binaan
        .map((e) => e.rw)
        .where((e) => e.isNotEmpty)
        .toSet();
    final distinctRt = binaan
        .map((e) => e.rt)
        .where((e) => e.isNotEmpty)
        .toSet();
    final distinctDasaWisma = binaan
        .map((e) => e.dasaWisma)
        .where((e) => e.isNotEmpty)
        .toSet();
    final distinctDusun = binaan
        .map((e) => e.dusun.trim().toLowerCase())
        .where((e) => e.isNotEmpty)
        .toSet();
    final totalBalitaL = binaan.fold(
      0,
      (sum, e) => sum +
          (e.jumlahBalitaL + e.jumlahBalitaP > 0
              ? e.jumlahBalitaL
              : e.jumlahBalita),
    );
    final totalBalitaP = binaan.fold(0, (sum, e) => sum + e.jumlahBalitaP);
    final totalPus = binaan.fold(0, (sum, e) => sum + e.jumlahPus);
    final totalWus = binaan.fold(0, (sum, e) => sum + e.jumlahWus);
    final totalIbuHamil = binaan.fold(0, (sum, e) => sum + e.jumlahIbuHamil);
    final totalIbuMenyusui = binaan.fold(
      0,
      (sum, e) => sum + e.jumlahIbuMenyusui,
    );
    final totalLansia = binaan.fold(0, (sum, e) => sum + e.jumlahLansia);
    final totalButaL = binaan.fold(
      0,
      (sum, e) => sum +
          (e.jumlahTigaButaL + e.jumlahTigaButaP > 0
              ? e.jumlahTigaButaL
              : e.jumlahTigaButa),
    );
    final totalButaP = binaan.fold(0, (sum, e) => sum + e.jumlahTigaButaP);
    final totalRumahSehat = binaan
        .where((e) => e.kriteriaRumah.toLowerCase() == 'sehat')
        .length;
    final totalRumahKurangSehat = binaan.length - totalRumahSehat;
    final totalSampah = binaan.where((e) => e.memilikiTempatSampah).length;
    final totalSpal = binaan.where((e) => e.mempunyaiSpal).length;
    final totalAirPdam = binaan
        .where((e) => e.sumberAir.toLowerCase() == 'pdam')
        .length;
    final totalAirSumur = binaan
        .where((e) => e.sumberAir.toLowerCase() == 'sumur')
        .length;
    final totalAirSungai = binaan
        .where((e) => e.sumberAir.toLowerCase() == 'sungai')
        .length;
    final totalAirLainnya =
        binaan.length - totalAirPdam - totalAirSumur - totalAirSungai;
    final totalJamban = binaan.fold(0, (sum, e) => sum + e.jumlahMckSepticTank);
    final totalBeras = binaan
        .where((e) => e.makananPokok.toLowerCase() == 'beras')
        .length;
    final totalNonBeras = binaan.length - totalBeras;
    final totalUp2k = binaan.where((e) => e.aktifitasUp2k).length;
    final totalKesling = binaan
        .where((e) => e.aktifitasKesehatanLingkungan)
        .length;
    final totalStikerP4k =
        binaan.where((e) => e.memilikiStikerP4k).length;
    final totalKegiatanPekarangan =
        binaan.where((e) => e.aktifitasTanahPekarangan).length;
    final totalIndustriRumahTangga =
        binaan.where((e) => e.aktifitasIndustriRumahTangga).length;

    final existing = _cache.firstWhere(
      (e) => e.level == level && e.tahun == '2026',
      orElse: () => DataUmumPkkItem(id: 0, level: level, tahun: '2026'),
    );
    final item = DataUmumPkkItem(
      id: existing.id,
      level: level,
      tahun: '2026',
      kabupaten: wilayah?.kabupaten ?? 'TASIKMALAYA',
      provinsi: wilayah?.provinsi ?? 'JAWA BARAT',
      kecamatan: wilayah?.kecamatan ?? 'Singaparna',
      desa: wilayah?.desa ?? 'Singaparna',
      jumlahDusun: distinctDusun.length,
      jumlahPkkRw: distinctRw.length,
      jumlahPkkRt: distinctRt.length,
      jumlahDasaWisma: distinctDasaWisma.length,
      jumlahKrt: dataKk.fold(0, (sum, e) => sum + e.jumlahKk),
      jumlahKk: dataKk.fold(0, (sum, e) => sum + e.jumlahKk),
      jiwaL: binaan.fold(0, (sum, e) => sum + e.jumlahLakiLaki),
      jiwaP: binaan.fold(0, (sum, e) => sum + e.jumlahPerempuan),
      keterangan:
          'Auto-Isi dari ${binaan.length} Keluarga Binaan dan ${dataKk.length} Data KK',
    );

    final token = await _token();
    if (token.isEmpty) {
      throw StateError('Sesi login tidak ditemukan. Silakan login kembali.');
    }

    final rekapService = RekapKegiatanWargaBerjenjangService();
    final existingRekap = (await rekapService.getByLevel(
      level,
    )).where((e) => e.tahun == '2026').firstOrNull;
    await rekapService.save(
      RekapKegiatanWargaBerjenjangItem(
        id: existingRekap?.id ?? 0,
        level: level,
        tahun: '2026',
        kecamatan: wilayah?.kecamatan ?? 'Singaparna',
        namaKecamatan: wilayah?.kecamatan ?? 'Singaparna',
        desa: wilayah?.desa ?? 'Singaparna',
        namaDesa: wilayah?.desa ?? 'Singaparna',
        jumlahDusun: item.jumlahDusun,
        jumlahRw: item.jumlahPkkRw,
        jumlahRt: item.jumlahPkkRt,
        jumlahDasawisma: item.jumlahDasaWisma,
        jumlahKrt: item.jumlahKrt,
        jumlahKk: item.jumlahKk,
        totalL: item.jiwaL,
        totalP: item.jiwaP,
        balitaL: totalBalitaL,
        balitaP: totalBalitaP,
        pus: totalPus,
        wus: totalWus,
        ibuHamil: totalIbuHamil,
        ibuMenyusui: totalIbuMenyusui,
        lansia: totalLansia,
        butaL: totalButaL,
        butaP: totalButaP,
        memilikiStikerP4k: totalStikerP4k,
        rumahSehat: totalRumahSehat,
        rumahKurangSehat: totalRumahKurangSehat,
        memilikiTempatSampah: totalSampah,
        memilikiSpal: totalSpal,
        jumlahJambanKeluarga: totalJamban,
        airPdam: totalAirPdam,
        airSumur: totalAirSumur,
        airSungai: totalAirSungai,
        airDll: totalAirLainnya,
        makananPokokBeras: totalBeras,
        makananPokokNonBeras: totalNonBeras,
        kegiatanUp2k: totalUp2k,
        kegiatanTanahPekarangan: totalKegiatanPekarangan,
        kegiatanIndustriRumahTangga: totalIndustriRumahTangga,
        kegiatanKesehatanLingkungan: totalKesling,
        keterangan:
            'Auto-Isi dari ${binaan.length} Keluarga Binaan dan ${dataKk.length} Data KK',
      ),
      token,
    );

    final saved = await save(item, token);
    final existingIdx = _cache.indexWhere(
      (e) => e.level == saved.level && e.tahun == saved.tahun,
    );
    if (existingIdx >= 0) {
      _cache[existingIdx] = saved;
    } else {
      _cache.insert(0, saved);
    }
    await _saveToCache(_cache);
  }

  // ============================================================
  // CACHE
  // ============================================================
  Future<void> _saveToCache(List<DataUmumPkkItem> list) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(list.map((e) => e.toJson()).toList());
      await prefs.setString(_cacheKey, raw);
    } catch (_) {}
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _cache = list.map((e) => DataUmumPkkItem.fromJson(e)).toList();
      }
    } catch (_) {
      _cache = [];
    }
  }

  Future<void> _updateCache(DataUmumPkkItem item) async {
    final idx = _cache.indexWhere((e) => e.id == item.id);
    if (idx >= 0) {
      _cache[idx] = item;
    } else {
      _cache.insert(0, item);
    }
    await _saveToCache(_cache);
  }

  Future<void> clearCache() async {
    _cache = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  DateTime? get lastFetch => _lastFetch;
}
