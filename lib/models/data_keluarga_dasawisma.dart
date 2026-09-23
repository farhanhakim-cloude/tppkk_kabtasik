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

  factory AnggotaKeluargaItem.fromJson(Map<String, dynamic> j) =>
      AnggotaKeluargaItem(
        noReg: j['noReg']?.toString() ?? '',
        nama: j['nama']?.toString() ?? '',
        statusDalamKeluarga: j['statusDalamKeluarga']?.toString() ?? '',
        statusPerkawinan: j['statusPerkawinan']?.toString() ?? '',
        jenisKelamin: j['jenisKelamin']?.toString() ?? 'L',
        tanggalLahirUmur: j['tanggalLahirUmur']?.toString() ?? '',
        pendidikan: j['pendidikan']?.toString() ?? '',
        pekerjaan: j['pekerjaan']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
    'noReg': noReg,
    'nama': nama,
    'statusDalamKeluarga': statusDalamKeluarga,
    'statusPerkawinan': statusPerkawinan,
    'jenisKelamin': jenisKelamin,
    'tanggalLahirUmur': tanggalLahirUmur,
    'pendidikan': pendidikan,
    'pekerjaan': pekerjaan,
  };
}

class DataKeluargaDasawisma {
  final int id;
  final String dasaWisma;
  final String rt;
  final String rw;
  final String dusun;
  final String desa;
  final String kecamatan;
  final String kabupaten;
  final String provinsi;
  final String namaKepalaRumahTangga;
  final String nomorKk;
  final String nikKepalaKeluarga;
  final String alamat;
  final int jumlahLakiLaki;
  final int jumlahPerempuan;

  // 1-2 Rekapitulasi
  final int jumlahKk;
  final int jumlahBalita;
  final int jumlahBalitaL;
  final int jumlahBalitaP;
  final int jumlahAnak;
  final int jumlahPus; // Pasangan Usia Subur
  final int jumlahWus; // Wanita Usia Subur
  final int jumlahTigaButa;
  final int jumlahTigaButaL;
  final int jumlahTigaButaP;
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
  final bool memilikiStikerP4k;
  final String kriteriaRumah; // Sehat / Kurang Sehat
  final bool aktifitasUp2k;
  final String jenisUsahaUp2k;
  final bool aktifitasKesehatanLingkungan;
  final bool aktifitasTanahPekarangan;
  final bool aktifitasIndustriRumahTangga;

  DataKeluargaDasawisma({
    required this.id,
    required this.dasaWisma,
    required this.rt,
    required this.rw,
    this.dusun = '',
    required this.desa,
    required this.kecamatan,
    this.kabupaten = 'Kabupaten Tasikmalaya',
    this.provinsi = 'Provinsi Jawa Barat',
    required this.namaKepalaRumahTangga,
    this.nomorKk = '',
    this.nikKepalaKeluarga = '',
    this.alamat = '',
    this.jumlahLakiLaki = 2,
    this.jumlahPerempuan = 2,
    this.jumlahKk = 1,
    this.jumlahBalita = 1,
    this.jumlahBalitaL = 0,
    this.jumlahBalitaP = 0,
    this.jumlahAnak = 1,
    this.jumlahPus = 1,
    this.jumlahWus = 1,
    this.jumlahTigaButa = 0,
    this.jumlahTigaButaL = 0,
    this.jumlahTigaButaP = 0,
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
    this.memilikiStikerP4k = false,
    this.kriteriaRumah = 'Sehat',
    this.aktifitasUp2k = false,
    this.jenisUsahaUp2k = '',
    this.aktifitasKesehatanLingkungan = true,
    this.aktifitasTanahPekarangan = false,
    this.aktifitasIndustriRumahTangga = false,
  });

