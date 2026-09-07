// lib/models/kriteria_rumah.dart

class KriteriaRumah {
  final String id;

  // Identitas
  final String namaKepalaKeluarga;
  final String noKk;
  final String rt;
  final String rw;
  final String desa;
  final String kecamatan;
  final String kabupaten;
  final String dasaWisma;
  final String tanggalPenilaian;

  // ── KRITERIA LAYAK HUNI (5 aspek, Kementerian PUPR / SDGs) ──────────────────
  // 1. Ketahanan Bangunan (Keselamatan)
  final bool strukturAmanKokoh;       // Struktur bangunan aman & kokoh
  final bool atapTidakBocor;          // Atap tidak bocor (genteng/seng/beton)
  final bool lantaiPadat;             // Lantai padat & aman (ubin/semen/keramik)
  final bool dindingKokoh;            // Dinding kokoh & tidak lapuk (tembok/plesteran)

  // 2. Kecukupan Luas
  final bool luasMinimalPerOrang;     // Luas ≥ 7,2 m² per orang
  final bool ketinggianRuangCukup;    // Ketinggian ruang ≥ 2,8 m

  // 3. Akses Air Minum & Sanitasi
  final bool airMinumTerlindungi;     // Air minum terlindungi & berkelanjutan
  final bool sanitasiLayak;           // Memiliki jamban/toilet dengan septic tank

  // 4. Kesehatan Lingkungan Rumah
  final bool pencahayaanVentilasi;    // Jendela/bukaan cukup, sirkulasi udara & cahaya matahari

  // 5. Legalitas Kepemilikan
  final bool legalitasTanah;          // Dibangun di atas tanah legal & surat kepemilikan sah

  // ── KRITERIA TIDAK LAYAK HUNI (8 poin, Kemensos RI) ────────────────────────
  final bool luasDiBawah9m2;          // Luas ruangan < 9 m² per orang
  final bool konstruksiBuruk;         // Konstruksi bangunan buruk / membahayakan
  final bool sirkulasiUdaraKurang;    // Sistem sirkulasi udara kurang baik
  final bool kurangPencahayaanAlami;  // Kurang pencahayaan alami
  final bool kelembapanTinggi;        // Tingkat kelembapan tinggi
  final bool sanitasiBuruk;           // Sistem sanitasi buruk
  final bool sulitAirBersih;          // Sulit mendapat air bersih/minum
  final bool lokasiMembahayakan;      // Lokasi di daerah yang membahayakan

  // Catatan tambahan
  final String catatan;

  KriteriaRumah({
    required this.id,
    required this.namaKepalaKeluarga,
    required this.noKk,
    required this.rt,
    required this.rw,
    required this.desa,
    required this.kecamatan,
    required this.kabupaten,
    required this.dasaWisma,
    required this.tanggalPenilaian,
    // Layak huni
    this.strukturAmanKokoh = false,
    this.atapTidakBocor = false,
    this.lantaiPadat = false,
    this.dindingKokoh = false,
    this.luasMinimalPerOrang = false,
    this.ketinggianRuangCukup = false,
    this.airMinumTerlindungi = false,
    this.sanitasiLayak = false,
    this.pencahayaanVentilasi = false,
    this.legalitasTanah = false,
    // Tidak layak huni
    this.luasDiBawah9m2 = false,
    this.konstruksiBuruk = false,
    this.sirkulasiUdaraKurang = false,
    this.kurangPencahayaanAlami = false,
    this.kelembapanTinggi = false,
    this.sanitasiBuruk = false,
    this.sulitAirBersih = false,
    this.lokasiMembahayakan = false,
    this.catatan = '',
  });

  /// Hitung skor layak huni (0-10)
  int get skorLayakHuni {
    int skor = 0;
    if (strukturAmanKokoh) skor++;
    if (atapTidakBocor) skor++;
    if (lantaiPadat) skor++;
    if (dindingKokoh) skor++;
    if (luasMinimalPerOrang) skor++;
    if (ketinggianRuangCukup) skor++;
    if (airMinumTerlindungi) skor++;
    if (sanitasiLayak) skor++;
    if (pencahayaanVentilasi) skor++;
    if (legalitasTanah) skor++;
    return skor;
  }

