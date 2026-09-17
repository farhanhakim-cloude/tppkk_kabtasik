import '../models/dasawisma_catatan_keluarga.dart';

class DasawismaCatatanKeluargaService {
  static final DasawismaCatatanKeluargaService _instance = DasawismaCatatanKeluargaService._internal();
  factory DasawismaCatatanKeluargaService() => _instance;
  DasawismaCatatanKeluargaService._internal();

  final List<DasawismaCatatanKeluarga> _items = [];
  int _idCounter = 1;

  Future<List<DasawismaCatatanKeluarga>> getAll({String query = '', String? tahun, String? desa, String? kecamatan}) async {
    await Future.delayed(const Duration(milliseconds: 80));
    Iterable<DasawismaCatatanKeluarga> filtered = _items;
    if (tahun != null && tahun.isNotEmpty) filtered = filtered.where((e) => e.tahun == tahun);
    if (desa != null && desa.isNotEmpty) filtered = filtered.where((e) => e.desa.toLowerCase() == desa.toLowerCase());
    if (kecamatan != null && kecamatan.isNotEmpty) filtered = filtered.where((e) => e.kecamatan.toLowerCase() == kecamatan.toLowerCase());
    if (query.trim().isEmpty) return List.from(filtered);
    final q = query.toLowerCase().trim();
    return filtered.where((e) => e.dasaWisma.toLowerCase().contains(q) || e.desa.toLowerCase().contains(q) || e.rt.contains(q) || e.rw.contains(q) || e.tahun.contains(q) || e.items.any((it) => it.namaAnggota.toLowerCase().contains(q))).toList();
  }

  Future<DasawismaCatatanKeluarga?> getById(String id) async {
    await Future.delayed(const Duration(milliseconds: 40));
    try { return _items.firstWhere((e) => e.id == id); } catch (_) { return null; }
  }

  Future<void> save(DasawismaCatatanKeluarga data) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = _items.indexWhere((e) => e.id == data.id);
    if (idx >= 0) { _items[idx] = data; } else { final newId = data.id.isEmpty || data.id == '0' ? '${_idCounter++}' : data.id; _items.insert(0, data.copyWith(id: newId)); }
  }

  Future<void> add(DasawismaCatatanKeluarga data) => save(data);
  Future<void> update(DasawismaCatatanKeluarga data) => save(data);

  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 60));
    _items.removeWhere((e) => e.id == id);
  }

  Future<List<DasawismaCatatanKeluarga>> getByWilayah({String? rt, String? rw, String? dusun, String? desa, String? kecamatan, String? tahun}) async {
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
    return {'total': _items.length, 'totalAnggota': _items.fold(0, (sum, e) => sum + e.totalAnggota), 'totalLaki': _items.fold(0, (sum, e) => sum + e.totalLaki), 'totalPerempuan': _items.fold(0, (sum, e) => sum + e.totalPerempuan)};
  }
}
