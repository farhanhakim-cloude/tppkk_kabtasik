// lib/services/data_keluarga_dasawisma_service.dart
// Pakai SharedPreferences agar data rekap Dasawisma tetap tersedia lokal.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/data_keluarga_dasawisma.dart';

class DataKeluargaDasawismaService {
  static final DataKeluargaDasawismaService _instance =
      DataKeluargaDasawismaService._internal();
  factory DataKeluargaDasawismaService() => _instance;
  DataKeluargaDasawismaService._internal();

  static const String _prefKey = 'data_keluarga_dasawisma_v2';
  List<DataKeluargaDasawisma> _cache = [];
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw != null && raw.isNotEmpty) {
        final List decoded = jsonDecode(raw);
        _cache = decoded
            .map(
              (e) => DataKeluargaDasawisma.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }
    } catch (_) {
      _cache = [];
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(_cache.map((e) => e.toJson()).toList());
      await prefs.setString(_prefKey, encoded);
    } catch (_) {}
  }

  Future<List<DataKeluargaDasawisma>> getAll({String query = ''}) async {
    await _ensureLoaded();
    if (query.trim().isEmpty) return List.from(_cache);
    final q = query.toLowerCase();
    return _cache.where((e) {
      return e.namaKepalaRumahTangga.toLowerCase().contains(q) ||
          e.dasaWisma.toLowerCase().contains(q) ||
          e.rt.contains(q) ||
          e.rw.contains(q) ||
          e.desa.toLowerCase().contains(q) ||
          e.kecamatan.toLowerCase().contains(q);
    }).toList();
  }

  Future<DataKeluargaDasawisma?> getById(int id) async {
    await _ensureLoaded();
    try {
      return _cache.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<DataKeluargaDasawisma> save(DataKeluargaDasawisma item) async {
    await _ensureLoaded();
    final idx = _cache.indexWhere((e) => e.id == item.id);
    if (idx >= 0) {
      _cache[idx] = item;
      await _persist();
      return item;
    }

    final newId = _cache.isEmpty
        ? 1
        : (_cache.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
    final newItem = item.copyWith(id: newId);
    _cache.insert(0, newItem);
    await _persist();
    return newItem;
  }

  Future<void> delete(int id) async {
    await _ensureLoaded();
    _cache.removeWhere((e) => e.id == id);
    await _persist();
  }

  void invalidate() {
    _loaded = false;
    _cache = [];
  }
}
