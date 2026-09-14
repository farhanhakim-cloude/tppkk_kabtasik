// lib/services/catatan_keluarga_baru_service.dart
import '../models/catatan_keluarga.dart';

class CatatanKeluargaBaruService {
  static final CatatanKeluargaBaruService _instance = CatatanKeluargaBaruService._internal();
  factory CatatanKeluargaBaruService() => _instance;
  CatatanKeluargaBaruService._internal();

  final List<CatatanKeluarga> _data = [
    CatatanKeluarga(
      id: 1,
      namaKepalaKeluarga: 'Ahmad Fauzi',
      dasaWisma: 'Mawar 01',
      tahun: '2025',
      kriteriaRumah: 'Layak Huni',
      jambanKeluarga: 'Ada',
      jumlahJamban: 1,
      sumberAir: 'PDAM',
      tempatSampah: 'Ada',
      tanggalInput: DateTime(2025, 1, 10),
      anggota: [
        AnggotaCatatanKeluarga(
          id: 1,
          nama: 'Ahmad Fauzi',
          statusPerkawinan: 'Kawin',
          jenisKelamin: 'L',
          tempatLahir: 'Tasikmalaya',
          tanggalLahir: '15-06-1982',
          umur: 43,
          agama: 'Islam',
          pendidikan: 'S1',
          pekerjaan: 'Wiraswasta',
          berkebutuhanKhusus: false,
          penghayatanPancasila: true,
          gotongRoyong: true,
          pendidikanKeterampilan: false,
          pengembanganKoperasi: true,
          pangan: true,
          sandang: false,
          kesehatan: true,
          perencanaanSehat: true,
        ),
        AnggotaCatatanKeluarga(
          id: 2,
          nama: 'Siti Nurhaliza',
          statusPerkawinan: 'Kawin',
          jenisKelamin: 'P',
          tempatLahir: 'Ciamis',
          tanggalLahir: '20-09-1985',
          umur: 40,
          agama: 'Islam',
          pendidikan: 'SMA/SMK',
          pekerjaan: 'Ibu Rumah Tangga',
          berkebutuhanKhusus: false,
          penghayatanPancasila: true,
          gotongRoyong: true,
          pendidikanKeterampilan: true,
          pengembanganKoperasi: true,
          pangan: true,
          sandang: true,
          kesehatan: true,
          perencanaanSehat: true,
        ),
        AnggotaCatatanKeluarga(
          id: 3,
          nama: 'Rizky Fauzi',
          statusPerkawinan: 'Belum Kawin',
          jenisKelamin: 'L',
          tempatLahir: 'Tasikmalaya',
          tanggalLahir: '10-03-2010',
          umur: 15,
          agama: 'Islam',
          pendidikan: 'SMP/Sederajat',
          pekerjaan: 'Pelajar',
          berkebutuhanKhusus: false,
          penghayatanPancasila: true,
          gotongRoyong: false,
          pendidikanKeterampilan: false,
          pengembanganKoperasi: false,
          pangan: false,
          sandang: false,
          kesehatan: true,
          perencanaanSehat: false,
        ),
      ],
    ),
    CatatanKeluarga(
      id: 2,
      namaKepalaKeluarga: 'Budi Santoso',
      dasaWisma: 'Mawar 01',
      tahun: '2025',
      kriteriaRumah: 'Layak Huni',
      jambanKeluarga: 'Ada',
      jumlahJamban: 1,
      sumberAir: 'Sumur',
      tempatSampah: 'Ada',
      tanggalInput: DateTime(2025, 1, 12),
      anggota: [
        AnggotaCatatanKeluarga(
          id: 1,
          nama: 'Budi Santoso',
          statusPerkawinan: 'Kawin',
          jenisKelamin: 'L',
          tempatLahir: 'Garut',
          tanggalLahir: '05-04-1979',
          umur: 46,
          agama: 'Islam',
          pendidikan: 'SMA/SMK',
          pekerjaan: 'PNS',
          berkebutuhanKhusus: false,
          penghayatanPancasila: true,
          gotongRoyong: true,
          pendidikanKeterampilan: true,
          pengembanganKoperasi: false,
          pangan: true,
          sandang: false,
          kesehatan: true,
          perencanaanSehat: true,
        ),
        AnggotaCatatanKeluarga(
          id: 2,
          nama: 'Dewi Rahayu',
          statusPerkawinan: 'Kawin',
          jenisKelamin: 'P',
          tempatLahir: 'Tasikmalaya',
          tanggalLahir: '17-11-1982',
          umur: 42,
          agama: 'Islam',
          pendidikan: 'D3',
          pekerjaan: 'Guru',
          berkebutuhanKhusus: false,
          penghayatanPancasila: true,
          gotongRoyong: true,
          pendidikanKeterampilan: true,
          pengembanganKoperasi: true,
          pangan: true,
          sandang: true,
          kesehatan: true,
          perencanaanSehat: true,
        ),
      ],
    ),
    CatatanKeluarga(
      id: 3,
      namaKepalaKeluarga: 'Cecep Hidayat',
      dasaWisma: 'Melati 02',
      tahun: '2025',
      kriteriaRumah: 'Tidak Layak Huni',
      jambanKeluarga: 'Tidak',
      jumlahJamban: 0,
      sumberAir: 'Sumur',
      tempatSampah: 'Tidak',
      tanggalInput: DateTime(2025, 1, 15),
      anggota: [
        AnggotaCatatanKeluarga(
          id: 1,
          nama: 'Cecep Hidayat',
          statusPerkawinan: 'Kawin',
          jenisKelamin: 'L',
          tempatLahir: 'Tasikmalaya',
          tanggalLahir: '12-08-1975',
          umur: 49,
          agama: 'Islam',
          pendidikan: 'SD/MI',
          pekerjaan: 'Petani',
          berkebutuhanKhusus: false,
          penghayatanPancasila: true,
          gotongRoyong: true,
          pendidikanKeterampilan: false,
          pengembanganKoperasi: false,
          pangan: true,
          sandang: false,
          kesehatan: false,
          perencanaanSehat: false,
        ),
        AnggotaCatatanKeluarga(
          id: 2,
          nama: 'Emi Sumiati',
          statusPerkawinan: 'Kawin',
          jenisKelamin: 'P',
          tempatLahir: 'Tasikmalaya',
          tanggalLahir: '03-02-1978',
          umur: 47,
          agama: 'Islam',
          pendidikan: 'SD/MI',
          pekerjaan: 'Buruh Tani',
          berkebutuhanKhusus: false,
          penghayatanPancasila: true,
          gotongRoyong: false,
          pendidikanKeterampilan: false,
          pengembanganKoperasi: false,
          pangan: true,
          sandang: false,
          kesehatan: true,
          perencanaanSehat: false,
        ),
      ],
    ),
  ];

  Future<List<CatatanKeluarga>> getAll({String? query}) async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (query != null && query.isNotEmpty) {
      return _data
          .where((c) =>
              c.namaKepalaKeluarga.toLowerCase().contains(query.toLowerCase()) ||
              c.dasaWisma.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    return List.from(_data);
  }

  Future<CatatanKeluarga?> getById(int id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _data.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(CatatanKeluarga item) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _data.indexWhere((c) => c.id == item.id);
    if (index >= 0) {
      _data[index] = item;
    } else {
      final newId = _data.isEmpty
          ? 1
          : _data.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;
      _data.insert(0, item.copyWith(id: newId));
    }
  }

  Future<void> delete(int id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _data.removeWhere((c) => c.id == id);
  }
}
