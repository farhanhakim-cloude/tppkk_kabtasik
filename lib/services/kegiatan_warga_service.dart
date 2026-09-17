import '../models/kegiatan_warga.dart';

class KegiatanWargaService {
  static final KegiatanWargaService _instance = KegiatanWargaService._internal();
  factory KegiatanWargaService() => _instance;
  KegiatanWargaService._internal();

  final List<KegiatanWarga> _items = [];
  int _idCounter = 1;

  Future<List<KegiatanWarga>> getAll({String query = '', String? tahun, String? desa}) async {
    await Future.delayed(const Duration(milliseconds: 80));
    Iterable<KegiatanWarga> filtered = _items;
    if (tahun != null && tahun.isNotEmpty) filtered = filtered.where((e) => e.tahun == tahun);
    if (desa != null && desa.isNotEmpty) filtered = filtered.where((e) => e.desa.toLowerCase() == desa.toLowerCase());
    if (query.trim().isEmpty) return List.from(filtered);
    final q = query.toLowerCase().trim();
    return filtered.where((e) {
      return e.dasaWisma.toLowerCase().contains(q) ||
          e.desa.toLowerCase().contains(q) ||
          e.rt.contains(q) ||
          e.rw.contains(q) ||
          e.tahun.contains(q) ||
          e.items.any((it) => it.nama.toLowerCase().contains(q));
    }).toList();
  }

  Future<KegiatanWarga?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 40));
    try {
      return _items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(KegiatanWarga data) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = _items.indexWhere((e) => e.id == data.id);
    if (idx >= 0) {
      _items[idx] = data;
    } else {
      final newId = data.id.isEmpty || data.id == '0' ? '${_idCounter++}' : data.id;
      _items.insert(0, data.copyWith(id: newId));
    }
  }

  Future<void> add(KegiatanWarga data) => save(data);
  Future<void> update(KegiatanWarga data) => save(data);

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 60));
    _items.removeWhere((e) => e.id == id);
  }

  Future<List<KegiatanWarga>> getByWilayah({
    String? rt,
    String? rw,
    String? dusun,
    String? desa,
    String? kecamatan,
    String? tahun,
  }) async {
    await Future.delayed(const Duration(milliseconds: 60));
    return _items.where((e) {
      if (rt != null && rt.isNotEmpty && e.rt != rt) return false;
      if (rw != null && rw.isNotEmpty && e.rw != rw) return false;
      if (dusun != null && dusun.isNotEmpty && e.dusun.toLowerCase() != dusun.toLowerCase()) return false;
      if (desa != null && desa.isNotEmpty && e.desa.toLowerCase() != desa.toLowerCase()) return false;
      if (kecamatan != null && kecamatan.isNotEmpty && e.kecamatan.toLowerCase() != kecamatan.toLowerCase()) return false;
      if (tahun != null && tahun.isNotEmpty && e.tahun != tahun) return false;
      return true;
    }).toList();
  }

  Future<Map<String, int>> getStatistik() async {
    await Future.delayed(const Duration(milliseconds: 40));
    final map = <String, int>{'total': _items.length, 'totalAktif': 0};
    for (final d in _items) {
      for (final it in d.items) {
        if (it.aktif) {
          map['totalAktif'] = (map['totalAktif'] ?? 0) + 1;
          map[it.nama] = (map[it.nama] ?? 0) + 1;
        }
      }
    }
    return map;
  }
}
