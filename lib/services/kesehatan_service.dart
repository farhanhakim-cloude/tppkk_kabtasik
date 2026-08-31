import '../models/kesehatan.dart';

class KesehatanService {
  static final List<DataKesehatan> _data = [
    DataKesehatan(id: 1, namaIbu: 'Siti Aminah', kategori: KategoriKesehatan.ibuHamil, usiaKehamilanAtauAnak: '28 minggu', rt: '01', rw: '05'),
    DataKesehatan(id: 2, namaIbu: 'Dewi Lestari', namaAnak: 'Raka', kategori: KategoriKesehatan.balita, usiaKehamilanAtauAnak: '18 bulan', statusGizi: 'Normal', rt: '02', rw: '05'),
    DataKesehatan(id: 3, namaIbu: 'Nur Halimah', namaAnak: 'Aisyah', kategori: KategoriKesehatan.balita, usiaKehamilanAtauAnak: '8 bulan', statusGizi: 'Kurang', rt: '01', rw: '06'),
    DataKesehatan(id: 4, namaIbu: 'Wulan Sari', kategori: KategoriKesehatan.ibuMenyusui, usiaKehamilanAtauAnak: '2 bulan', rt: '03', rw: '05'),
    DataKesehatan(id: 5, namaIbu: 'Lilis Karlina', namaAnak: 'Dimas', kategori: KategoriKesehatan.anak, usiaKehamilanAtauAnak: '6 tahun', statusGizi: 'Normal', rt: '01', rw: '05'),
    DataKesehatan(id: 6, namaIbu: 'Rina Nose', namaAnak: 'Zahra', kategori: KategoriKesehatan.anak, usiaKehamilanAtauAnak: '8 tahun', statusGizi: 'Normal', rt: '03', rw: '06'),
  ];

  Future<List<DataKesehatan>> getAll({KategoriKesehatan? filter}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (filter == null) return List.from(_data);
    return _data.where((d) => d.kategori == filter).toList();

    // NANTI: ganti jadi http.get('$baseUrl/kesehatan?kategori=...')
  }

  Future<void> add(DataKesehatan data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newId = (_data.isEmpty ? 0 : _data.map((d) => d.id).reduce((a, b) => a > b ? a : b)) + 1;
    _data.add(data.salin(id: newId));
  }

  Future<void> update(DataKesehatan data) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _data.indexWhere((d) => d.id == data.id);
    if (index != -1) _data[index] = data;
  }

  Future<void> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _data.removeWhere((d) => d.id == id);
  }
}