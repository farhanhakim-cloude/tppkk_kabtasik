class Keluarga {
  final int id;
  final String dasaWisma;
  final String namaKepalaRumahTangga;

  // 1-4
  final String noRegistrasi;
  final String noKtpKk;
  final String namaKepalaKeluarga; // Nama Warga / KK
  final String jabatan;

  // 5-8
  final String jenisKelamin; // "Laki-laki", "Perempuan"
  final String tempatLahir;
  final String tanggalLahir;
  final String statusPerkawinan; // "Menikah", "Lajang", "Janda", "Duda"

  // 9-10
  final String statusDalamKeluarga; // "Kepala Rumah Tangga", "Anggota Keluarga"
  final String statusAnggotaDetail;
  final String agama; // "Islam", "Kristen", "Katolik", "Hindu", "Budha", "Konghuchu", "Kepercayaan", "Lain-lain"
  final String agamaLainnya;

  // 11
  final String alamat;
  final String rt;
  final String rw;
  final String desa;
  final String kecamatan;
  final String kabupaten;

  // 12-13
  final String pendidikan; // "Tidak Tamat SD", "SD/MI", "SMP/Sederajat", "SMA/SMK/Sederajat", "Diploma", "S1", "S2", "S3"
  final String pekerjaan; // "Petani", "Pedagang", "Swasta", "Wirausaha", "PNS", "TNI/Polri", "Lainnya"
  final int jumlahAnggota;

  // 14-20
  final bool akseptorKb;
  final String jenisAkseptorKb;
  final bool aktifPosyandu;
  final String frekuensiPosyandu;
  final bool mengikutiBkb;
  final bool memilikiTabungan;
  final bool mengikutiKelompokBelajar;
  final String jenisKelompokBelajar; // "Paket A", "Paket B", "Paket C", "KF"
  final bool mengikutiPaud;
  final bool mengikutiKoperasi;
  final String jenisKoperasi;

  final String? fotoRumahPath;
  final double? latitude;
  final double? longitude;

  Keluarga({
    required this.id,
    this.dasaWisma = 'Mawar 01',
    this.namaKepalaRumahTangga = '',
    this.noRegistrasi = '',
    this.noKtpKk = '',
    required this.namaKepalaKeluarga,
    this.jabatan = 'Anggota',
    this.jenisKelamin = 'Laki-laki',
    this.tempatLahir = 'Tasikmalaya',
    this.tanggalLahir = '12-05-1985',
    this.statusPerkawinan = 'Menikah',
    this.statusDalamKeluarga = 'Kepala Rumah Tangga',
    this.statusAnggotaDetail = '',
    this.agama = 'Islam',
    this.agamaLainnya = '',
    required this.alamat,
    required this.rt,
    required this.rw,
    this.desa = 'Singaparna',
    this.kecamatan = 'Singaparna',
    this.kabupaten = 'Kabupaten Tasikmalaya',
    this.pendidikan = 'SMA/SMK/Sederajat',
    required this.pekerjaan,
    this.jumlahAnggota = 4,
    this.akseptorKb = true,
    this.jenisAkseptorKb = 'Suntik',
    this.aktifPosyandu = true,
    this.frekuensiPosyandu = '1',
    this.mengikutiBkb = false,
    this.memilikiTabungan = true,
    this.mengikutiKelompokBelajar = false,
    this.jenisKelompokBelajar = '',
    this.mengikutiPaud = false,
    this.mengikutiKoperasi = true,
    this.jenisKoperasi = 'Simpan Pinjam',
    this.fotoRumahPath,
    this.latitude,
    this.longitude,
  });

  Keluarga copyWith({
    int? id,
    String? dasaWisma,
    String? namaKepalaRumahTangga,
    String? noRegistrasi,
    String? noKtpKk,
    String? namaKepalaKeluarga,
    String? jabatan,
    String? jenisKelamin,
    String? tempatLahir,
    String? tanggalLahir,
    String? statusPerkawinan,
    String? statusDalamKeluarga,
    String? statusAnggotaDetail,
    String? agama,
    String? agamaLainnya,
    String? alamat,
    String? rt,
    String? rw,
    String? desa,
    String? kecamatan,
    String? kabupaten,
    String? pendidikan,
    String? pekerjaan,
    int? jumlahAnggota,
    bool? akseptorKb,
    String? jenisAkseptorKb,
    bool? aktifPosyandu,
    String? frekuensiPosyandu,
    bool? mengikutiBkb,
    bool? memilikiTabungan,
    bool? mengikutiKelompokBelajar,
    String? jenisKelompokBelajar,
    bool? mengikutiPaud,
    bool? mengikutiKoperasi,
    String? jenisKoperasi,
    String? fotoRumahPath,
    double? latitude,
    double? longitude,
  }) {
    return Keluarga(
      id: id ?? this.id,
      dasaWisma: dasaWisma ?? this.dasaWisma,
      namaKepalaRumahTangga: namaKepalaRumahTangga ?? this.namaKepalaRumahTangga,
      noRegistrasi: noRegistrasi ?? this.noRegistrasi,
      noKtpKk: noKtpKk ?? this.noKtpKk,
      namaKepalaKeluarga: namaKepalaKeluarga ?? this.namaKepalaKeluarga,
      jabatan: jabatan ?? this.jabatan,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      statusPerkawinan: statusPerkawinan ?? this.statusPerkawinan,
      statusDalamKeluarga: statusDalamKeluarga ?? this.statusDalamKeluarga,
      statusAnggotaDetail: statusAnggotaDetail ?? this.statusAnggotaDetail,
      agama: agama ?? this.agama,
      agamaLainnya: agamaLainnya ?? this.agamaLainnya,
      alamat: alamat ?? this.alamat,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      desa: desa ?? this.desa,
      kecamatan: kecamatan ?? this.kecamatan,
      kabupaten: kabupaten ?? this.kabupaten,
      pendidikan: pendidikan ?? this.pendidikan,
      pekerjaan: pekerjaan ?? this.pekerjaan,
      jumlahAnggota: jumlahAnggota ?? this.jumlahAnggota,
      akseptorKb: akseptorKb ?? this.akseptorKb,
      jenisAkseptorKb: jenisAkseptorKb ?? this.jenisAkseptorKb,
      aktifPosyandu: aktifPosyandu ?? this.aktifPosyandu,
      frekuensiPosyandu: frekuensiPosyandu ?? this.frekuensiPosyandu,
      mengikutiBkb: mengikutiBkb ?? this.mengikutiBkb,
      memilikiTabungan: memilikiTabungan ?? this.memilikiTabungan,
      mengikutiKelompokBelajar: mengikutiKelompokBelajar ?? this.mengikutiKelompokBelajar,
      jenisKelompokBelajar: jenisKelompokBelajar ?? this.jenisKelompokBelajar,
      mengikutiPaud: mengikutiPaud ?? this.mengikutiPaud,
      mengikutiKoperasi: mengikutiKoperasi ?? this.mengikutiKoperasi,
      jenisKoperasi: jenisKoperasi ?? this.jenisKoperasi,
      fotoRumahPath: fotoRumahPath ?? this.fotoRumahPath,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}
