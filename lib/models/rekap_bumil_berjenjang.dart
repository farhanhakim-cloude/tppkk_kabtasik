// lib/models/rekap_bumil_berjenjang.dart
// Model untuk Form Rekap Berjenjang Ibu Hamil, Melahirkan, Nifas, Kematian Ibu/Bayi & Balita
// Mendukung 5 Tingkat: RT, RW, Dusun, Desa, Kecamatan

class RekapBumilBerjenjangItem {
  final int id;
  final String level; // 'rt', 'rw', 'dusun', 'desa', 'kecamatan'
  final String bulan;
  final String tahun;
  final String kabupaten;
  final String provinsi;
  final String kecamatan;
  final String desa;
  final String dusun;
  final String rw;
  final String rt;

  // Kolom pengenal baris sesuai tingkat:
  final String namaDasawisma; // RT & RW
  final String nomorRt;       // RW
  final String nomorRw;       // Dusun
  final String namaDusun;     // Desa
  final String namaDesa;      // Kecamatan

  // Jumlah Wilayah Binaan (Dusun, Desa, Kecamatan):
  final int jumlahDusun;      // Kecamatan
  final int jumlahRw;         // Desa & Kecamatan
  final int jumlahRt;         // Dusun, Desa, Kecamatan
  final int jumlahDasawisma;  // Dusun, Desa, Kecamatan

  // Jumlah Ibu:
  final int ibuHamil;
  final int ibuMelahirkan;
  final int ibuNifas;
  final int ibuMeninggal;

  // Jumlah Bayi:
  final int bayiLahirL;
  final int bayiLahirP;
  final int akteAda;
  final int akteTidakAda;
  final int bayiMeninggalL;
  final int bayiMeninggalP;

  // Jumlah Balita Meninggal:
  final int balitaMeninggalL;
  final int balitaMeninggalP;

  // Keterangan:
  final String keterangan;

