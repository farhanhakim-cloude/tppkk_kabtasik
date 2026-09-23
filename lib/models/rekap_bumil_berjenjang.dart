// lib/models/rekap_bumil_berjenjang.dart
// ✅ HYBRID: Field lama (screen jalan) + field baru (API) + fromJson hybrid

class RekapBumilBerjenjangItem {
  final int id;
  final int? wilayahId;
  final String level;
  final String tahun;

  // ⚠️ Field lama — `bulan` String — screen lama pakai ini
  final String bulan;
  // ✅ Field baru — `bulanInt` — API pakai ini (1-12)
  final int bulanInt;
  final String namaBulan;

  // Wilayah
  final String kabupaten;
  final String provinsi;
  final String kecamatan;
  final String namaKecamatan;
  final String desa;
  final String namaDesa;
  final String dusun;
  final String namaDusun;
  final String rw;
  final String rt;
  final String dasaWisma;

  // ✅ Field lama — biar screen lama jalan
  final String namaDasawisma;
  final String nomorRt;
  final String nomorRw;

  // Jumlah Wilayah Binaan
  final int jumlahDusun;
  final int jumlahRw;
  final int jumlahRt;
  final int jumlahDasawisma;

  // Jumlah Ibu
  final int ibuHamil;
  final int ibuMelahirkan;
  final int ibuNifas;
  final int ibuMeninggal;

  // Jumlah Bayi
  final int bayiLahirL;
  final int bayiLahirP;
  final int akteAda;
  final int akteTidakAda;
  final int bayiMeninggalL;
  final int bayiMeninggalP;

  // Jumlah Balita Meninggal
  final int balitaMeninggalL;
  final int balitaMeninggalP;

  // Keterangan
  final String keterangan;

  RekapBumilBerjenjangItem({
    required this.id,
    this.wilayahId,
    this.level = 'rt',
    this.bulan = 'September',
    this.bulanInt = 9,
    this.namaBulan = 'September',
    this.tahun = '2026',
    this.kabupaten = 'Tasikmalaya',
    this.provinsi = 'Jawa Barat',
    this.kecamatan = '',
    this.namaKecamatan = '',
    this.desa = '',
    this.namaDesa = '',
    this.dusun = '',
    this.namaDusun = '',
    this.rw = '',
    this.rt = '',
    this.dasaWisma = '',
    this.namaDasawisma = '',
    this.nomorRt = '',
    this.nomorRw = '',
    this.jumlahDusun = 0,
    this.jumlahRw = 0,
    this.jumlahRt = 0,
    this.jumlahDasawisma = 0,
    this.ibuHamil = 0,
    this.ibuMelahirkan = 0,
    this.ibuNifas = 0,
    this.ibuMeninggal = 0,
    this.bayiLahirL = 0,
    this.bayiLahirP = 0,
    this.akteAda = 0,
    this.akteTidakAda = 0,
    this.bayiMeninggalL = 0,
    this.bayiMeninggalP = 0,
    this.balitaMeninggalL = 0,
    this.balitaMeninggalP = 0,
    this.keterangan = '',
  });

  // ============================================================
  // GETTER
  // ============================================================
  int get totalBayiLahir => bayiLahirL + bayiLahirP;
  int get totalBayiMeninggal => bayiMeninggalL + bayiMeninggalP;
  int get totalBalitaMeninggal => balitaMeninggalL + balitaMeninggalP;
  int get totalIbuMeninggal => ibuMeninggal;

  static String namaBulanDariInt(int bulan) {
    const list = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    if (bulan < 1 || bulan > 12) return 'Januari';
    return list[bulan - 1];
  }

  static int intDariNamaBulan(String nama) {
    const list = [
      'januari', 'februari', 'maret', 'april', 'mei', 'juni',
      'juli', 'agustus', 'september', 'oktober', 'november', 'desember',
    ];
    final idx = list.indexOf(nama.toLowerCase());
    return idx >= 0 ? idx + 1 : 1;
  }

