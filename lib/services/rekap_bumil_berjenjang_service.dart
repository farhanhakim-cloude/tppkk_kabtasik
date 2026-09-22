// lib/services/rekap_bumil_berjenjang_service.dart
// ✅ FIX: Ganti SharedPreferences → API
// Sumber data: API Laravel — /api/rekap-bumil
// Cache: opsional — untuk offline

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/rekap_bumil_berjenjang.dart';
import 'api_service.dart';

class RekapBumilBerjenjangService {
  static final RekapBumilBerjenjangService _instance =
      RekapBumilBerjenjangService._internal();
  factory RekapBumilBerjenjangService() => _instance;
  RekapBumilBerjenjangService._internal();

  final ApiService _api = ApiService();

  static const String _cacheKey = 'cache_rekap_bumil_v1';
  List<RekapBumilBerjenjangItem> _cache = [];
  DateTime? _lastFetch;

  // ============================================================
  // GET — dari API
  // ============================================================

  Future<List<RekapBumilBerjenjangItem>> getAll({
    String? tahun,
    String? bulan,
    String? level,
    int? wilayahId,
    String? search,
  }) async {
    try {
      final list = await _api.getRekapBumil(
        tahun: tahun,
        bulan: bulan,
        level: level,
        wilayahId: wilayahId,
        search: search,
      );
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

  Future<List<RekapBumilBerjenjangItem>> getByLevel(String level) async {
    return getAll(level: level);
  }

  Future<List<RekapBumilBerjenjangItem>> getByTahun(String tahun) async {
    return getAll(tahun: tahun);
  }

  Future<List<RekapBumilBerjenjangItem>> getByBulan(String tahun, int bulan) async {
    return getAll(tahun: tahun, bulan: bulan.toString());
  }

  Future<RekapBumilBerjenjangItem?> getById(int id) async {
    try {
      final json = await _api.getRekapBumilDetail(id);
      return RekapBumilBerjenjangItem.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // SAVE — ke API (POST / PUT)
  // ============================================================

  Future<RekapBumilBerjenjangItem> save(
    RekapBumilBerjenjangItem item,
    String token,
  ) async {
    if (item.id > 0) {
      final json = await _api.updateRekapBumil(item.id, item.toJson(), token);
      final updated = RekapBumilBerjenjangItem.fromJson(json);
      await _updateCache(updated);
      return updated;
    } else {
      final json = await _api.createRekapBumil(item.toJson(), token);
      final created = RekapBumilBerjenjangItem.fromJson(json);
      _cache.insert(0, created);
      await _saveToCache(_cache);
      return created;
    }
  }

  // ============================================================
  // DELETE — ke API
  // ============================================================

  Future<void> delete(int id, String token) async {
    await _api.deleteRekapBumil(id, token);
    _cache.removeWhere((e) => e.id == id);
    await _saveToCache(_cache);
  }

  // ============================================================
  // CACHE — SharedPreferences (offline only)
  // ============================================================

  Future<void> _saveToCache(List<RekapBumilBerjenjangItem> list) async {
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
            .map((e) => RekapBumilBerjenjangItem.fromJson(e))
            .toList();
      }
    } catch (_) {
      _cache = [];
    }
  }

  Future<void> _updateCache(RekapBumilBerjenjangItem item) async {
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