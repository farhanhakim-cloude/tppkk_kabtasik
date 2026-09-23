// lib/services/rekap_kegiatan_warga_berjenjang_service.dart
// ✅ FIX: Ganti SharedPreferences → API
// Sumber data: API Laravel — /api/rekap-kegiatan-warga
// Cache: opsional — untuk offline

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rekap_kegiatan_warga_berjenjang.dart';
import 'api_service.dart';

class RekapKegiatanWargaBerjenjangService {
  static final RekapKegiatanWargaBerjenjangService _instance =
      RekapKegiatanWargaBerjenjangService._internal();
  factory RekapKegiatanWargaBerjenjangService() => _instance;
  RekapKegiatanWargaBerjenjangService._internal();

  final ApiService _api = ApiService();

  static const String _cacheKey = 'cache_rekap_kegiatan_warga_v1';
  List<RekapKegiatanWargaBerjenjangItem> _cache = [];
  DateTime? _lastFetch;

  // ============================================================
  // GET — dari API
  // ============================================================

  Future<List<RekapKegiatanWargaBerjenjangItem>> getAll({
    String? tahun,
    String? level,
    int? wilayahId,
    String? search,
  }) async {
    try {
      final rawList = await _api.getRekapKegiatanWarga(
        tahun: tahun,
        level: level,
        wilayahId: wilayahId,
        search: search,
      );
      final list = rawList
          .map((e) => RekapKegiatanWargaBerjenjangItem.fromJson(e))
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

  Future<List<RekapKegiatanWargaBerjenjangItem>> getByLevel(
    String level,
  ) async {
    return getAll(level: level);
  }

  Future<RekapKegiatanWargaBerjenjangItem?> getById(int id) async {
    try {
      final json = await _api.getRekapKegiatanWargaDetail(id);
      return RekapKegiatanWargaBerjenjangItem.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<List<RekapKegiatanWargaBerjenjangItem>> getByTahun(
    String tahun,
  ) async {
    return getAll(tahun: tahun);
  }

  // ============================================================
  // SAVE — ke API (POST / PUT)
  // ============================================================

  Future<RekapKegiatanWargaBerjenjangItem> save(
    RekapKegiatanWargaBerjenjangItem item, [
    String? token,
  ]) async {
    if (token == null || token.isEmpty) {
      // Simpan lokal tanpa token
      final idx = _cache.indexWhere((e) => e.id == item.id);
      final saved = item.id > 0
          ? item
          : item.copyWith(id: DateTime.now().millisecondsSinceEpoch % 100000);
      if (idx >= 0) {
        _cache[idx] = saved;
      } else {
        _cache.insert(0, saved);
      }
      await _saveToCache(_cache);
      return saved;
    }
    if (item.id > 0) {
      final json = await _api.updateRekapKegiatanWarga(
        item.id,
        item.toJson(),
        token,
      );
      final updated = RekapKegiatanWargaBerjenjangItem.fromJson(json);
      await _updateCache(updated);
      return updated;
    } else {
      final json = await _api.createRekapKegiatanWarga(item.toJson(), token);
      final created = RekapKegiatanWargaBerjenjangItem.fromJson(json);
      _cache.insert(0, created);
      await _saveToCache(_cache);
      return created;
    }
  }

  /// Auto-generate dari data Dasawisma — stub untuk kompatibilitas screen lama
  Future<void> autoGenerateFromDasawisma(String level) async {
    // Fitur ini sudah dimigrasi ke API — tidak ada aksi lokal
  }

  // ============================================================
  // DELETE — ke API
  // ============================================================

  Future<void> delete(int id, [String? token]) async {
    if (token != null && token.isNotEmpty) {
      try {
        await _api.deleteRekapKegiatanWarga(id, token);
      } catch (_) {}
    }
    _cache.removeWhere((e) => e.id == id);
    await _saveToCache(_cache);
  }

  // ============================================================
  // CACHE — SharedPreferences (offline only)
  // ============================================================

  Future<void> _saveToCache(List<RekapKegiatanWargaBerjenjangItem> list) async {
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
        _cache = list
            .map((e) => RekapKegiatanWargaBerjenjangItem.fromJson(e))
            .toList();
      }
    } catch (_) {
      _cache = [];
    }
  }

  Future<void> _updateCache(RekapKegiatanWargaBerjenjangItem item) async {
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