  // Payload uses the Laravel table column names.
  Map<String, dynamic> toJson() => {
        'id': id,
        'wilayah_id': wilayahId,
        'level': level,
        'bulan': bulanInt,
        'nama_bulan': namaBulan,
        'tahun': tahun,
        'kecamatan': kecamatan,
        'nama_kecamatan': namaKecamatan.isNotEmpty ? namaKecamatan : kecamatan,
        'desa': desa,
        'nama_desa': namaDesa.isNotEmpty ? namaDesa : desa,
        'dusun': dusun,
        'nama_dusun': namaDusun.isNotEmpty ? namaDusun : dusun,
        'rw': rw,
        'rt': rt,
        'nama_dasawisma': namaDasawisma,
        'jumlah_dusun': jumlahDusun,
        'jumlah_rw': jumlahRw,
        'jumlah_rt': jumlahRt,
        'jumlah_dasa_wisma': jumlahDasawisma,
        'ibu_hamil': ibuHamil,
        'ibu_melahirkan': ibuMelahirkan,
        'ibu_nifas': ibuNifas,
        'ibu_meninggal': ibuMeninggal,
        'bayi_lahir_l': bayiLahirL,
        'bayi_lahir_p': bayiLahirP,
        'akte_ada': akteAda,
        'akte_tidak_ada': akteTidakAda,
        'bayi_meninggal_l': bayiMeninggalL,
        'bayi_meninggal_p': bayiMeninggalP,
        'balita_meninggal_l': balitaMeninggalL,
        'balita_meninggal_p': balitaMeninggalP,
        'keterangan': keterangan,
      };

  // ============================================================
  // FROM JSON — HYBRID: camelCase ATAU snake_case
  // ============================================================
  factory RekapBumilBerjenjangItem.fromJson(Map<String, dynamic> json) {
    // Parse bulan — dari int atau string
    int bulanIntParse = 1;
    String bulanStr = 'Januari';

    if (json['bulanInt'] != null) {
      bulanIntParse = _p(json['bulanInt']);
      bulanStr = namaBulanDariInt(bulanIntParse);
    } else if (json['bulan'] is int) {
      bulanIntParse = json['bulan'] as int;
      bulanStr = namaBulanDariInt(bulanIntParse);
    } else if (json['bulan'] is String) {
      // Coba parse integer dulu
      final asInt = int.tryParse(json['bulan']);
      if (asInt != null && asInt >= 1 && asInt <= 12) {
        bulanIntParse = asInt;
        bulanStr = namaBulanDariInt(asInt);
      } else {
        // Parse dari nama bulan
        bulanStr = json['bulan'] as String;
        bulanIntParse = intDariNamaBulan(bulanStr);
      }
    } else if (json['nama_bulan'] != null) {
      bulanStr = json['nama_bulan'].toString();
      bulanIntParse = intDariNamaBulan(bulanStr);
    } else if (json['namaBulan'] != null) {
      bulanStr = json['namaBulan'].toString();
      bulanIntParse = intDariNamaBulan(bulanStr);
    }

    return RekapBumilBerjenjangItem(
      id: _p(json['id']),
      wilayahId: json['wilayah_id'] != null ? _p(json['wilayah_id']) : null,
      level: json['level']?.toString() ?? 'rt',
      bulan: bulanStr,
      bulanInt: bulanIntParse,
      namaBulan: (json['namaBulan'] ?? json['nama_bulan'])?.toString() ?? bulanStr,
      tahun: json['tahun']?.toString() ?? '2026',
      kabupaten: json['kabupaten']?.toString() ?? 'Tasikmalaya',
      provinsi: json['provinsi']?.toString() ?? 'Jawa Barat',
      kecamatan: json['kecamatan']?.toString() ?? '',
      namaKecamatan: (json['namaKecamatan'] ?? json['nama_kecamatan'])?.toString() ?? '',
      desa: json['desa']?.toString() ?? '',
      namaDesa: (json['namaDesa'] ?? json['nama_desa'])?.toString() ?? '',
      dusun: json['dusun']?.toString() ?? '',
      namaDusun: (json['namaDusun'] ?? json['nama_dusun'])?.toString() ?? '',
      rw: json['rw']?.toString() ?? '',
      rt: json['rt']?.toString() ?? '',
      dasaWisma: (json['dasaWisma'] ?? json['dasa_wisma'])?.toString() ?? '',
      namaDasawisma: (json['namaDasawisma'] ?? json['nama_dasawisma'])?.toString() ?? '',
      nomorRt: (json['nomorRt'] ?? json['nomor_rt'] ?? json['rt'])?.toString() ?? '',
      nomorRw: (json['nomorRw'] ?? json['nomor_rw'] ?? json['rw'])?.toString() ?? '',
      jumlahDusun: _p(json['jumlahDusun'] ?? json['jumlah_dusun']),
      jumlahRw: _p(json['jumlahRw'] ?? json['jumlah_rw']),
      jumlahRt: _p(json['jumlahRt'] ?? json['jumlah_rt']),
      jumlahDasawisma: _p(json['jumlahDasawisma'] ?? json['jumlah_dasa_wisma']),
      ibuHamil: _p(json['ibuHamil'] ?? json['ibu_hamil']),
      ibuMelahirkan: _p(json['ibuMelahirkan'] ?? json['ibu_melahirkan']),
      ibuNifas: _p(json['ibuNifas'] ?? json['ibu_nifas']),
      ibuMeninggal: _p(json['ibuMeninggal'] ?? json['ibu_meninggal']),
      bayiLahirL: _p(json['bayiLahirL'] ?? json['bayi_lahir_l']),
      bayiLahirP: _p(json['bayiLahirP'] ?? json['bayi_lahir_p']),
      akteAda: _p(json['akteAda'] ?? json['akte_ada']),
      akteTidakAda: _p(json['akteTidakAda'] ?? json['akte_tidak_ada']),
      bayiMeninggalL: _p(json['bayiMeninggalL'] ?? json['bayi_meninggal_l']),
      bayiMeninggalP: _p(json['bayiMeninggalP'] ?? json['bayi_meninggal_p']),
      balitaMeninggalL: _p(json['balitaMeninggalL'] ?? json['balita_meninggal_l']),
      balitaMeninggalP: _p(json['balitaMeninggalP'] ?? json['balita_meninggal_p']),
      keterangan: json['keterangan']?.toString() ?? '',
    );
  }

