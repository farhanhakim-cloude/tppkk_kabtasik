// lib/models/data_umum_pkk.dart
// ✅ HYBRID: Field lama (biar screen kompilasi) + fromJson API

class DataUmumPkkItem {
  final int id;
  final int? wilayahId;
  final String level;
  final String tahun;
  final String kabupaten;      // ← balikin — biar screen ga error
  final String provinsi;       // ← balikin
  final String kecamatan;
  final String desa;
  final String namaDusun;
  final String namaDesa;
  final int jumlahDusun;
  final int jumlahPkkRw;
  final int jumlahPkkRt;
  final int jumlahDasaWisma;   // ← pakai 's' — sesuai model lama
  final int jumlahKrt;
  final int jumlahKk;
  final int jiwaL;
  final int jiwaP;
  final int kaderTpPkkL;       // ← balikin — biar screen ga error
  final int kaderTpPkkP;
  final int kaderUmumL;
  final int kaderUmumP;
  final int kaderKhususL;
  final int kaderKhususP;
  final int sekretariatHonorerL;
  final int sekretariatHonorerP;
  final int sekretariatBantuanL;
  final int sekretariatBantuanP;
  final String keterangan;

  DataUmumPkkItem({
    required this.id,
    this.wilayahId,
    this.level = 'desa',
    this.tahun = '2026',
    this.kabupaten = 'TASIKMALAYA',
    this.provinsi = 'JAWA BARAT',
    this.kecamatan = '',
    this.desa = '',
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

  // Getter — biar screen lama jalan
  int get totalJiwa => jiwaL + jiwaP;
  int get totalKader =>
      kaderTpPkkL + kaderTpPkkP +
      kaderUmumL + kaderUmumP +
      kaderKhususL + kaderKhususP;
  int get totalSekretariat =>
      sekretariatHonorerL + sekretariatHonorerP +
      sekretariatBantuanL + sekretariatBantuanP;

  // Payload uses the Laravel table column names.
  Map<String, dynamic> toJson() => {
        'id': id,
        'wilayah_id': wilayahId,
        'level': level,
        'tahun': tahun,
        'kecamatan': kecamatan,
        'nama_kecamatan': kecamatan,
        'desa': desa,
        'nama_desa': namaDesa.isNotEmpty ? namaDesa : desa,
        'dusun': namaDusun,
        'nama_dusun': namaDusun,
        'jumlah_dusun': jumlahDusun,
        'jumlah_pkk_rw': jumlahPkkRw,
        'jumlah_pkk_rt': jumlahPkkRt,
        'jumlah_dasa_wisma': jumlahDasaWisma,
        'jumlah_krt': jumlahKrt,
        'jumlah_kk': jumlahKk,
        'jiwa_l': jiwaL,
        'jiwa_p': jiwaP,
        'tp_pkk_l': kaderTpPkkL,
        'tp_pkk_p': kaderTpPkkP,
        'kader_umum_l': kaderUmumL,
        'kader_umum_p': kaderUmumP,
        'kader_khusus_l': kaderKhususL,
        'kader_khusus_p': kaderKhususP,
        'sekretariat_honorer_l': sekretariatHonorerL,
        'sekretariat_honorer_p': sekretariatHonorerP,
        'sekretariat_bantuan_l': sekretariatBantuanL,
        'sekretariat_bantuan_p': sekretariatBantuanP,
        'keterangan': keterangan,
      };

  // ✅ fromJson — HYBRID: baca camelCase ATAU snake_case
  factory DataUmumPkkItem.fromJson(Map<String, dynamic> json) =>
      DataUmumPkkItem(
        id: _p(json['id']),
        wilayahId: json['wilayah_id'] != null ? _p(json['wilayah_id']) : null,
        level: json['level']?.toString() ?? 'desa',
        tahun: json['tahun']?.toString() ?? '2026',
        kabupaten: json['kabupaten']?.toString() ?? 'TASIKMALAYA',
        provinsi: json['provinsi']?.toString() ?? 'JAWA BARAT',
        kecamatan: json['kecamatan']?.toString() ?? '',
        desa: json['desa']?.toString() ?? '',
        namaDusun: (json['namaDusun'] ?? json['nama_dusun'])?.toString() ?? '',
        namaDesa: (json['namaDesa'] ?? json['nama_desa'])?.toString() ?? '',
        jumlahDusun: _p(json['jumlahDusun'] ?? json['jumlah_dusun']),
        jumlahPkkRw: _p(json['jumlahPkkRw'] ?? json['jumlah_pkk_rw']),
        jumlahPkkRt: _p(json['jumlahPkkRt'] ?? json['jumlah_pkk_rt']),
        jumlahDasaWisma: _p(json['jumlahDasaWisma'] ?? json['jumlah_dasa_wisma']),
        jumlahKrt: _p(json['jumlahKrt'] ?? json['jumlah_krt']),
        jumlahKk: _p(json['jumlahKk'] ?? json['jumlah_kk']),
        jiwaL: _p(json['jiwaL'] ?? json['jiwa_l']),
        jiwaP: _p(json['jiwaP'] ?? json['jiwa_p']),
        kaderTpPkkL: _p(json['kaderTpPkkL'] ?? json['tp_pkk_l']),
        kaderTpPkkP: _p(json['kaderTpPkkP'] ?? json['tp_pkk_p']),
        kaderUmumL: _p(json['kaderUmumL'] ?? json['kader_umum_l']),
        kaderUmumP: _p(json['kaderUmumP'] ?? json['kader_umum_p']),
        kaderKhususL: _p(json['kaderKhususL'] ?? json['kader_khusus_l']),
        kaderKhususP: _p(json['kaderKhususP'] ?? json['kader_khusus_p']),
        sekretariatHonorerL: _p(json['sekretariatHonorerL'] ?? json['sekretariat_honorer_l']),
        sekretariatHonorerP: _p(json['sekretariatHonorerP'] ?? json['sekretariat_honorer_p']),
        sekretariatBantuanL: _p(json['sekretariatBantuanL'] ?? json['sekretariat_bantuan_l']),
        sekretariatBantuanP: _p(json['sekretariatBantuanP'] ?? json['sekretariat_bantuan_p']),
        keterangan: json['keterangan']?.toString() ?? '',
      );

  static int _p(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  DataUmumPkkItem copyWith({
    int? id, int? wilayahId, String? level, String? tahun, String? kabupaten, String? provinsi,
    String? kecamatan, String? desa, String? namaDusun, String? namaDesa,
    int? jumlahDusun, int? jumlahPkkRw, int? jumlahPkkRt, int? jumlahDasaWisma,
    int? jumlahKrt, int? jumlahKk, int? jiwaL, int? jiwaP,
    int? kaderTpPkkL, int? kaderTpPkkP, int? kaderUmumL, int? kaderUmumP,
    int? kaderKhususL, int? kaderKhususP,
    int? sekretariatHonorerL, int? sekretariatHonorerP,
    int? sekretariatBantuanL, int? sekretariatBantuanP, String? keterangan,
  }) => DataUmumPkkItem(
        id: id ?? this.id,
        wilayahId: wilayahId ?? this.wilayahId,
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