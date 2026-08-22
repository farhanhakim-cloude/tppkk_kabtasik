import '../models/catatan_kegiatan.dart';

class CatatanKegiatanService {
  static final List<CatatanKegiatan> _data = [];

  Future<List<CatatanKegiatan>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final list = List<CatatanKegiatan>.from(_data);
    list.sort((a, b) => b.tanggal.compareTo(a.tanggal)); // terbaru dulu
    return list;

    // NANTI: ganti jadi http.get('$baseUrl/catatan-kegiatan')
  }

  Future<void> kirim(CatatanKegiatan catatan) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newId = (_data.isEmpty ? 0 : _data.map((c) => c.id).reduce((a, b) => a > b ? a : b)) + 1;
    _data.add(CatatanKegiatan(
      id: newId,
      judul: catatan.judul,
      ceritaSingkat: catatan.ceritaSingkat,
      kategori: catatan.kategori,
      dataAngka: catatan.dataAngka,
      fotoPath: catatan.fotoPath,
      tanggal: catatan.tanggal,
    ));

    // NANTI: ganti jadi http.post multipart ke '$baseUrl/catatan-kegiatan' (karena ada upload foto)
  }
}