  static int _p(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  // ============================================================
  // COPY WITH
  // ============================================================
  RekapBumilBerjenjangItem copyWith({
    int? id, int? wilayahId, String? level, String? tahun,
    String? bulan, int? bulanInt, String? namaBulan,
    String? kabupaten, String? provinsi,
    String? kecamatan, String? namaKecamatan,
    String? desa, String? namaDesa, String? dusun, String? namaDusun,
    String? rw, String? rt, String? dasaWisma,
    String? namaDasawisma, String? nomorRt, String? nomorRw,
    int? jumlahDusun, int? jumlahRw, int? jumlahRt, int? jumlahDasawisma,
    int? ibuHamil, int? ibuMelahirkan, int? ibuNifas, int? ibuMeninggal,
    int? bayiLahirL, int? bayiLahirP, int? akteAda, int? akteTidakAda,
    int? bayiMeninggalL, int? bayiMeninggalP,
    int? balitaMeninggalL, int? balitaMeninggalP,
    String? keterangan,
  }) => RekapBumilBerjenjangItem(
        id: id ?? this.id,
        wilayahId: wilayahId ?? this.wilayahId,
        level: level ?? this.level,
        tahun: tahun ?? this.tahun,
        bulan: bulan ?? this.bulan,
        bulanInt: bulanInt ?? this.bulanInt,
        namaBulan: namaBulan ?? this.namaBulan,
        kabupaten: kabupaten ?? this.kabupaten,
        provinsi: provinsi ?? this.provinsi,
        kecamatan: kecamatan ?? this.kecamatan,
        namaKecamatan: namaKecamatan ?? this.namaKecamatan,
        desa: desa ?? this.desa,
        namaDesa: namaDesa ?? this.namaDesa,
        dusun: dusun ?? this.dusun,
        namaDusun: namaDusun ?? this.namaDusun,
        rw: rw ?? this.rw,
        rt: rt ?? this.rt,
        dasaWisma: dasaWisma ?? this.dasaWisma,
        namaDasawisma: namaDasawisma ?? this.namaDasawisma,
        nomorRt: nomorRt ?? this.nomorRt,
        nomorRw: nomorRw ?? this.nomorRw,
        jumlahDusun: jumlahDusun ?? this.jumlahDusun,
        jumlahRw: jumlahRw ?? this.jumlahRw,
        jumlahRt: jumlahRt ?? this.jumlahRt,
        jumlahDasawisma: jumlahDasawisma ?? this.jumlahDasawisma,
        ibuHamil: ibuHamil ?? this.ibuHamil,
        ibuMelahirkan: ibuMelahirkan ?? this.ibuMelahirkan,
        ibuNifas: ibuNifas ?? this.ibuNifas,
        ibuMeninggal: ibuMeninggal ?? this.ibuMeninggal,
        bayiLahirL: bayiLahirL ?? this.bayiLahirL,
        bayiLahirP: bayiLahirP ?? this.bayiLahirP,
        akteAda: akteAda ?? this.akteAda,
        akteTidakAda: akteTidakAda ?? this.akteTidakAda,
        bayiMeninggalL: bayiMeninggalL ?? this.bayiMeninggalL,
        bayiMeninggalP: bayiMeninggalP ?? this.bayiMeninggalP,
        balitaMeninggalL: balitaMeninggalL ?? this.balitaMeninggalL,
        balitaMeninggalP: balitaMeninggalP ?? this.balitaMeninggalP,
        keterangan: keterangan ?? this.keterangan,
      );
}