  RekapBumilBerjenjangItem({
    required this.id,
    required this.level,
    this.bulan = 'September',
    this.tahun = '2026',
    this.kabupaten = 'Tasikmalaya',
    this.provinsi = 'Jawa Barat',
    this.kecamatan = 'Singaparna',
    this.desa = 'Singaparna',
    this.dusun = 'Cikunir',
    this.rw = '05',
    this.rt = '01',
    this.namaDasawisma = '',
    this.nomorRt = '',
    this.nomorRw = '',
    this.namaDusun = '',
    this.namaDesa = '',
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'level': level,
        'bulan': bulan,
        'tahun': tahun,
        'kabupaten': kabupaten,
        'provinsi': provinsi,
        'kecamatan': kecamatan,
        'desa': desa,
        'dusun': dusun,
        'rw': rw,
        'rt': rt,
        'namaDasawisma': namaDasawisma,
        'nomorRt': nomorRt,
        'nomorRw': nomorRw,
        'namaDusun': namaDusun,
        'namaDesa': namaDesa,
        'jumlahDusun': jumlahDusun,
        'jumlahRw': jumlahRw,
        'jumlahRt': jumlahRt,
        'jumlahDasawisma': jumlahDasawisma,
        'ibuHamil': ibuHamil,
        'ibuMelahirkan': ibuMelahirkan,
        'ibuNifas': ibuNifas,
        'ibuMeninggal': ibuMeninggal,
        'bayiLahirL': bayiLahirL,
        'bayiLahirP': bayiLahirP,
        'akteAda': akteAda,
        'akteTidakAda': akteTidakAda,
        'bayiMeninggalL': bayiMeninggalL,
        'bayiMeninggalP': bayiMeninggalP,
        'balitaMeninggalL': balitaMeninggalL,
        'balitaMeninggalP': balitaMeninggalP,
        'keterangan': keterangan,
      };

  factory RekapBumilBerjenjangItem.fromJson(Map<String, dynamic> json) => RekapBumilBerjenjangItem(
        id: json['id'] as int? ?? 0,
        level: json['level'] as String? ?? 'rt',
        bulan: json['bulan'] as String? ?? 'September',
        tahun: json['tahun'] as String? ?? '2026',
        kabupaten: json['kabupaten'] as String? ?? 'Tasikmalaya',
        provinsi: json['provinsi'] as String? ?? 'Jawa Barat',
        kecamatan: json['kecamatan'] as String? ?? 'Singaparna',
        desa: json['desa'] as String? ?? 'Singaparna',
        dusun: json['dusun'] as String? ?? 'Cikunir',
        rw: json['rw'] as String? ?? '05',
        rt: json['rt'] as String? ?? '01',
        namaDasawisma: json['namaDasawisma'] as String? ?? '',
        nomorRt: json['nomorRt'] as String? ?? '',
        nomorRw: json['nomorRw'] as String? ?? '',
        namaDusun: json['namaDusun'] as String? ?? '',
        namaDesa: json['namaDesa'] as String? ?? '',
        jumlahDusun: json['jumlahDusun'] as int? ?? 0,
        jumlahRw: json['jumlahRw'] as int? ?? 0,
        jumlahRt: json['jumlahRt'] as int? ?? 0,
        jumlahDasawisma: json['jumlahDasawisma'] as int? ?? 0,
        ibuHamil: json['ibuHamil'] as int? ?? 0,
        ibuMelahirkan: json['ibuMelahirkan'] as int? ?? 0,
        ibuNifas: json['ibuNifas'] as int? ?? 0,
        ibuMeninggal: json['ibuMeninggal'] as int? ?? 0,
        bayiLahirL: json['bayiLahirL'] as int? ?? 0,
        bayiLahirP: json['bayiLahirP'] as int? ?? 0,
        akteAda: json['akteAda'] as int? ?? 0,
        akteTidakAda: json['akteTidakAda'] as int? ?? 0,
        bayiMeninggalL: json['bayiMeninggalL'] as int? ?? 0,
        bayiMeninggalP: json['bayiMeninggalP'] as int? ?? 0,
        balitaMeninggalL: json['balitaMeninggalL'] as int? ?? 0,
        balitaMeninggalP: json['balitaMeninggalP'] as int? ?? 0,
        keterangan: json['keterangan'] as String? ?? '',
      );

  RekapBumilBerjenjangItem copyWith({
    int? id,
    String? level,
    String? bulan,
    String? tahun,
    String? kabupaten,
    String? provinsi,
    String? kecamatan,
    String? desa,
    String? dusun,
    String? rw,
    String? rt,
    String? namaDasawisma,
    String? nomorRt,
    String? nomorRw,
    String? namaDusun,
    String? namaDesa,
    int? jumlahDusun,
    int? jumlahRw,
    int? jumlahRt,
    int? jumlahDasawisma,
    int? ibuHamil,
    int? ibuMelahirkan,
    int? ibuNifas,
    int? ibuMeninggal,
    int? bayiLahirL,
    int? bayiLahirP,
    int? akteAda,
    int? akteTidakAda,
    int? bayiMeninggalL,
    int? bayiMeninggalP,
    int? balitaMeninggalL,
    int? balitaMeninggalP,
    String? keterangan,
  }) {
    return RekapBumilBerjenjangItem(
      id: id ?? this.id,
      level: level ?? this.level,
      bulan: bulan ?? this.bulan,
      tahun: tahun ?? this.tahun,
      kabupaten: kabupaten ?? this.kabupaten,
      provinsi: provinsi ?? this.provinsi,
      kecamatan: kecamatan ?? this.kecamatan,
      desa: desa ?? this.desa,
      dusun: dusun ?? this.dusun,
      rw: rw ?? this.rw,
      rt: rt ?? this.rt,
      namaDasawisma: namaDasawisma ?? this.namaDasawisma,
      nomorRt: nomorRt ?? this.nomorRt,
      nomorRw: nomorRw ?? this.nomorRw,
      namaDusun: namaDusun ?? this.namaDusun,
      namaDesa: namaDesa ?? this.namaDesa,
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
}
