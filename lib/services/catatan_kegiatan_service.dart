import '../models/catatan_kegiatan.dart';

class CatatanKegiatanService {
  static final CatatanKegiatanService _instance = CatatanKegiatanService._internal();
  factory CatatanKegiatanService() => _instance;
  CatatanKegiatanService._internal();

  final List<CatatanKegiatan> _data = [
    CatatanKegiatan(
      id: 1,
      judul: 'Penyuluhan Pola Asuh Anak & Remaja (PAAR)',
      deskripsiSingkat: 'Sosialisasi pembinaan pola asuh anak dengan cinta kasih dan pencegahan kekerasan dalam rumah tangga bagi warga Singaparna.',
      kategori: PokjaKategori.pokja1,
      kecamatan: 'Singaparna',
      desa: 'Cikunten',
      tanggal: DateTime.now().subtract(const Duration(days: 1)),
      status: StatusKegiatan.dibaca,
    ),
    CatatanKegiatan(
      id: 2,
      judul: 'Pelatihan Olahan Pangan Lokal UP2K PKK',
      deskripsiSingkat: 'Pelatihan pembuatan keripik pisang aneka rasa dan kemasan higienis untuk peningkatan ekonomi kelompok UP2K.',
      kategori: PokjaKategori.pokja2,
      kecamatan: 'Rajapolah',
      desa: 'Manggungjaya',
      tanggal: DateTime.now().subtract(const Duration(days: 3)),
      status: StatusKegiatan.terkirim,
    ),
    CatatanKegiatan(
      id: 3,
      judul: 'Gerakan Menanam Halaman Asri Teratur Indah dan Nyaman (HATINYA PKK)',
      deskripsiSingkat: 'Penanaman bibit cabai, sayuran hidroponik, dan tanaman obat keluarga (TOGA) di pekarangan warga.',
      kategori: PokjaKategori.pokja3,
      kecamatan: 'Cisayong',
      desa: 'Nusawangi',
      tanggal: DateTime.now().subtract(const Duration(days: 5)),
      status: StatusKegiatan.terkirim,
    ),
    CatatanKegiatan(
      id: 4,
      judul: 'Penimbangan Balita & Pemeriksaan Ibu Hamil di Posyandu Melati',
      deskripsiSingkat: 'Pelaksanaan posyandu rutin balita gizi terpantau, pemberian vitamin A, dan penyuluhan sanitasi jamban sehat.',
      kategori: PokjaKategori.pokja4,
      kecamatan: 'Manonjaya',
      desa: 'Pasirbatang',
      tanggal: DateTime.now().subtract(const Duration(days: 7)),
      status: StatusKegiatan.dibaca,
    ),
  ];

  Future<List<CatatanKegiatan>> getAll({String? query, PokjaKategori? kategori}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    var list = List<CatatanKegiatan>.from(_data);
    if (kategori != null) {
      list = list.where((c) => c.kategori == kategori).toList();
    }
    if (query != null && query.isNotEmpty) {
      list = list
          .where((c) =>
              c.judul.toLowerCase().contains(query.toLowerCase()) ||
              c.kecamatan.toLowerCase().contains(query.toLowerCase()) ||
              c.deskripsiSingkat.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return list;
  }

  Future<CatatanKegiatan?> getById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _data.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(CatatanKegiatan catatan) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _data.indexWhere((c) => c.id == catatan.id);
    if (index >= 0) {
      _data[index] = catatan;
    } else {
      final newId = _data.isEmpty ? 1 : _data.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
      _data.insert(0, catatan.copyWith(id: newId));
    }
  }

  Future<void> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _data.removeWhere((c) => c.id == id);
  }
}