// lib/models/data_umum_pkk.dart
// Model data untuk Data Umum PKK Tingkat Desa (20 kolom) dan Kecamatan (21 kolom)
// Sesuai format formulir resmi TP PKK Kabupaten Tasikmalaya

class DataUmumPkkItem {
  final int id;
  final String level; // 'desa' atau 'kecamatan'
  final String tahun;
  final String kabupaten;
  final String provinsi;
  final String kecamatan;
  final String desa; // Diisi jika level == 'desa'

  // Kolom pengenal baris:
  // Tingkat Desa: Nama Dusun / Lingkungan / Sebutan Lainnya (Kolom 2)
  // Tingkat Kecamatan: Nama Desa (Kolom 2)
  final String namaDusun;
  final String namaDesa;

  // Jumlah Wilayah / Kelompok:
  final int jumlahDusun; // Hanya ada di Kecamatan (Kolom 3)
  final int jumlahPkkRw; // Desa (Kolom 3), Kecamatan (Kolom 4)
  final int jumlahPkkRt; // Desa (Kolom 4), Kecamatan (Kolom 5)
  final int jumlahDasaWisma; // Desa (Kolom 5), Kecamatan (Kolom 6)

  // Jumlah KRT & KK:
  final int jumlahKrt; // Desa (Kolom 6), Kecamatan (Kolom 7)
  final int jumlahKk; // Desa (Kolom 7), Kecamatan (Kolom 8)

  // Jumlah Jiwa:
  final int jiwaL; // L
  final int jiwaP; // P

  // Jumlah Kader:
  // 1. Anggota TP PKK
  final int kaderTpPkkL;
  final int kaderTpPkkP;
  // 2. Kader Umum
  final int kaderUmumL;
  final int kaderUmumP;
  // 3. Kader Khusus
  final int kaderKhususL;
  final int kaderKhususP;

  // Jumlah Tenaga Sekretariat:
  // 1. Honorer
  final int sekretariatHonorerL;
  final int sekretariatHonorerP;
  // 2. Bantuan
  final int sekretariatBantuanL;
  final int sekretariatBantuanP;

  // Keterangan
  final String keterangan;

  DataUmumPkkItem({
    required this.id,
    required this.level,
    this.tahun = '2026',
    this.kabupaten = 'TASIKMALAYA',
    this.provinsi = 'JAWA BARAT',
    this.kecamatan = 'Singaparna',
    this.desa = 'Singaparna',
    this.namaDusun = '',
    this.namaDesa = '',
    this.jumlahDusun = 0,
    this.jumlahPkkRw = 0,
    this.jumlahPkkRt = 0,
    this.jumlahDasaWisma = 0,
    this.jumlahKrt = 0,
    this.jumlahKk = 0,
    this.jiwaL = 0,
    this.jiwaP = 0,
    this.kaderTpPkkL = 0,
    this.kaderTpPkkP = 0,
    this.kaderUmumL = 0,
    this.kaderUmumP = 0,
    this.kaderKhususL = 0,
    this.kaderKhususP = 0,
    this.sekretariatHonorerL = 0,
    this.sekretariatHonorerP = 0,
    this.sekretariatBantuanL = 0,
    this.sekretariatBantuanP = 0,
    this.keterangan = '',
  });

  int get totalJiwa => jiwaL + jiwaP;
  int get totalKader =>
      kaderTpPkkL +
      kaderTpPkkP +
      kaderUmumL +
      kaderUmumP +
      kaderKhususL +
      kaderKhususP;
  int get totalSekretariat =>
      sekretariatHonorerL +
      sekretariatHonorerP +
      sekretariatBantuanL +
      sekretariatBantuanP;

  Map<String, dynamic> toJson() => {
        'id': id,
        'level': level,
        'tahun': tahun,
        'kabupaten': kabupaten,
        'provinsi': provinsi,
        'kecamatan': kecamatan,
        'desa': desa,
        'namaDusun': namaDusun,
        'namaDesa': namaDesa,
        'jumlahDusun': jumlahDusun,
        'jumlahPkkRw': jumlahPkkRw,
        'jumlahPkkRt': jumlahPkkRt,
        'jumlahDasaWisma': jumlahDasaWisma,
        'jumlahKrt': jumlahKrt,
        'jumlahKk': jumlahKk,
        'jiwaL': jiwaL,
        'jiwaP': jiwaP,
        'kaderTpPkkL': kaderTpPkkL,
        'kaderTpPkkP': kaderTpPkkP,
        'kaderUmumL': kaderUmumL,
        'kaderUmumP': kaderUmumP,
        'kaderKhususL': kaderKhususL,
        'kaderKhususP': kaderKhususP,
        'sekretariatHonorerL': sekretariatHonorerL,
        'sekretariatHonorerP': sekretariatHonorerP,
        'sekretariatBantuanL': sekretariatBantuanL,
        'sekretariatBantuanP': sekretariatBantuanP,
        'keterangan': keterangan,
      };

