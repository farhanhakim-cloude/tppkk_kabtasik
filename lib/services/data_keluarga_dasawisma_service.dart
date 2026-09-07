import '../models/data_keluarga_dasawisma.dart';

class DataKeluargaDasawismaService {
  static final DataKeluargaDasawismaService _instance = DataKeluargaDasawismaService._internal();
  factory DataKeluargaDasawismaService() => _instance;
  DataKeluargaDasawismaService._internal();

  final List<DataKeluargaDasawisma> _items = [
    DataKeluargaDasawisma(
      id: 1,
      dasaWisma: 'Mawar 01',
      rt: '01',
      rw: '05',
      desa: 'Singaparna',
      kecamatan: 'Singaparna',
      namaKepalaRumahTangga: 'Ahmad Fauzi',
      jumlahLakiLaki: 2,
      jumlahPerempuan: 2,
      jumlahKk: 1,
      jumlahBalita: 1,
      jumlahAnak: 1,
      jumlahPus: 1,
      jumlahWus: 1,
      jumlahTigaButa: 0,
      jumlahIbuHamil: 0,
      jumlahIbuMenyusui: 1,
      jumlahLansia: 0,
      makananPokok: 'Beras',
      mempunyaiMck: true,
      jumlahMckSepticTank: 1,
      sumberAir: 'Sumur',
      memilikiTempatSampah: true,
      mempunyaiSpal: true,
      kriteriaRumah: 'Sehat',
      aktifitasUp2k: true,
      jenisUsahaUp2k: 'Kerajinan Tangan',
      aktifitasKesehatanLingkungan: true,
      anggotaList: [
        AnggotaKeluargaItem(
          noReg: '001',
          nama: 'Ahmad Fauzi',
          statusDalamKeluarga: 'Suami',
          statusPerkawinan: 'Kawin',
          jenisKelamin: 'L',
          tanggalLahirUmur: '12-05-1985 / 41 th',
          pendidikan: 'SMA/SMK/Sederajat',
          pekerjaan: 'Wiraswasta',
        ),
        AnggotaKeluargaItem(
          noReg: '002',
          nama: 'Siti Aminah',
          statusDalamKeluarga: 'Istri',
          statusPerkawinan: 'Kawin',
          jenisKelamin: 'P',
          tanggalLahirUmur: '20-08-1989 / 37 th',
          pendidikan: 'Diploma',
          pekerjaan: 'Ibu Rumah Tangga',
        ),
        AnggotaKeluargaItem(
          noReg: '003',
          nama: 'Rizky Fauzi',
          statusDalamKeluarga: 'Anak',
          statusPerkawinan: 'Tidak Kawin',
          jenisKelamin: 'L',
          tanggalLahirUmur: '10-02-2015 / 11 th',
          pendidikan: 'SD/MI',
          pekerjaan: 'Pelajar',
        ),
        AnggotaKeluargaItem(
          noReg: '004',
          nama: 'Aisyah Fauzi',
          statusDalamKeluarga: 'Anak',
          statusPerkawinan: 'Tidak Kawin',
          jenisKelamin: 'P',
          tanggalLahirUmur: '05-09-2023 / 3 th',
          pendidikan: 'Tidak Tamat SD',
          pekerjaan: 'Belum Bekerja',
        ),
      ],
    ),
  ];

  Future<List<DataKeluargaDasawisma>> getAll({String query = ''}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (query.trim().isEmpty) return List.from(_items);
    final q = query.toLowerCase();
    return _items.where((e) {
      return e.namaKepalaRumahTangga.toLowerCase().contains(q) ||
          e.dasaWisma.toLowerCase().contains(q) ||
          e.rt.contains(q) ||
          e.rw.contains(q);
    }).toList();
  }

  Future<void> save(DataKeluargaDasawisma item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index >= 0) {
      _items[index] = item;
    } else {
      final newId = _items.isEmpty ? 1 : (_items.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1);
      _items.insert(0, item.copyWith(id: newId));
    }
  }

  Future<void> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _items.removeWhere((e) => e.id == id);
  }
}