  DataKeluargaDasawisma copyWith({
    int? id,
    String? dasaWisma,
    String? rt,
    String? rw,
    String? dusun,
    String? desa,
    String? kecamatan,
    String? kabupaten,
    String? provinsi,
    String? namaKepalaRumahTangga,
    String? nomorKk,
    String? nikKepalaKeluarga,
    String? alamat,
    int? jumlahLakiLaki,
    int? jumlahPerempuan,
    int? jumlahKk,
    int? jumlahBalita,
    int? jumlahBalitaL,
    int? jumlahBalitaP,
    int? jumlahAnak,
    int? jumlahPus,
    int? jumlahWus,
    int? jumlahTigaButa,
    int? jumlahTigaButaL,
    int? jumlahTigaButaP,
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
    bool? memilikiStikerP4k,
    String? kriteriaRumah,
    bool? aktifitasUp2k,
    String? jenisUsahaUp2k,
    bool? aktifitasKesehatanLingkungan,
    bool? aktifitasTanahPekarangan,
    bool? aktifitasIndustriRumahTangga,
  }) {
    return DataKeluargaDasawisma(
      id: id ?? this.id,
      dasaWisma: dasaWisma ?? this.dasaWisma,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      dusun: dusun ?? this.dusun,
      desa: desa ?? this.desa,
      kecamatan: kecamatan ?? this.kecamatan,
      kabupaten: kabupaten ?? this.kabupaten,
      provinsi: provinsi ?? this.provinsi,
      namaKepalaRumahTangga:
          namaKepalaRumahTangga ?? this.namaKepalaRumahTangga,
      nomorKk: nomorKk ?? this.nomorKk,
      nikKepalaKeluarga: nikKepalaKeluarga ?? this.nikKepalaKeluarga,
      alamat: alamat ?? this.alamat,
      jumlahLakiLaki: jumlahLakiLaki ?? this.jumlahLakiLaki,
      jumlahPerempuan: jumlahPerempuan ?? this.jumlahPerempuan,
      jumlahKk: jumlahKk ?? this.jumlahKk,
      jumlahBalita: jumlahBalita ?? this.jumlahBalita,
      jumlahBalitaL: jumlahBalitaL ?? this.jumlahBalitaL,
      jumlahBalitaP: jumlahBalitaP ?? this.jumlahBalitaP,
      jumlahAnak: jumlahAnak ?? this.jumlahAnak,
      jumlahPus: jumlahPus ?? this.jumlahPus,
      jumlahWus: jumlahWus ?? this.jumlahWus,
      jumlahTigaButa: jumlahTigaButa ?? this.jumlahTigaButa,
      jumlahTigaButaL: jumlahTigaButaL ?? this.jumlahTigaButaL,
      jumlahTigaButaP: jumlahTigaButaP ?? this.jumlahTigaButaP,
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
      memilikiStikerP4k: memilikiStikerP4k ?? this.memilikiStikerP4k,
      kriteriaRumah: kriteriaRumah ?? this.kriteriaRumah,
      aktifitasUp2k: aktifitasUp2k ?? this.aktifitasUp2k,
      jenisUsahaUp2k: jenisUsahaUp2k ?? this.jenisUsahaUp2k,
      aktifitasKesehatanLingkungan:
          aktifitasKesehatanLingkungan ?? this.aktifitasKesehatanLingkungan,
      aktifitasTanahPekarangan:
          aktifitasTanahPekarangan ?? this.aktifitasTanahPekarangan,
      aktifitasIndustriRumahTangga:
          aktifitasIndustriRumahTangga ?? this.aktifitasIndustriRumahTangga,
    );
  }