  factory DataUmumPkkItem.fromJson(Map<String, dynamic> json) =>
      DataUmumPkkItem(
        id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
        level: json['level'] ?? 'desa',
        tahun: json['tahun'] ?? '2026',
        kabupaten: json['kabupaten'] ?? 'TASIKMALAYA',
        provinsi: json['provinsi'] ?? 'JAWA BARAT',
        kecamatan: json['kecamatan'] ?? '',
        desa: json['desa'] ?? '',
        namaDusun: json['namaDusun'] ?? '',
        namaDesa: json['namaDesa'] ?? '',
        jumlahDusun: json['jumlahDusun'] ?? 0,
        jumlahPkkRw: json['jumlahPkkRw'] ?? 0,
        jumlahPkkRt: json['jumlahPkkRt'] ?? 0,
        jumlahDasaWisma: json['jumlahDasaWisma'] ?? 0,
        jumlahKrt: json['jumlahKrt'] ?? 0,
        jumlahKk: json['jumlahKk'] ?? 0,
        jiwaL: json['jiwaL'] ?? 0,
        jiwaP: json['jiwaP'] ?? 0,
        kaderTpPkkL: json['kaderTpPkkL'] ?? 0,
        kaderTpPkkP: json['kaderTpPkkP'] ?? 0,
        kaderUmumL: json['kaderUmumL'] ?? 0,
        kaderUmumP: json['kaderUmumP'] ?? 0,
        kaderKhususL: json['kaderKhususL'] ?? 0,
        kaderKhususP: json['kaderKhususP'] ?? 0,
        sekretariatHonorerL: json['sekretariatHonorerL'] ?? 0,
        sekretariatHonorerP: json['sekretariatHonorerP'] ?? 0,
        sekretariatBantuanL: json['sekretariatBantuanL'] ?? 0,
        sekretariatBantuanP: json['sekretariatBantuanP'] ?? 0,
        keterangan: json['keterangan'] ?? '',
      );

  DataUmumPkkItem copyWith({
    int? id,
    String? level,
    String? tahun,
    String? kabupaten,
    String? provinsi,
    String? kecamatan,
    String? desa,
    String? namaDusun,
    String? namaDesa,
    int? jumlahDusun,
    int? jumlahPkkRw,
    int? jumlahPkkRt,
    int? jumlahDasaWisma,
    int? jumlahKrt,
    int? jumlahKk,
    int? jiwaL,
    int? jiwaP,
    int? kaderTpPkkL,
    int? kaderTpPkkP,
    int? kaderUmumL,
    int? kaderUmumP,
    int? kaderKhususL,
    int? kaderKhususP,
    int? sekretariatHonorerL,
    int? sekretariatHonorerP,
    int? sekretariatBantuanL,
    int? sekretariatBantuanP,
    String? keterangan,
  }) {
    return DataUmumPkkItem(
      id: id ?? this.id,
      level: level ?? this.level,
      tahun: tahun ?? this.tahun,
      kabupaten: kabupaten ?? this.kabupaten,
      provinsi: provinsi ?? this.provinsi,
      kecamatan: kecamatan ?? this.kecamatan,
      desa: desa ?? this.desa,
      namaDusun: namaDusun ?? this.namaDusun,
      namaDesa: namaDesa ?? this.namaDesa,
      jumlahDusun: jumlahDusun ?? this.jumlahDusun,
      jumlahPkkRw: jumlahPkkRw ?? this.jumlahPkkRw,
      jumlahPkkRt: jumlahPkkRt ?? this.jumlahPkkRt,
      jumlahDasaWisma: jumlahDasaWisma ?? this.jumlahDasaWisma,
      jumlahKrt: jumlahKrt ?? this.jumlahKrt,
      jumlahKk: jumlahKk ?? this.jumlahKk,
      jiwaL: jiwaL ?? this.jiwaL,
      jiwaP: jiwaP ?? this.jiwaP,
      kaderTpPkkL: kaderTpPkkL ?? this.kaderTpPkkL,
      kaderTpPkkP: kaderTpPkkP ?? this.kaderTpPkkP,
      kaderUmumL: kaderUmumL ?? this.kaderUmumL,
      kaderUmumP: kaderUmumP ?? this.kaderUmumP,
      kaderKhususL: kaderKhususL ?? this.kaderKhususL,
      kaderKhususP: kaderKhususP ?? this.kaderKhususP,
      sekretariatHonorerL: sekretariatHonorerL ?? this.sekretariatHonorerL,
      sekretariatHonorerP: sekretariatHonorerP ?? this.sekretariatHonorerP,
      sekretariatBantuanL: sekretariatBantuanL ?? this.sekretariatBantuanL,
      sekretariatBantuanP: sekretariatBantuanP ?? this.sekretariatBantuanP,
      keterangan: keterangan ?? this.keterangan,
    );
  }
}
