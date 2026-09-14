// lib/models/catatan_keluarga.dart

/// Model untuk satu baris anggota keluarga dalam Catatan Keluarga
class AnggotaCatatanKeluarga {
  final int id;
  final String nama;
  final String statusPerkawinan; // Kawin, Belum Kawin, Janda, Duda
  final String jenisKelamin; // L / P
  final String tempatLahir;
  final String tanggalLahir; // dd-MM-yyyy
  final int umur;
  final String agama;
  final String pendidikan;
  final String pekerjaan;
  final bool berkebutuhanKhusus;
  final String keteranganBK; // jenis berkebutuhan khusus jika ada

  // Kegiatan PKK yang diikuti (centang/tidak)
  final bool penghayatanPancasila;
  final bool gotongRoyong;
  final bool pendidikanKeterampilan;
  final bool pengembanganKoperasi;
  final bool pangan;
  final bool sandang;
  final bool kesehatan;
  final bool perencanaanSehat;

  final String keterangan;

  const AnggotaCatatanKeluarga({
    required this.id,
    required this.nama,
    this.statusPerkawinan = 'Kawin',
    this.jenisKelamin = 'L',
    this.tempatLahir = '',
    this.tanggalLahir = '',
    this.umur = 0,
    this.agama = 'Islam',
    this.pendidikan = '',
    this.pekerjaan = '',
    this.berkebutuhanKhusus = false,
    this.keteranganBK = '',
    this.penghayatanPancasila = false,
    this.gotongRoyong = false,
    this.pendidikanKeterampilan = false,
    this.pengembanganKoperasi = false,
    this.pangan = false,
    this.sandang = false,
    this.kesehatan = false,
    this.perencanaanSehat = false,
    this.keterangan = '',
  });

  AnggotaCatatanKeluarga copyWith({
    int? id,
    String? nama,
    String? statusPerkawinan,
    String? jenisKelamin,
    String? tempatLahir,
    String? tanggalLahir,
    int? umur,
    String? agama,
    String? pendidikan,
    String? pekerjaan,
    bool? berkebutuhanKhusus,
    String? keteranganBK,
    bool? penghayatanPancasila,
    bool? gotongRoyong,
    bool? pendidikanKeterampilan,
    bool? pengembanganKoperasi,
    bool? pangan,
    bool? sandang,
    bool? kesehatan,
    bool? perencanaanSehat,
    String? keterangan,
  }) {
    return AnggotaCatatanKeluarga(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      statusPerkawinan: statusPerkawinan ?? this.statusPerkawinan,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      umur: umur ?? this.umur,
      agama: agama ?? this.agama,
      pendidikan: pendidikan ?? this.pendidikan,
      pekerjaan: pekerjaan ?? this.pekerjaan,
      berkebutuhanKhusus: berkebutuhanKhusus ?? this.berkebutuhanKhusus,
      keteranganBK: keteranganBK ?? this.keteranganBK,
      penghayatanPancasila: penghayatanPancasila ?? this.penghayatanPancasila,
      gotongRoyong: gotongRoyong ?? this.gotongRoyong,
      pendidikanKeterampilan: pendidikanKeterampilan ?? this.pendidikanKeterampilan,
      pengembanganKoperasi: pengembanganKoperasi ?? this.pengembanganKoperasi,
      pangan: pangan ?? this.pangan,
      sandang: sandang ?? this.sandang,
      kesehatan: kesehatan ?? this.kesehatan,
      perencanaanSehat: perencanaanSehat ?? this.perencanaanSehat,
      keterangan: keterangan ?? this.keterangan,
    );
  }
}

/// Model untuk satu Catatan Keluarga (1 KK / 1 buku catatan)
class CatatanKeluarga {
  final int id;
  final String namaKepalaKeluarga;
  final String dasaWisma;
  final String tahun;

  // Kanan atas: kondisi rumah
  final String kriteriaRumah; // 'Layak Huni' / 'Tidak Layak Huni'
  final String jambanKeluarga; // 'Ada' / 'Tidak'
  final int jumlahJamban;
  final String sumberAir; // 'PDAM' / 'Sumur' / 'Lainnya'
  final String tempatSampah; // 'Ada' / 'Tidak'

  // Daftar anggota keluarga (baris tabel)
  final List<AnggotaCatatanKeluarga> anggota;

  final DateTime tanggalInput;

  const CatatanKeluarga({
    required this.id,
    required this.namaKepalaKeluarga,
    this.dasaWisma = '',
    this.tahun = '',
    this.kriteriaRumah = 'Layak Huni',
    this.jambanKeluarga = 'Ada',
    this.jumlahJamban = 1,
    this.sumberAir = 'Sumur',
    this.tempatSampah = 'Ada',
    this.anggota = const [],
    required this.tanggalInput,
  });

  CatatanKeluarga copyWith({
    int? id,
    String? namaKepalaKeluarga,
    String? dasaWisma,
    String? tahun,
    String? kriteriaRumah,
    String? jambanKeluarga,
    int? jumlahJamban,
    String? sumberAir,
    String? tempatSampah,
    List<AnggotaCatatanKeluarga>? anggota,
    DateTime? tanggalInput,
  }) {
    return CatatanKeluarga(
      id: id ?? this.id,
      namaKepalaKeluarga: namaKepalaKeluarga ?? this.namaKepalaKeluarga,
      dasaWisma: dasaWisma ?? this.dasaWisma,
      tahun: tahun ?? this.tahun,
      kriteriaRumah: kriteriaRumah ?? this.kriteriaRumah,
      jambanKeluarga: jambanKeluarga ?? this.jambanKeluarga,
      jumlahJamban: jumlahJamban ?? this.jumlahJamban,
      sumberAir: sumberAir ?? this.sumberAir,
      tempatSampah: tempatSampah ?? this.tempatSampah,
      anggota: anggota ?? this.anggota,
      tanggalInput: tanggalInput ?? this.tanggalInput,
    );
  }
}
