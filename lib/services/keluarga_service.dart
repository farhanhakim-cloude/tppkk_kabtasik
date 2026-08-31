import '../models/keluarga.dart';

class KeluargaService {
  // SEKARANG: data dummy disimpan di memory (hilang kalau app di-restart)
  static final List<Keluarga> _data = [
    Keluarga(id: 1, namaKepalaKeluarga: 'Ahmad Fauzi', alamat: 'Jl. Mawar No. 12', rt: '01', rw: '05', jumlahAnggota: 4, pekerjaan: 'Wiraswasta', latitude: -7.3274, longitude: 108.2207),
    Keluarga(id: 2, namaKepalaKeluarga: 'Budi Santoso', alamat: 'Jl. Kenanga No. 7', rt: '02', rw: '05', jumlahAnggota: 3, pekerjaan: 'PNS', latitude: -7.3298, longitude: 108.2145),
    Keluarga(id: 3, namaKepalaKeluarga: 'Cecep Hidayat', alamat: 'Jl. Melati No. 21', rt: '01', rw: '06', jumlahAnggota: 5, pekerjaan: 'Petani', latitude: -7.3341, longitude: 108.2289),
  ];

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