  /// Hitung jumlah indikator tidak layak huni (0-8)
  int get jumlahTidakLayak {
    int jumlah = 0;
    if (luasDiBawah9m2) jumlah++;
    if (konstruksiBuruk) jumlah++;
    if (sirkulasiUdaraKurang) jumlah++;
    if (kurangPencahayaanAlami) jumlah++;
    if (kelembapanTinggi) jumlah++;
    if (sanitasiBuruk) jumlah++;
    if (sulitAirBersih) jumlah++;
    if (lokasiMembahayakan) jumlah++;
    return jumlah;
  }

  /// Status akhir: 'Layak Huni', 'Perlu Perhatian', atau 'Tidak Layak Huni'
  String get statusRumah {
    // Jika ada ≥ 3 indikator tidak layak → Tidak Layak Huni
    if (jumlahTidakLayak >= 3) return 'Tidak Layak Huni';
    // Jika skor layak huni ≥ 8 dan tidak layak < 3 → Layak Huni
    if (skorLayakHuni >= 8 && jumlahTidakLayak < 2) return 'Layak Huni';
    return 'Perlu Perhatian';
  }

  KriteriaRumah copyWith({
    String? id,
    String? namaKepalaKeluarga,
    String? noKk,
    String? rt,
    String? rw,
    String? desa,
    String? kecamatan,
    String? kabupaten,
    String? dasaWisma,
    String? tanggalPenilaian,
    bool? strukturAmanKokoh,
    bool? atapTidakBocor,
    bool? lantaiPadat,
    bool? dindingKokoh,
    bool? luasMinimalPerOrang,
    bool? ketinggianRuangCukup,
    bool? airMinumTerlindungi,
    bool? sanitasiLayak,
    bool? pencahayaanVentilasi,
    bool? legalitasTanah,
    bool? luasDiBawah9m2,
    bool? konstruksiBuruk,
    bool? sirkulasiUdaraKurang,
    bool? kurangPencahayaanAlami,
    bool? kelembapanTinggi,
    bool? sanitasiBuruk,
    bool? sulitAirBersih,
    bool? lokasiMembahayakan,
    String? catatan,
  }) {
    return KriteriaRumah(
      id: id ?? this.id,
      namaKepalaKeluarga: namaKepalaKeluarga ?? this.namaKepalaKeluarga,
      noKk: noKk ?? this.noKk,
      rt: rt ?? this.rt,
      rw: rw ?? this.rw,
      desa: desa ?? this.desa,
      kecamatan: kecamatan ?? this.kecamatan,
      kabupaten: kabupaten ?? this.kabupaten,
      dasaWisma: dasaWisma ?? this.dasaWisma,
      tanggalPenilaian: tanggalPenilaian ?? this.tanggalPenilaian,
      strukturAmanKokoh: strukturAmanKokoh ?? this.strukturAmanKokoh,
      atapTidakBocor: atapTidakBocor ?? this.atapTidakBocor,
      lantaiPadat: lantaiPadat ?? this.lantaiPadat,
      dindingKokoh: dindingKokoh ?? this.dindingKokoh,
      luasMinimalPerOrang: luasMinimalPerOrang ?? this.luasMinimalPerOrang,
      ketinggianRuangCukup: ketinggianRuangCukup ?? this.ketinggianRuangCukup,
      airMinumTerlindungi: airMinumTerlindungi ?? this.airMinumTerlindungi,
      sanitasiLayak: sanitasiLayak ?? this.sanitasiLayak,
      pencahayaanVentilasi: pencahayaanVentilasi ?? this.pencahayaanVentilasi,
      legalitasTanah: legalitasTanah ?? this.legalitasTanah,
      luasDiBawah9m2: luasDiBawah9m2 ?? this.luasDiBawah9m2,
      konstruksiBuruk: konstruksiBuruk ?? this.konstruksiBuruk,
      sirkulasiUdaraKurang: sirkulasiUdaraKurang ?? this.sirkulasiUdaraKurang,
      kurangPencahayaanAlami: kurangPencahayaanAlami ?? this.kurangPencahayaanAlami,
      kelembapanTinggi: kelembapanTinggi ?? this.kelembapanTinggi,
      sanitasiBuruk: sanitasiBuruk ?? this.sanitasiBuruk,
      sulitAirBersih: sulitAirBersih ?? this.sulitAirBersih,
      lokasiMembahayakan: lokasiMembahayakan ?? this.lokasiMembahayakan,
      catatan: catatan ?? this.catatan,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'namaKepalaKeluarga': namaKepalaKeluarga,
      'noKk': noKk,
      'rt': rt,
      'rw': rw,
      'desa': desa,
      'kecamatan': kecamatan,
      'kabupaten': kabupaten,
      'dasaWisma': dasaWisma,
      'tanggalPenilaian': tanggalPenilaian,
      'strukturAmanKokoh': strukturAmanKokoh,
      'atapTidakBocor': atapTidakBocor,
      'lantaiPadat': lantaiPadat,
      'dindingKokoh': dindingKokoh,
      'luasMinimalPerOrang': luasMinimalPerOrang,
      'ketinggianRuangCukup': ketinggianRuangCukup,
      'airMinumTerlindungi': airMinumTerlindungi,
      'sanitasiLayak': sanitasiLayak,
      'pencahayaanVentilasi': pencahayaanVentilasi,
      'legalitasTanah': legalitasTanah,
      'luasDiBawah9m2': luasDiBawah9m2,
      'konstruksiBuruk': konstruksiBuruk,
      'sirkulasiUdaraKurang': sirkulasiUdaraKurang,
      'kurangPencahayaanAlami': kurangPencahayaanAlami,
      'kelembapanTinggi': kelembapanTinggi,
      'sanitasiBuruk': sanitasiBuruk,
      'sulitAirBersih': sulitAirBersih,
      'lokasiMembahayakan': lokasiMembahayakan,
      'catatan': catatan,
    };
  }

