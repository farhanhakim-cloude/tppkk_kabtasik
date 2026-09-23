import '../models/keluarga.dart';

class KeluargaService {
  static final List<Keluarga> _data = [];

  Future<List<Keluarga>> getAll({String query = ''}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (query.isEmpty) return List.from(_data);
    return _data
        .where((k) => k.namaKepalaKeluarga.toLowerCase().contains(query.toLowerCase()))
        .toList();

    // NANTI: ganti jadi
    // final response = await http.get(Uri.parse('$baseUrl/keluarga?search=$query'));
    // return parseKeluargaList(response.body);
  }

  Future<void> add(Keluarga keluarga) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newId = (_data.isEmpty ? 0 : _data.map((k) => k.id).reduce((a, b) => a > b ? a : b)) + 1;
    _data.add(keluarga.copyWith(id: newId));

    // NANTI: ganti jadi http.post(...) ke endpoint /keluarga
  }

  Future<void> update(Keluarga keluarga) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _data.indexWhere((k) => k.id == keluarga.id);
    if (index != -1) _data[index] = keluarga;

    // NANTI: ganti jadi http.put(...) ke endpoint /keluarga/{id}
  }

  Future<void> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _data.removeWhere((k) => k.id == id);

    // NANTI: ganti jadi http.delete(...) ke endpoint /keluarga/{id}
  }
}
