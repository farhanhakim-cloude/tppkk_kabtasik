// lib/services/kriteria_rumah_service.dart

import '../models/kriteria_rumah.dart';

class KriteriaRumahService {
  // In-memory store (replace with SQLite/Hive for production)
  final List<KriteriaRumah> _store = [];
  int _idCounter = 1;

  Future<List<KriteriaRumah>> getAll({String query = ''}) async {
    await Future.delayed(const Duration(milliseconds: 60));
    if (query.isEmpty) return List.from(_store);
    final q = query.toLowerCase();
    return _store
        .where((k) =>
            k.namaKepalaKeluarga.toLowerCase().contains(q) ||
            k.noKk.toLowerCase().contains(q) ||
            k.dasaWisma.toLowerCase().contains(q) ||
            k.desa.toLowerCase().contains(q))
        .toList();
  }

  Future<KriteriaRumah> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 40));
    return _store.firstWhere((k) => k.id == id);
  }

  Future<void> save(KriteriaRumah data) async {
    await Future.delayed(const Duration(milliseconds: 80));
    final idx = _store.indexWhere((k) => k.id == data.id);
    if (idx >= 0) {
      _store[idx] = data;
    } else {
      final newData = data.copyWith(id: '${_idCounter++}');
      _store.add(newData);
    }
  }

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 60));
    _store.removeWhere((k) => k.id == id);
  }

  // Statistik ringkasan
  Future<Map<String, int>> getStatistik() async {
    await Future.delayed(const Duration(milliseconds: 40));
    int layak = 0;
    int perluPerhatian = 0;
    int tidakLayak = 0;
    for (final k in _store) {
      switch (k.statusRumah) {
        case 'Layak Huni':
          layak++;
          break;
        case 'Perlu Perhatian':
          perluPerhatian++;
          break;
        case 'Tidak Layak Huni':
          tidakLayak++;
          break;
      }
    }
    return {
      'layak': layak,
      'perluPerhatian': perluPerhatian,
      'tidakLayak': tidakLayak,
      'total': _store.length,
    };
  }
}