  factory KriteriaRumah.fromMap(Map<String, dynamic> map) {
    return KriteriaRumah(
      id: map['id'] as String,
      namaKepalaKeluarga: map['namaKepalaKeluarga'] as String,
      noKk: map['noKk'] as String,
      rt: map['rt'] as String,
      rw: map['rw'] as String,
      desa: map['desa'] as String,
      kecamatan: map['kecamatan'] as String,
      kabupaten: map['kabupaten'] as String,
      dasaWisma: map['dasaWisma'] as String,
      tanggalPenilaian: map['tanggalPenilaian'] as String,
      strukturAmanKokoh: (map['strukturAmanKokoh'] as bool?) ?? false,
      atapTidakBocor: (map['atapTidakBocor'] as bool?) ?? false,
      lantaiPadat: (map['lantaiPadat'] as bool?) ?? false,
      dindingKokoh: (map['dindingKokoh'] as bool?) ?? false,
      luasMinimalPerOrang: (map['luasMinimalPerOrang'] as bool?) ?? false,
      ketinggianRuangCukup: (map['ketinggianRuangCukup'] as bool?) ?? false,
      airMinumTerlindungi: (map['airMinumTerlindungi'] as bool?) ?? false,
      sanitasiLayak: (map['sanitasiLayak'] as bool?) ?? false,
      pencahayaanVentilasi: (map['pencahayaanVentilasi'] as bool?) ?? false,
      legalitasTanah: (map['legalitasTanah'] as bool?) ?? false,
      luasDiBawah9m2: (map['luasDiBawah9m2'] as bool?) ?? false,
      konstruksiBuruk: (map['konstruksiBuruk'] as bool?) ?? false,
      sirkulasiUdaraKurang: (map['sirkulasiUdaraKurang'] as bool?) ?? false,
      kurangPencahayaanAlami: (map['kurangPencahayaanAlami'] as bool?) ?? false,
      kelembapanTinggi: (map['kelembapanTinggi'] as bool?) ?? false,
      sanitasiBuruk: (map['sanitasiBuruk'] as bool?) ?? false,
      sulitAirBersih: (map['sulitAirBersih'] as bool?) ?? false,
      lokasiMembahayakan: (map['lokasiMembahayakan'] as bool?) ?? false,
      catatan: (map['catatan'] as String?) ?? '',
    );
  }
}