  static int _p(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  factory DataKeluargaDasawisma.fromJson(Map<String, dynamic> j) =>
      DataKeluargaDasawisma(
        id: _p(j['id']),
        dasaWisma: j['dasaWisma']?.toString() ?? '',
        rt: j['rt']?.toString() ?? '',
        rw: j['rw']?.toString() ?? '',
        desa: j['desa']?.toString() ?? '',
        kecamatan: j['kecamatan']?.toString() ?? '',
        kabupaten: j['kabupaten']?.toString() ?? 'Kabupaten Tasikmalaya',
        provinsi: j['provinsi']?.toString() ?? 'Provinsi Jawa Barat',
        namaKepalaRumahTangga: j['namaKepalaRumahTangga']?.toString() ?? '',
        jumlahLakiLaki: _p(j['jumlahLakiLaki']),
        jumlahPerempuan: _p(j['jumlahPerempuan']),
        jumlahKk: _p(j['jumlahKk']),
        jumlahBalita: _p(j['jumlahBalita']),
        jumlahAnak: _p(j['jumlahAnak']),
        jumlahPus: _p(j['jumlahPus']),
        jumlahWus: _p(j['jumlahWus']),
        jumlahTigaButa: _p(j['jumlahTigaButa']),
        jumlahIbuHamil: _p(j['jumlahIbuHamil']),
        jumlahIbuMenyusui: _p(j['jumlahIbuMenyusui']),
        jumlahLansia: _p(j['jumlahLansia']),
        anggotaList: j['anggotaList'] != null
            ? (j['anggotaList'] as List)
                  .map(
                    (e) =>
                        AnggotaKeluargaItem.fromJson(e as Map<String, dynamic>),
                  )
                  .toList()
            : [],
        makananPokok: j['makananPokok']?.toString() ?? 'Beras',
        mempunyaiMck: j['mempunyaiMck'] == true || j['mempunyaiMck'] == 1,
        jumlahMckSepticTank: _p(j['jumlahMckSepticTank']),
        sumberAir: j['sumberAir']?.toString() ?? 'Sumur',
        memilikiTempatSampah:
            j['memilikiTempatSampah'] == true || j['memilikiTempatSampah'] == 1,
        mempunyaiSpal: j['mempunyaiSpal'] == true || j['mempunyaiSpal'] == 1,
        kriteriaRumah: j['kriteriaRumah']?.toString() ?? 'Sehat',
        aktifitasUp2k: j['aktifitasUp2k'] == true || j['aktifitasUp2k'] == 1,
        jenisUsahaUp2k: j['jenisUsahaUp2k']?.toString() ?? '',
        aktifitasKesehatanLingkungan:
            j['aktifitasKesehatanLingkungan'] == true ||
            j['aktifitasKesehatanLingkungan'] == 1,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'dasaWisma': dasaWisma,
    'rt': rt,
    'rw': rw,
    'desa': desa,
    'kecamatan': kecamatan,
    'kabupaten': kabupaten,
    'provinsi': provinsi,
    'namaKepalaRumahTangga': namaKepalaRumahTangga,
    'jumlahLakiLaki': jumlahLakiLaki,
    'jumlahPerempuan': jumlahPerempuan,
    'jumlahKk': jumlahKk,
    'jumlahBalita': jumlahBalita,
    'jumlahAnak': jumlahAnak,
    'jumlahPus': jumlahPus,
    'jumlahWus': jumlahWus,
    'jumlahTigaButa': jumlahTigaButa,
    'jumlahIbuHamil': jumlahIbuHamil,
    'jumlahIbuMenyusui': jumlahIbuMenyusui,
    'jumlahLansia': jumlahLansia,
    'anggotaList': anggotaList.map((e) => e.toJson()).toList(),
    'makananPokok': makananPokok,
    'mempunyaiMck': mempunyaiMck,
    'jumlahMckSepticTank': jumlahMckSepticTank,
    'sumberAir': sumberAir,
    'memilikiTempatSampah': memilikiTempatSampah,
    'mempunyaiSpal': mempunyaiSpal,
    'kriteriaRumah': kriteriaRumah,
    'aktifitasUp2k': aktifitasUp2k,
    'jenisUsahaUp2k': jenisUsahaUp2k,
    'aktifitasKesehatanLingkungan': aktifitasKesehatanLingkungan,
  };
}
