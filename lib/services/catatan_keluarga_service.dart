import '../models/catatan_keluarga_pokja.dart';

class CatatanKeluargaService {
  static final CatatanKeluargaService _instance = CatatanKeluargaService._internal();
  factory CatatanKeluargaService() => _instance;
  CatatanKeluargaService._internal();

  final List<CatatanKeluargaPokja> _data = [
    CatatanKeluargaPokja(
      id: 1,
      keluargaId: 1,
      namaKepalaKeluarga: 'Ahmad Subagja',
      rt: '02',
      rw: '05',
      tanggalInput: DateTime.now().subtract(const Duration(days: 2)),
      penghayatanPancasila: [
        'Keagamaan (Ibadah, Pengajian dll)',
        'Pola Asuh',
        'Pencegahan PKDRT',
        'PKBN',
      ],
      gotongRoyong: [
        'Kerja Bakti / Rukun Tetangga',
        'Rukun Kematian',
        'Jimpitan / Arisan',
      ],
      pendidikanKeterampilan: [
        'Bina Keluarga Balita (BKB)',
        'PAUD / TPQ',
        'Pelatihan Keterampilan',
      ],
      pengembanganKoperasi: [
        'Kelompok UP2K Aktif',
        'Anggota Koperasi PKK',
      ],
      panganSandangTataLaksana: [
        'Makanan Pokok Beras Seimbang',
        'Pemanfaatan Pekarangan (Hatinya PKK)',
        'Rumah Sehat Layak Huni',
      ],
      kesehatanLingkungan: [
        'Tempat Sampah Terpisah',
        'Jamban Sehat / MCK Keluarga',
        'Sumber Air Bersih Terlindung',
        'Stiker P4K Terpasang',
      ],
      perencanaanSehat: [
        'Akseptor KB Aktif',
        'Memiliki BPJS / Asuransi Kesehatan',
        'PHBS Terverifikasi',
      ],
    ),
    CatatanKeluargaPokja(
      id: 2,
      keluargaId: 2,
      namaKepalaKeluarga: 'Budi Santoso',
      rt: '01',
      rw: '05',
      tanggalInput: DateTime.now().subtract(const Duration(days: 5)),
      penghayatanPancasila: [
        'Keagamaan (Ibadah, Pengajian dll)',
        'PKBN',
        'Pencegahan Narkoba',
      ],
      gotongRoyong: [
        'Kerja Bakti / Rukun Tetangga',
        'Jimpitan / Arisan',
      ],
      pendidikanKeterampilan: [
        'Pelatihan Keterampilan Wirausaha',
      ],
      pengembanganKoperasi: [
        'Tabungan Mandiri Keluarga',
      ],
      panganSandangTataLaksana: [
        'Makanan Pokok Beras Seimbang',
        'Pemanfaatan Pekarangan (Hatinya PKK)',
      ],
      kesehatanLingkungan: [
        'Jamban Sehat / MCK Keluarga',
        'Sumber Air Bersih Terlindung',
      ],
      perencanaanSehat: [
        'Akseptor KB Aktif',
        'Memiliki BPJS / Asuransi Kesehatan',
      ],
    ),
  ];

  Future<List<CatatanKeluargaPokja>> getAll({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (query != null && query.isNotEmpty) {
      return _data
          .where((k) =>
              k.namaKepalaKeluarga.toLowerCase().contains(query.toLowerCase()) ||
              k.rt.contains(query) ||
              k.rw.contains(query))
          .toList();
    }
    return List.from(_data);
  }

  Future<CatatanKeluargaPokja?> getById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _data.firstWhere((k) => k.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(CatatanKeluargaPokja item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _data.indexWhere((k) => k.id == item.id);
    if (index >= 0) {
      _data[index] = item;
    } else {
      final newId = _data.isEmpty ? 1 : _data.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
      _data.insert(0, item.copyWith(id: newId));
    }
  }

  Future<void> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _data.removeWhere((k) => k.id == id);
  }
}
