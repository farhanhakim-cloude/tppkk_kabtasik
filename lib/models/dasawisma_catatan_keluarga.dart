// lib/models/dasawisma_catatan_keluarga.dart
// Sesuai Sheet "CATATAN KELUARGA" 19 kolom + header wilayah untuk hierarki Dasawisma -> RT/RW/Dusun/Desa/Kec/Kab (Opsi A)

class DasawismaCatatanKeluargaItem {
  final String namaAnggota;
  final String statusPerkawinan;
  final String jenisKelamin; // "L" / "P"
  final String tempatLahir;
  final String tanggalLahirUmur;
  final String agama;
  final String pendidikan;
  final String pekerjaan;
  final String berkebutuhanKhusus;
  final bool penghayatanPancasila;
  final bool gotongRoyong;
  final bool pendidikanKeterampilan;
  final bool pengembanganKoperasi;
  final bool pangan;
  final bool sandang;
  final bool kesehatan;
  final bool perencanaanSehat;
  final String keterangan;

  DasawismaCatatanKeluargaItem({
    required this.namaAnggota,
    this.statusPerkawinan = 'Kawin',
    this.jenisKelamin = 'P',
    this.tempatLahir = '',
    this.tanggalLahirUmur = '',
    this.agama = 'Islam',
    this.pendidikan = '',
    this.pekerjaan = '',
    this.berkebutuhanKhusus = 'Tidak',
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

  DasawismaCatatanKeluargaItem copyWith({
    String? namaAnggota,
    String? statusPerkawinan,
    String? jenisKelamin,
    String? tempatLahir,
    String? tanggalLahirUmur,
    String? agama,
    String? pendidikan,
    String? pekerjaan,
    String? berkebutuhanKhusus,
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
    return DasawismaCatatanKeluargaItem(
      namaAnggota: namaAnggota ?? this.namaAnggota,
      statusPerkawinan: statusPerkawinan ?? this.statusPerkawinan,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      tanggalLahirUmur: tanggalLahirUmur ?? this.tanggalLahirUmur,
      agama: agama ?? this.agama,
      pendidikan: pendidikan ?? this.pendidikan,
      pekerjaan: pekerjaan ?? this.pekerjaan,
      berkebutuhanKhusus: berkebutuhanKhusus ?? this.berkebutuhanKhusus,
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

  int get jumlahKegiatanDiikuti {
    int c = 0;
    if (penghayatanPancasila) c++;
    if (gotongRoyong) c++;
    if (pendidikanKeterampilan) c++;
    if (pengembanganKoperasi) c++;
    if (pangan) c++;
    if (sandang) c++;
    if (kesehatan) c++;
    if (perencanaanSehat) c++;
    return c;
  }
}

class DasawismaCatatanKeluarga {
  final String id;
  final String tahun;
  final String dasaWisma;
  final String rt;
  final String rw;
  final String dusun;
  final String desa;
  final String kecamatan;
  final String kabupaten;
  final String catatanDari;
  final String kriteriaRumah;
  final String sumberAir;
  final String tempatSampah;
  final List<DasawismaCatatanKeluargaItem> items;
  final String keteranganUmum;

  DasawismaCatatanKeluarga({
    required this.id,
    required this.tahun,
    required this.dasaWisma,
    required this.rt,
    required this.rw,
    this.dusun = '',
    required this.desa,
    required this.kecamatan,
    this.kabupaten = 'Kabupaten Tasikmalaya',
    this.catatanDari = '',
    this.kriteriaRumah = 'Sehat',
    this.sumberAir = 'Sumur',
    this.tempatSampah = 'Ada',
    required this.items,
    this.keteranganUmum = '',
  });

  DasawismaCatatanKeluarga copyWith({
    String? id,
    String? tahun,
    String? dasaWisma,
    String? rt,
    String? rw,
    String? dusun,
    String? desa,
    String? kecamatan,
    String? kabupaten,
    String? catatanDari,
    String? kriteriaRumah,
    String? sumberAir,
    String? tempatSampah,
    List<DasawismaCatatanKeluargaItem>? items,
    String? keteranganUmum,
  }) {
    return DasawismaCatatanKeluarga(
      id: id ?? this.id,
      tahun: tahun ?? this.tahun,
      dasaWisma: dasaWisma ?? this.dasaWisma,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      dusun: dusun ?? this.dusun,
      desa: desa ?? this.desa,
      kecamatan: kecamatan ?? this.kecamatan,
      kabupaten: kabupaten ?? this.kabupaten,
      catatanDari: catatanDari ?? this.catatanDari,
      kriteriaRumah: kriteriaRumah ?? this.kriteriaRumah,
      sumberAir: sumberAir ?? this.sumberAir,
      tempatSampah: tempatSampah ?? this.tempatSampah,
      items: items ?? this.items,
      keteranganUmum: keteranganUmum ?? this.keteranganUmum,
    );
  }

  int get totalAnggota => items.length;
  int get totalLaki => items.where((e) => e.jenisKelamin == 'L').length;
  int get totalPerempuan => items.where((e) => e.jenisKelamin == 'P').length;
}
