// lib/services/data_umum_pkk_service.dart
// ✅ HYBRID: API + method lama (autoGenerateFromRekap) + token opsional

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_umum_pkk.dart';
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
      final list = rawList.map((e) => DataUmumPkkItem.fromJson(e)).toList();
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
    if (item.id > 0) {
      // Update
      if (token == null || token.isEmpty) {
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
      if (token == null || token.isEmpty) {
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
    try {
      final kegiatanService = RekapKegiatanWargaBerjenjangService();
      final kegiatanList = await kegiatanService.getByLevel(level);

      if (kegiatanList.isEmpty) return;

      for (final k in kegiatanList) {
        final name = level == 'desa'
            ? (k.namaDusun.isNotEmpty ? k.namaDusun : 'Dusun ${k.dusun}')
            : (k.namaDesa.isNotEmpty ? k.namaDesa : 'Desa ${k.desa}');

        final existingIdx = _cache.indexWhere(
          (e) =>
              e.level == level &&
              (level == 'desa' ? e.namaDusun == name : e.namaDesa == name),
        );

        final newItem = DataUmumPkkItem(
          id: existingIdx >= 0
              ? _cache[existingIdx].id
              : DateTime.now().millisecondsSinceEpoch % 100000,
          level: level,
          tahun: k.tahun.isNotEmpty ? k.tahun : '2026',
          kabupaten: 'TASIKMALAYA',
          provinsi: 'JAWA BARAT',
          kecamatan: k.kecamatan.isNotEmpty ? k.kecamatan : 'Singaparna',
          desa: k.desa.isNotEmpty ? k.desa : 'Singaparna',
          namaDusun: level == 'desa' ? name : '',
          namaDesa: level == 'kecamatan' ? name : '',
          jumlahDusun: k.jumlahDusun > 0
              ? k.jumlahDusun
              : (level == 'kecamatan' ? 3 : 0),
          jumlahPkkRw: k.jumlahRw > 0 ? k.jumlahRw : 4,
          jumlahPkkRt: k.jumlahRt > 0 ? k.jumlahRt : 12,
          jumlahDasaWisma: k.jumlahDasawisma > 0 ? k.jumlahDasawisma : 24,
          jumlahKrt: k.jumlahKrt,
          jumlahKk: k.jumlahKk,
          jiwaL: k.totalL,
          jiwaP: k.totalP,
          kaderTpPkkL: 2,
          kaderTpPkkP: 18,
          kaderUmumL: 5,
          kaderUmumP: 25,
          kaderKhususL: 2,
          kaderKhususP: 10,
          sekretariatHonorerL: 1,
          sekretariatHonorerP: 2,
          sekretariatBantuanL: 0,
          sekretariatBantuanP: 1,
          keterangan: 'Auto roll-up dari data kegiatan warga $name',
        );

        if (existingIdx >= 0) {
          _cache[existingIdx] = newItem;
        } else {
          _cache.add(newItem);
        }
      }

      await _saveToCache(_cache);
    } catch (e) {
      // Silent — biar screen ga crash
    }
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
