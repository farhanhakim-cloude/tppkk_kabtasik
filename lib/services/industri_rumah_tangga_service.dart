// lib/services/industri_rumah_tangga_service.dart

import '../models/industri_rumah_tangga.dart';

class IndustriRumahTanggaService {
  final List<IndustriRumahTangga> _store = [];
  int _idCounter = 1;

  Future<List<IndustriRumahTangga>> getAll({String query = ''}) async {
    await Future.delayed(const Duration(milliseconds: 60));
    if (query.trim().isEmpty) return List.from(_store);
    final q = query.toLowerCase().trim();
    return _store.where((d) {
      return d.namaKepalaKeluarga.toLowerCase().contains(q) ||
          d.dasaWisma.toLowerCase().contains(q) ||
          d.rt.contains(q) ||
          d.rw.contains(q) ||
          d.items.any((i) =>
              i.kategori.toLowerCase().contains(q) ||
              i.komoditi.toLowerCase().contains(q));
    }).toList();
  }

  Future<IndustriRumahTangga?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 40));
    try {
      return _store.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> add(IndustriRumahTangga data) async {
    await Future.delayed(const Duration(milliseconds: 80));
    final withId = data.copyWith(id: '${_idCounter++}');
    _store.add(withId);
  }

  Future<void> update(IndustriRumahTangga data) async {
    await Future.delayed(const Duration(milliseconds: 80));
    final idx = _store.indexWhere((d) => d.id == data.id);
    if (idx >= 0) _store[idx] = data;
  }

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 60));
    _store.removeWhere((d) => d.id == id);
  }

  Future<Map<String, int>> getStatistik() async {
    await Future.delayed(const Duration(milliseconds: 40));
    final Map<String, int> kategoriCount = {};
    for (final d in _store) {
      for (final item in d.items) {
        if (item.kategori.isNotEmpty) {
          kategoriCount[item.kategori] = (kategoriCount[item.kategori] ?? 0) + 1;
        }
      }
    }
    return {
      'total': _store.length,
      'totalKomoditi': _store.fold(0, (sum, d) => sum + d.items.length),
      ...kategoriCount,
    };
  }
}
