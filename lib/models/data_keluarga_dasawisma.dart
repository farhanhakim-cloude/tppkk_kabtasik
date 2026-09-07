class AnggotaKeluargaItem {
  final String noReg;
  final String nama;
  final String statusDalamKeluarga; // Suami, Istri, Anak, Menantu, Keluarga dll
  final String statusPerkawinan; // Kawin, Tidak Kawin
  final String jenisKelamin; // "L", "P"
  final String tanggalLahirUmur;
  final String pendidikan;
  final String pekerjaan;

  AnggotaKeluargaItem({
    required this.noReg,
    required this.nama,
    required this.statusDalamKeluarga,
    required this.statusPerkawinan,
    required this.jenisKelamin,
    required this.tanggalLahirUmur,
    required this.pendidikan,
    required this.pekerjaan,
  });

  AnggotaKeluargaItem copyWith({
    String? noReg,
    String? nama,
    String? statusDalamKeluarga,
    String? statusPerkawinan,
    String? jenisKelamin,
    String? tanggalLahirUmur,
    String? pendidikan,
    String? pekerjaan,
  }) {
    return AnggotaKeluargaItem(
      noReg: noReg ?? this.noReg,
      nama: nama ?? this.nama,
      statusDalamKeluarga: statusDalamKeluarga ?? this.statusDalamKeluarga,
      statusPerkawinan: statusPerkawinan ?? this.statusPerkawinan,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tanggalLahirUmur: tanggalLahirUmur ?? this.tanggalLahirUmur,
      pendidikan: pendidikan ?? this.pendidikan,
      pekerjaan: pekerjaan ?? this.pekerjaan,
    );
  }
}

class DataKeluargaDasawisma {
  final int id;
  final String dasaWisma;
  final String rt;
  final String rw;
  final String desa;
  final String kecamatan;
  final String kabupaten;
  final String provinsi;
  final String namaKepalaRumahTangga;
  final int jumlahLakiLaki;
  final int jumlahPerempuan;

  // 1-2 Rekapitulasi
  final int jumlahKk;
  final int jumlahBalita;
  final int jumlahAnak;
  final int jumlahPus; // Pasangan Usia Subur
  final int jumlahWus; // Wanita Usia Subur
  final int jumlahTigaButa;
  final int jumlahIbuHamil;
  final int jumlahIbuMenyusui;
  final int jumlahLansia;

  // Tabel Anggota
  final List<AnggotaKeluargaItem> anggotaList;

  // 3-10 Fasilitas & Lingkungan
  final String makananPokok; // Beras / Non Beras
  final bool mempunyaiMck;
  final int jumlahMckSepticTank;
  final String sumberAir; // PDAM / Sumur / Sungai / Lainnya
  final bool memilikiTempatSampah;
  final bool mempunyaiSpal;
  final String kriteriaRumah; // Sehat / Kurang Sehat
  final bool aktifitasUp2k;
  final String jenisUsahaUp2k;
  final bool aktifitasKesehatanLingkungan;

  DataKeluargaDasawisma({
    required this.id,
    required this.dasaWisma,
    required this.rt,
    required this.rw,
    required this.desa,
    required this.kecamatan,
    this.kabupaten = 'Kabupaten Tasikmalaya',
    this.provinsi = 'Provinsi Jawa Barat',
    required this.namaKepalaRumahTangga,
    this.jumlahLakiLaki = 2,
    this.jumlahPerempuan = 2,
    this.jumlahKk = 1,
    this.jumlahBalita = 1,
    this.jumlahAnak = 1,
    this.jumlahPus = 1,
    this.jumlahWus = 1,
    this.jumlahTigaButa = 0,
    this.jumlahIbuHamil = 0,
    this.jumlahIbuMenyusui = 1,
    this.jumlahLansia = 0,
    this.anggotaList = const [],
    this.makananPokok = 'Beras',
    this.mempunyaiMck = true,
    this.jumlahMckSepticTank = 1,
    this.sumberAir = 'Sumur',
    this.memilikiTempatSampah = true,
    this.mempunyaiSpal = true,
    this.kriteriaRumah = 'Sehat',
    this.aktifitasUp2k = false,
    this.jenisUsahaUp2k = '',
    this.aktifitasKesehatanLingkungan = true,
  });

  DataKeluargaDasawisma copyWith({
    int? id,
    String? dasaWisma,
    String? rt,
    String? rw,
    String? desa,
    String? kecamatan,
    String? kabupaten,
    String? provinsi,
    String? namaKepalaRumahTangga,
    int? jumlahLakiLaki,
    int? jumlahPerempuan,
    int? jumlahKk,
    int? jumlahBalita,
    int? jumlahAnak,
    int? jumlahPus,
    int? jumlahWus,
    int? jumlahTigaButa,
    int? jumlahIbuHamil,
    int? jumlahIbuMenyusui,
    int? jumlahLansia,
    List<AnggotaKeluargaItem>? anggotaList,
    String? makananPokok,
    bool? mempunyaiMck,
    int? jumlahMckSepticTank,
    String? sumberAir,
    bool? memilikiTempatSampah,
    bool? mempunyaiSpal,
    String? kriteriaRumah,
    bool? aktifitasUp2k,
    String? jenisUsahaUp2k,
    bool? aktifitasKesehatanLingkungan,
  }) {
    return DataKeluargaDasawisma(
      id: id ?? this.id,
      dasaWisma: dasaWisma ?? this.dasaWisma,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      desa: desa ?? this.desa,
      kecamatan: kecamatan ?? this.kecamatan,
      kabupaten: kabupaten ?? this.kabupaten,
      provinsi: provinsi ?? this.provinsi,
      namaKepalaRumahTangga: namaKepalaRumahTangga ?? this.namaKepalaRumahTangga,
      jumlahLakiLaki: jumlahLakiLaki ?? this.jumlahLakiLaki,
      jumlahPerempuan: jumlahPerempuan ?? this.jumlahPerempuan,
      jumlahKk: jumlahKk ?? this.jumlahKk,
      jumlahBalita: jumlahBalita ?? this.jumlahBalita,
      jumlahAnak: jumlahAnak ?? this.jumlahAnak,
      jumlahPus: jumlahPus ?? this.jumlahPus,
      jumlahWus: jumlahWus ?? this.jumlahWus,
      jumlahTigaButa: jumlahTigaButa ?? this.jumlahTigaButa,
      jumlahIbuHamil: jumlahIbuHamil ?? this.jumlahIbuHamil,
      jumlahIbuMenyusui: jumlahIbuMenyusui ?? this.jumlahIbuMenyusui,
      jumlahLansia: jumlahLansia ?? this.jumlahLansia,
      anggotaList: anggotaList ?? this.anggotaList,
      makananPokok: makananPokok ?? this.makananPokok,
      mempunyaiMck: mempunyaiMck ?? this.mempunyaiMck,
      jumlahMckSepticTank: jumlahMckSepticTank ?? this.jumlahMckSepticTank,
      sumberAir: sumberAir ?? this.sumberAir,
      memilikiTempatSampah: memilikiTempatSampah ?? this.memilikiTempatSampah,
      mempunyaiSpal: mempunyaiSpal ?? this.mempunyaiSpal,
      kriteriaRumah: kriteriaRumah ?? this.kriteriaRumah,
      aktifitasUp2k: aktifitasUp2k ?? this.aktifitasUp2k,
      jenisUsahaUp2k: jenisUsahaUp2k ?? this.jenisUsahaUp2k,
      aktifitasKesehatanLingkungan: aktifitasKesehatanLingkungan ?? this.aktifitasKesehatanLingkungan,
    );
  }
}
